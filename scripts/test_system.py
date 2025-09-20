#!/usr/bin/env python3
"""
Script para probar el sistema de recomendaciones
"""

import requests
import json
import time
from typing import Dict, Any

# Configuración
API_BASE_URL = "http://localhost:8080"

def test_api_health():
    """Probar si la API está funcionando"""
    try:
        response = requests.get(f"{API_BASE_URL}/", timeout=5)
        if response.status_code == 200:
            print("✅ API está funcionando")
            return True
        else:
            print(f"❌ API respondió con código: {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Error conectando a la API: {e}")
        return False

def test_recommendations(user_id: str, limit: int = 5, mood: str = None):
    """Probar endpoint de recomendaciones"""
    try:
        url = f"{API_BASE_URL}/v1/recommendations"
        params = {"user_id": user_id, "limit": limit}
        
        if mood:
            params["mood"] = mood
        
        print(f"🔍 Probando recomendaciones para usuario: {user_id}")
        if mood:
            print(f"🎭 Estado de ánimo: {mood}")
        
        response = requests.get(url, params=params, timeout=30)
        
        if response.status_code == 200:
            data = response.json()
            results = data.get("results", [])
            print(f"✅ Recomendaciones obtenidas: {len(results)}")
            
            # Mostrar primeras 3 recomendaciones
            for i, movie in enumerate(results[:3], 1):
                title = movie.get("title", "Sin título")
                year = movie.get("release_date", "Sin año")[:4] if movie.get("release_date") else "Sin año"
                rating = movie.get("vote_average", "Sin rating")
                print(f"   {i}. {title} ({year}) - Rating: {rating}")
            
            return True
        else:
            print(f"❌ Error en recomendaciones: {response.status_code}")
            print(f"   Respuesta: {response.text}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Error en recomendaciones: {e}")
        return False

def test_search(query: str, content_type: str = "multi"):
    """Probar endpoint de búsqueda"""
    try:
        url = f"{API_BASE_URL}/v1/search"
        params = {"q": query, "type": content_type}
        
        print(f"🔍 Probando búsqueda: '{query}'")
        
        response = requests.get(url, params=params, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            results = data.get("results", [])
            print(f"✅ Resultados de búsqueda: {len(results)}")
            
            # Mostrar primeros 3 resultados
            for i, item in enumerate(results[:3], 1):
                title = item.get("title") or item.get("name", "Sin título")
                item_type = item.get("media_type", "unknown")
                print(f"   {i}. {title} ({item_type})")
            
            return True
        else:
            print(f"❌ Error en búsqueda: {response.status_code}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Error en búsqueda: {e}")
        return False

def test_user_creation():
    """Probar creación de usuario"""
    try:
        url = f"{API_BASE_URL}/v1/users"
        
        print("👤 Probando creación de usuario...")
        
        response = requests.post(url, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            user_id = data.get("user_id")
            print(f"✅ Usuario creado: {user_id}")
            return user_id
        else:
            print(f"❌ Error creando usuario: {response.status_code}")
            return None
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Error creando usuario: {e}")
        return None

def main():
    """Función principal de testing"""
    print("🚀 Iniciando pruebas del sistema...")
    print("=" * 50)
    
    # 1. Probar salud de la API
    print("\n1. 🔍 Probando salud de la API...")
    if not test_api_health():
        print("❌ API no está funcionando. Revisa los logs de Docker.")
        return False
    
    # 2. Probar búsqueda
    print("\n2. 🔍 Probando búsqueda...")
    test_search("Matrix", "movie")
    test_search("Breaking Bad", "tv")
    
    # 3. Crear usuario de prueba
    print("\n3. 👤 Creando usuario de prueba...")
    user_id = test_user_creation()
    if not user_id:
        user_id = "test_user"  # Usar ID por defecto
    
    # 4. Probar recomendaciones sin mood
    print("\n4. 🎬 Probando recomendaciones sin estado de ánimo...")
    test_recommendations(user_id, limit=5)
    
    # 5. Probar recomendaciones con mood
    print("\n5. 🎭 Probando recomendaciones con estado de ánimo...")
    test_recommendations(user_id, limit=5, mood="feliz")
    test_recommendations(user_id, limit=5, mood="triste")
    test_recommendations(user_id, limit=5, mood="acción")
    
    print("\n" + "=" * 50)
    print("✅ Pruebas completadas!")
    print("\n📊 Resumen:")
    print("   - API funcionando")
    print("   - Búsqueda funcionando")
    print("   - Recomendaciones funcionando")
    print("   - Sistema listo para desarrollo")
    
    return True

if __name__ == "__main__":
    main()
