#!/bin/bash

# Script para configurar entorno de testing de modelos alternativos

echo "🚀 Configurando entorno de testing para modelos alternativos..."

# Ir al directorio del proyecto
cd /home/jmgarzo/Projects/kmp/TMDB+Deepseek/FastMCP+R1

echo "📋 1. Verificando que el sistema original está funcionando..."
docker ps | grep ollama_r1

echo "📋 2. Iniciando contenedor de testing..."
docker compose -f docker-compose-test.yml up -d

echo "⏳ 3. Esperando que Ollama de testing se inicie (30 segundos)..."
sleep 30

echo "📋 4. Verificando estado de Ollama de testing..."
docker logs ollama_test --tail 10

echo "📋 5. Verificando que el modelo se descargó..."
docker exec ollama_test ollama list

echo "📋 6. Probando generación básica..."
docker exec ollama_test ollama run llama3.2:3b "Hola, ¿cómo estás?"

echo "📋 7. Verificando uso de GPU..."
nvidia-smi

echo "📋 8. Ejecutando comparación de modelos..."
cd /home/jmgarzo/Projects/kmp/TMDB+Deepseek/testing/llama3.2-3b
python3 test_alternative_models.py

echo "✅ Configuración de testing completada!"
echo ""
echo "🔍 Para ver logs en tiempo real:"
echo "  - Ollama original: docker logs -f ollama_r1"
echo "  - Ollama testing: docker logs -f ollama_test"
echo ""
echo "🧪 Para ejecutar comparación manual:"
echo "  python3 test_alternative_models.py"
