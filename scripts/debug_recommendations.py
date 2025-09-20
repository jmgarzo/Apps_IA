#!/usr/bin/env python3
"""
Script para debuggear el sistema de recomendaciones
"""

import requests
import json
import time
from typing import Dict, Any

# Configuración
API_BASE_URL = "http://localhost:8080"
OLLAMA_URL = "http://localhost:11434"

def test_ollama_directly():
    """Probar Ollama directamente"""
    print("🤖 Probando Ollama directamente...")
    
    try:
        # Probar si Ollama responde
        response = requests.get(f"{OLLAMA_URL}/api/tags", timeout=10)
        if response.status_code == 200:
            models = response.json()
            print(f"✅ Ollama responde. Modelos disponibles: {len(models.get('models', []))}")
            
            for model in models.get('models', []):
                print(f"   - {model.get('name', 'Unknown')}")
            
            return True
        else:
            print(f"❌ Ollama no responde: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error conectando a Ollama: {e}")
        return False

def test_ollama_generate():
    """Probar generación con Ollama"""
    print("🤖 Probando generación con Ollama...")
    
    try:
        payload = {
            "model": "deepseek-r1:14b",
            "prompt": "Hola, ¿cómo estás?",
            "stream": False
        }
        
        start_time = time.time()
        response = requests.post(f"{OLLAMA_URL}/api/generate", json=payload, timeout=60)
        elapsed = time.time() - start_time
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Ollama generó respuesta en {elapsed:.2f}s")
            print(f"   Respuesta: {data.get('response', '')[:100]}...")
            return True
        else:
            print(f"❌ Error en generación: {response.status_code}")
            print(f"   Respuesta: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Error en generación: {e}")
        return False

def test_recommendations_with_timeout(user_id: str, mood: str, timeout: int = 60):
    """Probar recomendaciones con timeout personalizado"""
    print(f"🎭 Probando recomendaciones con mood '{mood}' (timeout: {timeout}s)...")
    
    try:
        url = f"{API_BASE_URL}/v1/recommendations"
        params = {"user_id": user_id, "limit": 5, "mood": mood}
        
        start_time = time.time()
        response = requests.get(url, params=params, timeout=timeout)
        elapsed = time.time() - start_time
        
        if response.status_code == 200:
            data = response.json()
            results = data.get("results", [])
            print(f"✅ Recomendaciones obtenidas en {elapsed:.2f}s: {len(results)}")
            
            for i, movie in enumerate(results[:3], 1):
                title = movie.get("title", "Sin título")
                print(f"   {i}. {title}")
            
            return True
        else:
            print(f"❌ Error en recomendaciones: {response.status_code}")
            print(f"   Respuesta: {response.text}")
            return False
    except requests.exceptions.Timeout:
        print(f"⏰ Timeout después de {timeout}s")
        return False
    except Exception as e:
        print(f"❌ Error en recomendaciones: {e}")
        return False

def test_api_health():
    """Probar salud de la API"""
    print("🔍 Probando salud de la API...")
    
    try:
        response = requests.get(f"{API_BASE_URL}/", timeout=5)
        if response.status_code == 200:
            print("✅ API está funcionando")
            return True
        else:
            print(f"❌ API respondió con código: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error conectando a la API: {e}")
        return False

def main():
    """Función principal de debug"""
    print("🚀 Iniciando debug del sistema...")
    print("=" * 60)
    
    # 1. Probar salud de la API
    print("\n1. 🔍 Probando salud de la API...")
    if not test_api_health():
        print("❌ API no está funcionando. Revisa los logs de Docker.")
        return False
    
    # 2. Probar Ollama directamente
    print("\n2. 🤖 Probando Ollama directamente...")
    if not test_ollama_directly():
        print("❌ Ollama no está funcionando. Revisa los logs de Ollama.")
        return False
    
    # 3. Probar generación con Ollama
    print("\n3. 🤖 Probando generación con Ollama...")
    if not test_ollama_generate():
        print("❌ Ollama no puede generar respuestas. Revisa la configuración.")
        return False
    
    # 4. Crear usuario de prueba
    print("\n4. 👤 Creando usuario de prueba...")
    try:
        response = requests.post(f"{API_BASE_URL}/v1/users", timeout=10)
        if response.status_code == 200:
            user_id = response.json().get("user_id")
            print(f"✅ Usuario creado: {user_id}")
        else:
            user_id = "test_user"
            print(f"⚠️  Usando usuario por defecto: {user_id}")
    except Exception as e:
        user_id = "test_user"
        print(f"⚠️  Usando usuario por defecto: {user_id}")
    
    # 5. Probar recomendaciones sin mood
    print("\n5. 🎬 Probando recomendaciones sin mood...")
    test_recommendations_with_timeout(user_id, None, 30)
    
    # 6. Probar recomendaciones con mood (timeout corto)
    print("\n6. 🎭 Probando recomendaciones con mood (timeout 30s)...")
    test_recommendations_with_timeout(user_id, "feliz", 30)
    
    # 7. Probar recomendaciones con mood (timeout largo)
    print("\n7. 🎭 Probando recomendaciones con mood (timeout 120s)...")
    test_recommendations_with_timeout(user_id, "feliz", 120)
    
    print("\n" + "=" * 60)
    print("✅ Debug completado!")
    
    return True

if __name__ == "__main__":
    main()
