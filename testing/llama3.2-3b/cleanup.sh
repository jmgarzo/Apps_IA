#!/bin/bash

# Script de limpieza para el entorno de testing

echo "🧹 Limpiando entorno de testing de Llama 3.2 3B..."

# Ir al directorio del testing
cd /home/jmgarzo/Projects/kmp/TMDB+Deepseek/testing/llama3.2-3b

echo "📋 1. Parando contenedores de testing..."
docker compose -f docker-compose-test.yml down

echo "📋 2. Eliminando contenedores de testing..."
docker rm ollama_test ollama-test-init 2>/dev/null || true

echo "📋 3. Eliminando volúmenes de testing..."
docker volume rm tmdb-deepseek-test_ollama-test 2>/dev/null || true

echo "📋 4. Verificando limpieza..."
echo "Contenedores de testing:"
docker ps -a | grep ollama_test || echo "  ✅ Ninguno encontrado"

echo "Volúmenes de testing:"
docker volume ls | grep ollama-test || echo "  ✅ Ninguno encontrado"

echo "✅ Limpieza completada!"
echo ""
echo "ℹ️  El sistema original sigue funcionando normalmente"
