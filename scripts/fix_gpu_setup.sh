#!/bin/bash

# Script para solucionar configuración de GPU de manera permanente

echo "🚀 Solucionando configuración de GPU..."

# Ir al directorio del proyecto
cd /home/jmgarzo/Projects/kmp/TMDB+Deepseek/FastMCP+R1

echo "📋 1. Verificando estado actual..."
docker ps -a

echo "📋 2. Parando contenedores..."
docker compose down

echo "📋 3. Iniciando Ollama..."
docker compose up -d ollama

echo "⏳ 4. Esperando que Ollama se inicie (30 segundos)..."
sleep 30

echo "📋 5. Verificando que Ollama está funcionando..."
docker logs ollama_r1 --tail 10

echo "📋 6. Descargando modelo deepseek-r1:14b..."
docker exec ollama_r1 ollama pull deepseek-r1:14b

echo "📋 7. Verificando que el modelo se descargó..."
docker exec ollama_r1 ollama list

echo "📋 8. Iniciando todos los servicios..."
docker compose up -d

echo "⏳ 9. Esperando que todos los servicios se inicien (60 segundos)..."
sleep 60

echo "📋 10. Verificando estado final..."
docker ps

echo "📋 11. Verificando uso de GPU..."
nvidia-smi

echo "📋 12. Probando recomendaciones..."
cd /home/jmgarzo/Projects/kmp/TMDB+Deepseek
python3 scripts/test_system.py

echo "✅ Configuración de GPU completada!"
