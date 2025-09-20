-- Esquema de base de datos para sistema de recomendaciones unificado
-- Películas y Series

-- Extensión para vectores (PostgreSQL con pgvector)
CREATE EXTENSION IF NOT EXISTS vector;

-- Tabla principal de contenido (películas y series)
CREATE TABLE IF NOT EXISTS content (
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
    status TEXT, -- 'ended', 'ongoing', 'cancelled'
    episode_runtime INTEGER,
    
    -- Campos unificados
    embedding VECTOR(768), -- Vector de características
    mood_tags TEXT[], -- Tags generados por LLM
    popularity FLOAT,
    adult BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabla de perfiles de usuario
CREATE TABLE IF NOT EXISTS user_profiles (
    user_id TEXT PRIMARY KEY,
    preferences JSONB, -- Preferencias del usuario
    mood_history JSONB, -- Historial de estados de ánimo
    content_embeddings VECTOR(768), -- Embedding del perfil del usuario
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabla de interacciones del usuario
CREATE TABLE IF NOT EXISTS user_interactions (
    id SERIAL PRIMARY KEY,
    user_id TEXT REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    content_id BIGINT REFERENCES content(id) ON DELETE CASCADE,
    interaction_type TEXT CHECK (interaction_type IN ('view', 'like', 'dislike', 'rating', 'skip')),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    mood TEXT, -- Estado de ánimo durante la interacción
    created_at TIMESTAMP DEFAULT NOW()
);

-- Tabla de recomendaciones generadas
CREATE TABLE IF NOT EXISTS recommendations (
    id SERIAL PRIMARY KEY,
    user_id TEXT REFERENCES user_profiles(user_id) ON DELETE CASCADE,
    content_id BIGINT REFERENCES content(id) ON DELETE CASCADE,
    score FLOAT, -- Score de recomendación
    algorithm TEXT, -- Algoritmo usado ('content-based', 'collaborative', 'hybrid')
    mood TEXT, -- Estado de ánimo considerado
    created_at TIMESTAMP DEFAULT NOW()
);

-- Tabla de embeddings de contenido
CREATE TABLE IF NOT EXISTS content_embeddings (
    content_id BIGINT PRIMARY KEY REFERENCES content(id) ON DELETE CASCADE,
    title_embedding VECTOR(768),
    overview_embedding VECTOR(768),
    genre_embedding VECTOR(768),
    cast_embedding VECTOR(768),
    combined_embedding VECTOR(768),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Índices para optimizar consultas
CREATE INDEX IF NOT EXISTS idx_content_type ON content(content_type);
CREATE INDEX IF NOT EXISTS idx_content_genres ON content USING GIN(genres);
CREATE INDEX IF NOT EXISTS idx_content_year ON content(year);
CREATE INDEX IF NOT EXISTS idx_content_rating ON content(rating);
CREATE INDEX IF NOT EXISTS idx_content_popularity ON content(popularity);

CREATE INDEX IF NOT EXISTS idx_user_interactions_user_id ON user_interactions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_interactions_content_id ON user_interactions(content_id);
CREATE INDEX IF NOT EXISTS idx_user_interactions_type ON user_interactions(interaction_type);
CREATE INDEX IF NOT EXISTS idx_user_interactions_created_at ON user_interactions(created_at);

CREATE INDEX IF NOT EXISTS idx_recommendations_user_id ON recommendations(user_id);
CREATE INDEX IF NOT EXISTS idx_recommendations_score ON recommendations(score);
CREATE INDEX IF NOT EXISTS idx_recommendations_algorithm ON recommendations(algorithm);

-- Índices para búsqueda vectorial
CREATE INDEX IF NOT EXISTS idx_content_embedding ON content USING ivfflat (embedding vector_cosine_ops);
CREATE INDEX IF NOT EXISTS idx_content_embeddings_combined ON content_embeddings USING ivfflat (combined_embedding vector_cosine_ops);

-- Función para actualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para actualizar updated_at
CREATE TRIGGER update_content_updated_at BEFORE UPDATE ON content
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Vista para estadísticas de contenido
CREATE OR REPLACE VIEW content_stats AS
SELECT 
    content_type,
    COUNT(*) as total_count,
    AVG(rating) as avg_rating,
    MIN(year) as min_year,
    MAX(year) as max_year,
    COUNT(CASE WHEN adult = true THEN 1 END) as adult_count
FROM content
GROUP BY content_type;

-- Vista para estadísticas de usuario
CREATE OR REPLACE VIEW user_stats AS
SELECT 
    up.user_id,
    COUNT(ui.id) as total_interactions,
    COUNT(CASE WHEN ui.interaction_type = 'like' THEN 1 END) as likes,
    COUNT(CASE WHEN ui.interaction_type = 'dislike' THEN 1 END) as dislikes,
    COUNT(CASE WHEN ui.interaction_type = 'rating' THEN 1 END) as ratings,
    AVG(ui.rating) as avg_rating,
    COUNT(DISTINCT ui.content_id) as unique_content_viewed
FROM user_profiles up
LEFT JOIN user_interactions ui ON up.user_id = ui.user_id
GROUP BY up.user_id;

-- Función para obtener recomendaciones por similitud
CREATE OR REPLACE FUNCTION get_similar_content(
    target_content_id BIGINT,
    limit_count INTEGER DEFAULT 10
)
RETURNS TABLE(
    content_id BIGINT,
    title TEXT,
    similarity FLOAT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.title,
        1 - (c.embedding <=> (SELECT embedding FROM content WHERE id = target_content_id)) as similarity
    FROM content c
    WHERE c.id != target_content_id
    AND c.embedding IS NOT NULL
    ORDER BY similarity DESC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Función para obtener recomendaciones por usuario
CREATE OR REPLACE FUNCTION get_user_recommendations(
    target_user_id TEXT,
    limit_count INTEGER DEFAULT 10,
    content_type_filter TEXT DEFAULT NULL
)
RETURNS TABLE(
    content_id BIGINT,
    title TEXT,
    content_type TEXT,
    score FLOAT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.title,
        c.content_type,
        r.score
    FROM recommendations r
    JOIN content c ON r.content_id = c.id
    WHERE r.user_id = target_user_id
    AND (content_type_filter IS NULL OR c.content_type = content_type_filter)
    ORDER BY r.score DESC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;
