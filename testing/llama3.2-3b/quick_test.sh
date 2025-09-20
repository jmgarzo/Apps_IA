#!/bin/bash

# Script de testing rápido para Llama 3.2 3B

echo "🚀 Testing rápido: Llama 3.2 3B vs DeepSeek-R1 14B"
echo "=" * 50

# Ir al directorio del testing
cd /home/jmgarzo/Projects/kmp/TMDB+Deepseek/testing/llama3.2-3b

echo "📋 1. Verificando que el sistema original está funcionando..."
if docker ps | grep -q ollama_r1; then
    echo "✅ Sistema original funcionando"
else
    echo "❌ Sistema original no está funcionando"
    echo "   Ejecuta: cd /home/jmgarzo/Projects/kmp/TMDB+Deepseek/FastMCP+R1 && docker compose up -d"
    exit 1
fi

echo "📋 2. Iniciando contenedor de testing..."
docker compose -f docker-compose-test.yml up -d

echo "⏳ 3. Esperando que se descargue el modelo (60 segundos)..."
sleep 60

echo "📋 4. Verificando estado..."
docker logs ollama_test --tail 5

echo "📋 5. Ejecutando comparación..."
python3 test_alternative_models.py

echo "✅ Testing completado!"
echo ""
echo "🧹 Para limpiar:"
echo "  docker compose -f docker-compose-test.yml down"
