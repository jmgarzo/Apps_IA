#!/bin/bash

# Script para configurar Ollama para usar GPU correctamente

echo "🚀 Configurando Ollama para usar GPU..."

# Ir al directorio del proyecto
cd /home/jmgarzo/Projects/kmp/TMDB+Deepseek/FastMCP+R1

echo "📋 1. Verificando estado actual de Ollama..."
docker exec ollama_r1 ollama list

echo "📋 2. Verificando variables de entorno de GPU..."
docker exec ollama_r1 env | grep -i gpu
docker exec ollama_r1 env | grep -i cuda

echo "📋 3. Verificando si Ollama detecta GPU..."
docker exec ollama_r1 ollama run deepseek-r1:14b "¿Estás usando GPU? Responde solo 'Sí' o 'No'"

echo "📋 4. Parando Ollama para reconfigurar..."
docker compose stop ollama

echo "📋 5. Eliminando contenedor Ollama..."
docker rm ollama_r1

echo "📋 6. Iniciando Ollama con configuración GPU..."
docker compose up -d ollama

echo "⏳ 7. Esperando que Ollama se inicie (30 segundos)..."
sleep 30

echo "📋 8. Verificando que Ollama está funcionando..."
docker logs ollama_r1 --tail 10

echo "📋 9. Verificando que el modelo está disponible..."
docker exec ollama_r1 ollama list

echo "📋 10. Probando generación con GPU..."
echo "Ejecutando: docker exec ollama_r1 ollama run deepseek-r1:14b 'Hola, ¿estás usando GPU?'"
docker exec ollama_r1 ollama run deepseek-r1:14b "Hola, ¿estás usando GPU? Responde solo 'Sí' o 'No'"

echo "📋 11. Verificando uso de GPU durante generación..."
echo "Monitorea nvidia-smi en otra terminal mientras se ejecuta:"
echo "docker exec ollama_r1 ollama run deepseek-r1:14b 'Recomiéndame una película de acción'"

echo "✅ Configuración de Ollama completada!"
echo ""
echo "🔍 Para verificar que funciona:"
echo "1. Ejecuta: nvidia-smi -l 1"
echo "2. En otra terminal: docker exec ollama_r1 ollama run deepseek-r1:14b 'Test'"
echo "3. Deberías ver uso de GPU en nvidia-smi"
