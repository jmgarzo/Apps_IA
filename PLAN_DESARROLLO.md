# 🎬📺 PLAN DE DESARROLLO: SISTEMA DE RECOMENDACIONES PERSONALIZADO

## 📋 **RESUMEN EJECUTIVO**

**Objetivo:** Desarrollar un sistema de recomendaciones personalizado para películas y series que combine IA, datos de TMDb y aprendizaje del usuario.

**Servidor Actual:** Intel i7-14700KF, 32GB RAM, RTX 5060 Ti (16GB VRAM), 868GB SSD
**Capacidad Estimada:** 500-2,000 usuarios
**Costo de Migración:** €270-1,400/mes
**Tiempo de Migración:** 2-4 semanas

---

## 🎯 **FASES DE DESARROLLO**

### **FASE 1: DESARROLLO LOCAL (0-3 meses)**
- **Usuarios:** 10-50 (beta testing)
- **Costo:** €0 (servidor local)
- **Objetivo:** Validar producto y funcionalidades

### **FASE 2: MVP EN PRODUCCIÓN (3-6 meses)**
- **Usuarios:** 100-500
- **Costo:** €300-500/mes
- **Objetivo:** Crecimiento inicial y feedback

### **FASE 3: ESCALAMIENTO (6-12 meses)**
- **Usuarios:** 500-2,000
- **Costo:** €500-1,000/mes
- **Objetivo:** Monetización y optimización

### **FASE 4: CRECIMIENTO (12+ meses)**
- **Usuarios:** 2,000+
- **Costo:** €1,000+/mes
- **Objetivo:** Expansión y nuevas funcionalidades

---

## 🏗️ **ARQUITECTURA TÉCNICA**

### **BASE DE DATOS UNIFICADA**
```sql
CREATE TABLE content (
    id BIGINT PRIMARY KEY,
    title TEXT NOT NULL,
    overview TEXT,
    genres TEXT[],
    cast TEXT[],
    crew TEXT[],
    year INTEGER,
    rating FLOAT,
    content_type TEXT CHECK (content_type IN ('movie', 'tv')),
    
    -- Campos específicos de series
    seasons INTEGER,
    episodes INTEGER,
    status TEXT,
    episode_runtime INTEGER,
    
    -- Campos unificados
    embedding VECTOR(768),
    mood_tags TEXT[],
    popularity FLOAT,
    adult BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE user_profiles (
    user_id TEXT PRIMARY KEY,
    preferences JSONB,
    mood_history JSONB,
    content_embeddings VECTOR(768),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE user_interactions (
    id SERIAL PRIMARY KEY,
    user_id TEXT REFERENCES user_profiles(user_id),
    content_id BIGINT REFERENCES content(id),
    interaction_type TEXT, -- 'view', 'like', 'dislike', 'rating'
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    mood TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### **SERVICIOS DOCKER**
```yaml
# docker-compose.yml
services:
  ollama:
    image: ollama/ollama:latest
    container_name: ollama_r1
    restart: unless-stopped
    ports:
      - "11434:11434"
    volumes:
      - ollama:/root/.ollama
    environment:
      OLLAMA_HOST: 0.0.0.0
      NVIDIA_VISIBLE_DEVICES: all
      NVIDIA_DRIVER_CAPABILITIES: compute,utility
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]

  db:
    image: postgres:16
    container_name: tmdb_db
    restart: unless-stopped
    environment:
      POSTGRES_DB: tmdb
      POSTGRES_USER: tmdb
      POSTGRES_PASSWORD: tmdb
    volumes:
      - db-data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  api:
    build:
      context: ./server
      dockerfile: Dockerfile
    container_name: tmdb_api
    restart: unless-stopped
    environment:
      OLLAMA_BASE_URL: http://ollama:11434
      DATABASE_URL: postgresql+psycopg://tmdb:tmdb@db:5432/tmdb
    depends_on:
      - db
      - ollama
    ports:
      - "8080:8080"
    volumes:
      - ./server:/app

  redis:
    image: redis:7-alpine
    container_name: tmdb_redis
    restart: unless-stopped
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
```

---

## 🧠 **ALGORITMOS DE RECOMENDACIÓN**

### **1. CONTENT-BASED FILTERING**
```python
def content_based_recommendations(user_profile, content_type="both"):
    # Analizar características de películas/series
    # Calcular similitud basada en géneros, cast, crew, etc.
    # Usar embeddings para similitud semántica
    pass
```

### **2. COLLABORATIVE FILTERING**
```python
def collaborative_recommendations(user_id, content_type="both"):
    # "Usuarios similares a ti vieron X"
    # Matrix factorization o deep learning
    # Recomendaciones basadas en comportamiento
    pass
```

### **3. HÍBRIDO + LLM RERANKING**
```python
def hybrid_recommendations(user_profile, mood=None, content_type="both"):
    # 1. Content-based + Collaborative
    # 2. Combinar scores
    # 3. LLM reranking por mood/contexto
    # 4. Retornar recomendaciones finales
    pass
```

---

## 📊 **FUENTES DE DATOS**

### **DATASETS PRINCIPALES**
1. **TMDB 5000 Movie Dataset** (Kaggle) - Películas
2. **TMDB TV Dataset** (Kaggle) - Series
3. **MovieLens Dataset** - Ratings y preferencias
4. **TMDb API** - Datos actualizados en tiempo real

### **ENDPOINTS TMDb**
```python
# Películas
"/movie/popular"
"/movie/top_rated"
"/movie/trending/week"
"/search/movie"

# Series
"/tv/popular"
"/tv/top_rated"
"/tv/trending/week"
"/search/tv"

# Unificado
"/search/multi"
"/discover/movie"
"/discover/tv"
```

---

## 🎯 **FUNCIONALIDADES PRINCIPALES**

### **SISTEMA DE PERFILADO**
```python
# Cuestionario inicial (5-7 preguntas)
questions = [
    "¿Prefieres películas o series?",
    "¿Cuáles son tus 3 géneros favoritos?",
    "¿Prefieres contenido reciente o clásico?",
    "¿Te gustan más los blockbusters o contenido independiente?",
    "¿Qué actores/directores te gustan?",
    "¿Prefieres contenido en español o subtitulado?",
    "¿Qué estado de ánimo buscas?",
    "¿Prefieres series cortas o largas?",
    "¿Te gustan las series que ya terminaron o las que están en emisión?"
]
```

### **SISTEMA DE RECOMENDACIONES**
- **Recomendaciones por estado de ánimo**
- **Recomendaciones basadas en historial**
- **Recomendaciones híbridas (películas + series)**
- **Aprendizaje continuo del usuario**
- **Filtros avanzados**

### **INTERFAZ DE USUARIO**
- **Cuestionario inicial inteligente**
- **Dashboard personalizado**
- **Sistema de ratings y feedback**
- **Historial de visualizaciones**
- **Recomendaciones en tiempo real**

---

## 🚀 **ROADMAP DE IMPLEMENTACIÓN**

### **SEMANA 1-2: BASE DE DATOS Y DATOS**
- [ ] Configurar base de datos PostgreSQL
- [ ] Descargar y procesar dataset de Kaggle
- [ ] Implementar carga de datos desde TMDb API
- [ ] Crear sistema de embeddings
- [ ] Configurar Redis para cache

### **SEMANA 3-4: ALGORITMOS BÁSICOS**
- [ ] Implementar content-based filtering
- [ ] Implementar collaborative filtering
- [ ] Crear sistema de perfilado de usuario
- [ ] Implementar cuestionario inicial
- [ ] Crear sistema de ratings

### **SEMANA 5-6: INTEGRACIÓN LLM**
- [ ] Integrar DeepSeek-R1 para reranking
- [ ] Implementar recomendaciones por mood
- [ ] Crear sistema de aprendizaje continuo
- [ ] Optimizar prompts para el modelo
- [ ] Implementar cache inteligente

### **SEMANA 7-8: INTERFAZ Y OPTIMIZACIÓN**
- [ ] Crear API REST completa
- [ ] Implementar sistema de logs
- [ ] Optimizar rendimiento
- [ ] Crear documentación
- [ ] Pruebas de carga

### **SEMANA 9-12: TESTING Y REFINAMIENTO**
- [ ] Testing con usuarios beta
- [ ] Refinamiento de algoritmos
- [ ] Optimización de rendimiento
- [ ] Preparación para producción
- [ ] Documentación final

---

## 💰 **ANÁLISIS DE COSTOS**

### **DESARROLLO LOCAL (0-3 meses)**
- **Servidor:** €0 (tu hardware)
- **Electricidad:** €50-100/mes
- **Total:** €50-100/mes

### **PRODUCCIÓN BÁSICA (3-6 meses)**
- **Servidor Virtual:** €200-400/mes
- **Base de Datos:** €50-100/mes
- **CDN:** €20-50/mes
- **Total:** €270-550/mes

### **PRODUCCIÓN PREMIUM (6+ meses)**
- **Servidor Virtual:** €500-1,000/mes
- **Base de Datos:** €150-300/mes
- **CDN:** €50-100/mes
- **Total:** €700-1,400/mes

---

## 🔧 **HERRAMIENTAS Y TECNOLOGÍAS**

### **BACKEND**
- **Python 3.11+**
- **FastAPI** - API REST
- **PostgreSQL** - Base de datos principal
- **Redis** - Cache y sesiones
- **SQLAlchemy** - ORM
- **Pydantic** - Validación de datos

### **IA Y ML**
- **Ollama** - LLM local
- **DeepSeek-R1:14b** - Modelo de reranking
- **scikit-learn** - Algoritmos de ML
- **numpy/pandas** - Procesamiento de datos
- **sentence-transformers** - Embeddings

### **INFRAESTRUCTURA**
- **Docker** - Contenedores
- **Docker Compose** - Orquestación
- **NVIDIA Container Toolkit** - GPU
- **PostgreSQL** - Base de datos
- **Redis** - Cache

### **MONITOREO Y LOGS**
- **Prometheus** - Métricas
- **Grafana** - Dashboards
- **ELK Stack** - Logs
- **Health checks** - Monitoreo

---

## 📈 **MÉTRICAS DE ÉXITO**

### **TÉCNICAS**
- **Tiempo de respuesta:** < 2 segundos
- **Precisión de recomendaciones:** > 80%
- **Uptime:** > 99.5%
- **Usuarios concurrentes:** 100-200

### **DE NEGOCIO**
- **Usuarios activos:** 500-1,000
- **Sesiones por usuario:** > 3/semana
- **Tiempo en app:** > 10 minutos/sesión
- **Retención:** > 60% (30 días)

---

## 🎯 **PRÓXIMOS PASOS INMEDIATOS**

### **HOY**
1. [ ] Configurar permisos de Docker
2. [ ] Reiniciar API con logs
3. [ ] Probar sistema actual
4. [ ] Identificar problemas

### **ESTA SEMANA**
1. [ ] Descargar dataset de Kaggle
2. [ ] Configurar base de datos local
3. [ ] Implementar carga de datos
4. [ ] Crear sistema de embeddings

### **PRÓXIMA SEMANA**
1. [ ] Implementar content-based filtering
2. [ ] Crear sistema de perfilado
3. [ ] Integrar con LLM
4. [ ] Pruebas iniciales

---

## 📞 **CONTACTO Y SOPORTE**

**Desarrollador:** AI Assistant
**Proyecto:** Sistema de Recomendaciones Personalizado
**Repositorio:** /home/jmgarzo/Projects/kmp/TMDB+Deepseek
**Fecha de creación:** 20 de Septiembre de 2025

---

## 📝 **NOTAS ADICIONALES**

- **Backup:** Realizar backup diario de la base de datos
- **Logs:** Mantener logs detallados para debugging
- **Testing:** Implementar tests unitarios y de integración
- **Documentación:** Mantener documentación actualizada
- **Seguridad:** Implementar autenticación y autorización
- **Escalabilidad:** Diseñar para crecimiento horizontal

---

*Este plan es un documento vivo que se actualizará según el progreso del proyecto.*
