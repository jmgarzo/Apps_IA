#!/usr/bin/env python3
"""
Script para configurar la base de datos con el esquema unificado
"""

import os
import sys
from pathlib import Path
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError

# Agregar el directorio padre al path para imports
sys.path.append(str(Path(__file__).parent.parent))

# Configuración de base de datos
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql+psycopg://tmdb:tmdb@localhost:5432/tmdb")

def create_database_connection():
    """Crear conexión a la base de datos"""
    try:
        engine = create_engine(DATABASE_URL, pool_pre_ping=True)
        return engine
    except Exception as e:
        print(f"❌ Error conectando a la base de datos: {e}")
        return None

def load_schema():
    """Cargar esquema desde archivo SQL"""
    schema_file = Path(__file__).parent.parent / "database" / "schema.sql"
    
    if not schema_file.exists():
        print(f"❌ Archivo de esquema no encontrado: {schema_file}")
        return None
    
    try:
        with open(schema_file, 'r', encoding='utf-8') as f:
            schema_sql = f.read()
        return schema_sql
    except Exception as e:
        print(f"❌ Error leyendo esquema: {e}")
        return None

def execute_schema(engine, schema_sql):
    """Ejecutar esquema SQL"""
    try:
        with engine.begin() as conn:
            # Dividir el SQL en statements individuales
            statements = [stmt.strip() for stmt in schema_sql.split(';') if stmt.strip()]
            
            for i, statement in enumerate(statements):
                if statement:
                    print(f"📝 Ejecutando statement {i+1}/{len(statements)}...")
                    conn.execute(text(statement))
            
        print("✅ Esquema ejecutado correctamente")
        return True
    except SQLAlchemyError as e:
        print(f"❌ Error ejecutando esquema: {e}")
        return False

def verify_tables(engine):
    """Verificar que las tablas se crearon correctamente"""
    try:
        with engine.begin() as conn:
            # Verificar tablas principales
            tables = ['content', 'user_profiles', 'user_interactions', 'recommendations', 'content_embeddings']
            
            for table in tables:
                result = conn.execute(text(f"""
                    SELECT EXISTS (
                        SELECT FROM information_schema.tables 
                        WHERE table_name = '{table}'
                    );
                """))
                
                exists = result.scalar()
                if exists:
                    print(f"✅ Tabla '{table}' creada correctamente")
                else:
                    print(f"❌ Tabla '{table}' NO existe")
                    return False
            
            # Verificar extensiones
            result = conn.execute(text("""
                SELECT EXISTS (
                    SELECT FROM pg_extension 
                    WHERE extname = 'vector'
                );
            """))
            
            vector_exists = result.scalar()
            if vector_exists:
                print("✅ Extensión 'vector' instalada correctamente")
            else:
                print("⚠️  Extensión 'vector' no encontrada (necesaria para embeddings)")
            
            return True
            
    except Exception as e:
        print(f"❌ Error verificando tablas: {e}")
        return False

def create_sample_data(engine):
    """Crear datos de muestra para testing"""
    try:
        with engine.begin() as conn:
            # Insertar usuario de prueba
            conn.execute(text("""
                INSERT INTO user_profiles (user_id, preferences, mood_history)
                VALUES ('test_user', '{"genres": ["Action", "Comedy"], "content_type": "both"}', '{"happy": 5, "sad": 2}')
                ON CONFLICT (user_id) DO NOTHING;
            """))
            
            # Insertar contenido de prueba
            conn.execute(text("""
                INSERT INTO content (id, title, overview, genres, year, rating, content_type, popularity)
                VALUES 
                    (1, 'The Matrix', 'A computer hacker learns about the true nature of reality', ARRAY['Action', 'Sci-Fi'], 1999, 8.7, 'movie', 85.5),
                    (2, 'Breaking Bad', 'A high school chemistry teacher turned methamphetamine manufacturer', ARRAY['Drama', 'Crime'], 2008, 9.5, 'tv', 92.3),
                    (3, 'Inception', 'A thief who steals corporate secrets through dream-sharing technology', ARRAY['Action', 'Sci-Fi', 'Thriller'], 2010, 8.8, 'movie', 88.1)
                ON CONFLICT (id) DO NOTHING;
            """))
            
            print("✅ Datos de muestra creados")
            return True
            
    except Exception as e:
        print(f"❌ Error creando datos de muestra: {e}")
        return False

def main():
    """Función principal"""
    print("🚀 Configurando base de datos...")
    
    # Crear conexión
    engine = create_database_connection()
    if not engine:
        return False
    
    # Cargar esquema
    schema_sql = load_schema()
    if not schema_sql:
        return False
    
    # Ejecutar esquema
    if not execute_schema(engine, schema_sql):
        return False
    
    # Verificar tablas
    if not verify_tables(engine):
        return False
    
    # Crear datos de muestra
    create_sample_data(engine)
    
    print("\n✅ Base de datos configurada correctamente!")
    print("📊 Tablas creadas:")
    print("   - content (películas y series)")
    print("   - user_profiles (perfiles de usuario)")
    print("   - user_interactions (interacciones)")
    print("   - recommendations (recomendaciones)")
    print("   - content_embeddings (vectores)")
    
    return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
