#!/usr/bin/env python3
"""
Script para probar modelos alternativos de Ollama
"""

import requests
import time
import json
from typing import List, Dict, Any

# Configuración
OLLAMA_ORIGINAL = "http://localhost:11434"  # Puerto original
OLLAMA_TEST = "http://localhost:11435"      # Puerto de testing

def test_model_performance(ollama_url: str, model_name: str, test_prompts: List[str]) -> Dict[str, Any]:
    """Probar rendimiento de un modelo específico"""
    print(f"🤖 Probando modelo: {model_name}")
    print(f"🌐 URL: {ollama_url}")
    
    results = {
        "model": model_name,
        "url": ollama_url,
        "prompts": [],
        "total_time": 0,
        "avg_time": 0,
        "success_rate": 0
    }
    
    successful_tests = 0
    
    for i, prompt in enumerate(test_prompts, 1):
        print(f"  📝 Prompt {i}/{len(test_prompts)}: {prompt[:50]}...")
        
        try:
            payload = {
                "model": model_name,
                "prompt": prompt,
                "stream": False
            }
            
            start_time = time.time()
            response = requests.post(f"{ollama_url}/api/generate", json=payload, timeout=60)
            elapsed = time.time() - start_time
            
            if response.status_code == 200:
                data = response.json()
                response_text = data.get("response", "")
                
                result = {
                    "prompt": prompt,
                    "time": elapsed,
                    "success": True,
                    "response_length": len(response_text),
                    "response_preview": response_text[:100] + "..." if len(response_text) > 100 else response_text
                }
                
                successful_tests += 1
                print(f"    ✅ Completado en {elapsed:.2f}s")
            else:
                result = {
                    "prompt": prompt,
                    "time": elapsed,
                    "success": False,
                    "error": f"HTTP {response.status_code}",
                    "response_preview": response.text[:100]
                }
                print(f"    ❌ Error: {response.status_code}")
            
            results["prompts"].append(result)
            results["total_time"] += elapsed
            
        except Exception as e:
            result = {
                "prompt": prompt,
                "time": 0,
                "success": False,
                "error": str(e),
                "response_preview": ""
            }
            results["prompts"].append(result)
            print(f"    ❌ Excepción: {e}")
    
    # Calcular estadísticas
    results["success_rate"] = (successful_tests / len(test_prompts)) * 100
    results["avg_time"] = results["total_time"] / len(test_prompts) if test_prompts else 0
    
    return results

def test_ranking_performance(ollama_url: str, model_name: str) -> Dict[str, Any]:
    """Probar rendimiento específico para ranking de películas"""
    print(f"🎬 Probando ranking con {model_name}...")
    
    # Prompts específicos para ranking de películas
    ranking_prompts = [
        "Ordena estas películas según el estado de ánimo 'feliz': Matrix, Titanic, Inception, Toy Story, The Dark Knight",
        "Ordena estas películas según el estado de ánimo 'triste': Matrix, Titanic, Inception, Toy Story, The Dark Knight",
        "Ordena estas películas según el estado de ánimo 'acción': Matrix, Titanic, Inception, Toy Story, The Dark Knight",
        "Ordena estas películas según el estado de ánimo 'romance': Matrix, Titanic, Inception, Toy Story, The Dark Knight",
        "Ordena estas películas según el estado de ánimo 'comedia': Matrix, Titanic, Inception, Toy Story, The Dark Knight"
    ]
    
    return test_model_performance(ollama_url, model_name, ranking_prompts)

def check_ollama_status(ollama_url: str) -> bool:
    """Verificar si Ollama está funcionando"""
    try:
        response = requests.get(f"{ollama_url}/api/tags", timeout=5)
        if response.status_code == 200:
            models = response.json().get("models", [])
            print(f"✅ Ollama funcionando en {ollama_url}")
            print(f"📋 Modelos disponibles: {len(models)}")
            for model in models:
                print(f"   - {model.get('name', 'Unknown')}")
            return True
        else:
            print(f"❌ Ollama no responde en {ollama_url}: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error conectando a {ollama_url}: {e}")
        return False

def compare_models():
    """Comparar rendimiento entre modelos"""
    print("🚀 Iniciando comparación de modelos...")
    print("=" * 60)
    
    # Verificar estado de ambos Ollama
    print("\n1. 🔍 Verificando estado de Ollama...")
    original_ok = check_ollama_status(OLLAMA_ORIGINAL)
    test_ok = check_ollama_status(OLLAMA_TEST)
    
    if not original_ok:
        print("❌ Ollama original no está funcionando")
        return False
    
    if not test_ok:
        print("❌ Ollama de testing no está funcionando")
        return False
    
    # Probar modelo original
    print("\n2. 🎬 Probando modelo original (deepseek-r1:14b)...")
    original_results = test_ranking_performance(OLLAMA_ORIGINAL, "deepseek-r1:14b")
    
    # Probar modelo alternativo
    print("\n3. 🎬 Probando modelo alternativo (llama3.2:3b)...")
    test_results = test_ranking_performance(OLLAMA_TEST, "llama3.2:3b")
    
    # Comparar resultados
    print("\n4. 📊 Comparando resultados...")
    print("=" * 60)
    
    print(f"🔴 Modelo Original (deepseek-r1:14b):")
    print(f"   ⏱️  Tiempo promedio: {original_results['avg_time']:.2f}s")
    print(f"   ✅ Tasa de éxito: {original_results['success_rate']:.1f}%")
    print(f"   📝 Prompts exitosos: {sum(1 for p in original_results['prompts'] if p['success'])}/{len(original_results['prompts'])}")
    
    print(f"\n🟢 Modelo Alternativo (llama3.2:3b):")
    print(f"   ⏱️  Tiempo promedio: {test_results['avg_time']:.2f}s")
    print(f"   ✅ Tasa de éxito: {test_results['success_rate']:.1f}%")
    print(f"   📝 Prompts exitosos: {sum(1 for p in test_results['prompts'] if p['success'])}/{len(test_results['prompts'])}")
    
    # Calcular mejora
    if original_results['avg_time'] > 0 and test_results['avg_time'] > 0:
        speed_improvement = ((original_results['avg_time'] - test_results['avg_time']) / original_results['avg_time']) * 100
        print(f"\n🚀 Mejora de velocidad: {speed_improvement:.1f}%")
        
        if speed_improvement > 0:
            print(f"✅ El modelo alternativo es {speed_improvement:.1f}% más rápido")
        else:
            print(f"❌ El modelo alternativo es {abs(speed_improvement):.1f}% más lento")
    
    # Recomendación
    print("\n5. 💡 Recomendación:")
    if test_results['avg_time'] < original_results['avg_time'] and test_results['success_rate'] >= original_results['success_rate']:
        print("✅ RECOMENDADO: Migrar a llama3.2:3b")
        print("   - Más rápido")
        print("   - Misma o mejor tasa de éxito")
        print("   - Menos recursos computacionales")
    else:
        print("⚠️  CONSIDERAR: Mantener deepseek-r1:14b")
        print("   - Mejor calidad o tasa de éxito")
        print("   - Aunque sea más lento")
    
    return True

def main():
    """Función principal"""
    print("🎯 Testing de Modelos Alternativos para Sistema de Recomendaciones")
    print("=" * 70)
    
    success = compare_models()
    
    if success:
        print("\n✅ Comparación completada exitosamente!")
    else:
        print("\n❌ Error en la comparación")
    
    return success

if __name__ == "__main__":
    main()
