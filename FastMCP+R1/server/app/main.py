import os
import json
import time
import uuid
import asyncio
from datetime import datetime
from typing import List, Optional

import httpx
from fastapi import FastAPI, HTTPException
from sse_starlette.sse import EventSourceResponse
from pydantic import BaseModel
from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine

TMDB_BEARER = os.getenv("TMDB_BEARER_TOKEN", "")
TMDB_API_KEY = os.getenv("TMDB_API_KEY", "")
TMDB_BASE = "https://api.themoviedb.org/3"
LANG = os.getenv("TMDB_LANG", "es-ES")
REGION = os.getenv("TMDB_REGION", "ES")

OLLAMA_BASE_URL = os.getenv("OLLAMA_BASE_URL", "http://ollama:11434")
MODEL_NAME = os.getenv("OLLAMA_MODEL", "deepseek-r1:14b")

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql+psycopg://tmdb:tmdb@db:5432/tmdb")
engine: Engine = create_engine(DATABASE_URL, pool_pre_ping=True)

app = FastAPI(title="TMDb Recommender API", version="0.1.0")

# ---- DB bootstrap ----
SCHEMA_SQL = """
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS views (
  user_id TEXT NOT NULL,
  item_id BIGINT NOT NULL,
  media_type TEXT NOT NULL CHECK(media_type IN ('movie','tv')),
  rating INT,
  watched_at TIMESTAMP NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, item_id, media_type),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
"""

@app.on_event("startup")
def on_startup():
    with engine.begin() as conn:
        for stmt in SCHEMA_SQL.split(";\n\n"):
            sql = stmt.strip()
            if sql:
                conn.execute(text(sql))

# ---- Models ----
class CreateUserResp(BaseModel):
    user_id: str

class ViewIn(BaseModel):
    user_id: str
    item_id: int
    media_type: str  # "movie" | "tv"
    rating: Optional[int] = None
    watched_at: Optional[datetime] = None

class RecsOut(BaseModel):
    results: List[dict]

# ---- TMDb helpers ----
def tmdb_headers():
    if TMDB_BEARER:
        return {"Authorization": f"Bearer {TMDB_BEARER}"}
    elif TMDB_API_KEY:
        return {}
    else:
        raise RuntimeError("Configura TMDB_BEARER_TOKEN o TMDB_API_KEY")

async def tmdb_get(path: str, params: dict | None = None):
    params = params or {}
    params.setdefault("language", LANG)
    params.setdefault("region", REGION)
    if TMDB_API_KEY and not TMDB_BEARER:
        params.setdefault("api_key", TMDB_API_KEY)
    url = f"{TMDB_BASE}{path}"
    async with httpx.AsyncClient(timeout=20) as client:
        r = await client.get(url, params=params, headers=tmdb_headers())
        r.raise_for_status()
        return r.json()

# ---- Ollama helper (opcional para rerank por estado de ánimo) ----
import re

THINK_TAGS_RE = re.compile(r"<think>.*?</think>", re.DOTALL)

async def ollama_generate(prompt: str, model: str = MODEL_NAME) -> str:
    payload = {
        "model": model,
        "prompt": prompt,
        "stream": False  # <- respuesta en un único JSON
    }
    url = f"{OLLAMA_BASE_URL}/api/generate"
    async with httpx.AsyncClient(timeout=120) as client:
        r = await client.post(url, json=payload)
        r.raise_for_status()
        data = r.json()
        text = data.get("response", "") if isinstance(data, dict) else r.text
        # Quita bloques de pensamiento de DeepSeek-R1
        return THINK_TAGS_RE.sub("", text).strip()


# ---- Endpoints ----
@app.post("/v1/users", response_model=CreateUserResp)
async def create_user():
    user_id = str(uuid.uuid4())
    with engine.begin() as conn:
        conn.execute(text("INSERT INTO users(id) VALUES(:id)"), {"id": user_id})
    return {"user_id": user_id}

@app.post("/v1/views")
async def add_view(v: ViewIn):
    with engine.begin() as conn:
        conn.execute(text(
            """
            INSERT INTO views(user_id,item_id,media_type,rating,watched_at)
            VALUES(:user_id,:item_id,:media_type,:rating,COALESCE(:watched_at, NOW()))
            ON CONFLICT (user_id,item_id,media_type) DO UPDATE
            SET rating=EXCLUDED.rating, watched_at=EXCLUDED.watched_at
            """
        ), v.model_dump())
    return {"ok": True}

@app.get("/v1/search")
async def search(q: str, type: str = "multi"):
    if type == "movie":
        data = await tmdb_get("/search/movie", {"query": q})
    elif type == "tv":
        data = await tmdb_get("/search/tv", {"query": q})
    else:
        data = await tmdb_get("/search/multi", {"query": q})
    return data

@app.get("/v1/items/{item_id}")
async def item_details(item_id: int, type: str = "movie"):
    path = f"/movie/{item_id}" if type == "movie" else f"/tv/{item_id}"
    details = await tmdb_get(path)
    return details

@app.get("/v1/recommendations", response_model=RecsOut)
async def recommendations(user_id: str, limit: int = 12, mood: Optional[str] = None):
    # 1) Candidatos rápidos desde TMDb (trending)
    trending = await tmdb_get("/trending/movie/week")
    pool = trending.get("results", [])[:200]

    # 2) Filtra ya vistos
    with engine.begin() as conn:
        seen = conn.execute(
            text("SELECT item_id FROM views WHERE user_id=:u AND media_type='movie'"),
            {"u": user_id}
        ).fetchall()
        seen_ids = {row[0] for row in seen}
    pool = [x for x in pool if x.get("id") not in seen_ids]

    # 3) (Opcional) Rerank por estado de ánimo con LLM
    if mood and pool:
        top_titles = [p.get("title") or p.get("name") or str(p.get("id")) for p in pool[:50]]
        prompt = (
            "Eres un sistema de re-ranking. Ordena esta lista de películas del 1 al 50 según el estado de ánimo: '"
            + mood
            + "'.\nDevuelve solo los títulos, uno por línea, en orden.\n\n"
            + "\n".join(top_titles)
        )
        try:
            response = await ollama_generate(prompt)
            order = [line.strip() for line in response.splitlines() if line.strip()]
            by_title = {(p.get("title") or p.get("name")): p for p in pool[:50]}
            reranked = [by_title[t] for t in order if t in by_title]
            pool = reranked + [p for p in pool if (p.get("title") or p.get("name")) not in order]
        except Exception:
            pass

    return {"results": pool[:limit]}

# ---- SSE: ejemplo simple ----
@app.get("/v1/events/stream")
async def event_stream(user_id: str):
    async def gen():
        while True:
            payload = {"type": "heartbeat", "ts": time.time(), "user_id": user_id}
            yield {"event": "heartbeat", "data": json.dumps(payload)}
            await asyncio.sleep(20)
    return EventSourceResponse(gen())

@app.get("/")
async def root():
    return {"ok": True, "service": "tmdb-recommender", "time": datetime.utcnow().isoformat()}

