#!/usr/bin/env python3
"""
Script para descargar datasets de películas y series
"""

import os
import requests
import zipfile
import pandas as pd
from pathlib import Path

# Configuración
DATA_DIR = Path(__file__).parent.parent / "data"
RAW_DIR = DATA_DIR / "raw"
PROCESSED_DIR = DATA_DIR / "processed"

# URLs de datasets (ejemplos - necesitarás las URLs reales)
DATASETS = {
    "tmdb_movies": {
        "url": "https://www.kaggle.com/datasets/tmdb/tmdb-movie-metadata/download",
        "filename": "tmdb_movies.zip",
        "description": "Dataset de películas de TMDb"
    },
    "tmdb_series": {
        "url": "https://www.kaggle.com/datasets/tmdb/tmdb-tv-series-metadata/download", 
        "filename": "tmdb_series.zip",
        "description": "Dataset de series de TMDb"
    }
}

def create_directories():
    """Crear directorios necesarios"""
    RAW_DIR.mkdir(parents=True, exist_ok=True)
    PROCESSED_DIR.mkdir(parents=True, exist_ok=True)
    print(f"✅ Directorios creados: {RAW_DIR}, {PROCESSED_DIR}")

def download_dataset(url, filename):
    """Descargar dataset desde URL"""
    filepath = RAW_DIR / filename
    
    if filepath.exists():
        print(f"⚠️  Archivo ya existe: {filename}")
        return filepath
    
    print(f"📥 Descargando: {filename}")
    try:
        response = requests.get(url, stream=True)
        response.raise_for_status()
        
        with open(filepath, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        
        print(f"✅ Descarga completada: {filename}")
        return filepath
    except Exception as e:
        print(f"❌ Error descargando {filename}: {e}")
        return None

def extract_zip(zip_path, extract_to):
    """Extraer archivo ZIP"""
    print(f"📦 Extrayendo: {zip_path.name}")
    try:
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(extract_to)
        print(f"✅ Extracción completada en: {extract_to}")
    except Exception as e:
        print(f"❌ Error extrayendo {zip_path.name}: {e}")

def process_movies_data():
    """Procesar datos de películas"""
    print("🎬 Procesando datos de películas...")
    # Aquí irá la lógica de procesamiento
    pass

def process_series_data():
    """Procesar datos de series"""
    print("📺 Procesando datos de series...")
    # Aquí irá la lógica de procesamiento
    pass

def main():
    """Función principal"""
    print("🚀 Iniciando descarga de datasets...")
    
    # Crear directorios
    create_directories()
    
    # Descargar datasets
    for name, config in DATASETS.items():
        print(f"\n📊 Procesando: {config['description']}")
        filepath = download_dataset(config['url'], config['filename'])
        
        if filepath:
            extract_zip(filepath, RAW_DIR)
    
    # Procesar datos
    process_movies_data()
    process_series_data()
    
    print("\n✅ Proceso completado!")

if __name__ == "__main__":
    main()
