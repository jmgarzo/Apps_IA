#!/bin/bash

echo "🚀 Solución Rápida para GPU en Ollama"
echo "====================================="

# Verificar si Docker puede acceder a la GPU
echo "1. Verificando acceso a GPU desde Docker..."
if sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi &>/dev/null; then
    echo "✅ Docker puede acceder a la GPU"
else
    echo "❌ Docker no puede acceder a la GPU"
    echo "🔄 Reiniciando Docker..."
    sudo systemctl restart docker
    sleep 3
    
    echo "🔄 Verificando nuevamente..."
    if sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi &>/dev/null; then
        echo "✅ Docker ahora puede acceder a la GPU"
    else
        echo "❌ Aún no funciona. Reinicia la sesión de usuario."
        exit 1
    fi
fi

# Parar contenedores actuales
echo ""
echo "2. Parando contenedores actuales..."
sudo docker compose down 2>/dev/null || true

# Iniciar con configuración de GPU
echo ""
echo "3. Iniciando servicios con soporte de GPU..."
sudo docker compose -f docker-compose-gpu.yml up -d

# Esperar a que se inicien
echo ""
echo "4. Esperando que los servicios se inicien..."
sleep 15

# Verificar estado
echo ""
echo "5. Verificando estado de los servicios..."
sudo docker compose -f docker-compose-gpu.yml ps

# Probar Ollama
echo ""
echo "6. Probando Ollama con GPU..."
if sudo docker exec ollama_r1 ollama list &>/dev/null; then
    echo "✅ Ollama está funcionando"
    
    # Verificar si el modelo está cargado
    if sudo docker exec ollama_r1 ollama list | grep -q deepseek-r1; then
        echo "✅ Modelo deepseek-r1 ya está cargado"
    else
        echo "📥 Descargando modelo deepseek-r1..."
        sudo docker exec ollama_r1 ollama pull deepseek-r1:14b
    fi
    
    # Probar inferencia
    echo ""
    echo "7. Probando inferencia con GPU..."
    echo "Pregunta: '¿Cuál es la capital de España?'"
    start_time=$(date +%s)
    echo "¿Cuál es la capital de España?" | sudo docker exec -i ollama_r1 ollama run deepseek-r1:14b 2>/dev/null | head -2
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    echo ""
    echo "⏱️  Tiempo de respuesta: ${duration} segundos"
    
    if [ $duration -lt 10 ]; then
        echo "✅ ¡Excelente! Ollama está usando la GPU correctamente"
    elif [ $duration -lt 30 ]; then
        echo "⚠️  Moderado. Ollama puede estar usando GPU parcialmente"
    else
        echo "❌ Lento. Ollama probablemente está usando solo CPU"
    fi
else
    echo "❌ Ollama no está funcionando correctamente"
fi

echo ""
echo "🎯 Para monitorear el uso de GPU:"
echo "   watch -n 1 nvidia-smi"
echo ""
echo "🎯 Para probar la app móvil:"
echo "   cd ../MediaRecomendatorApp && ./test_integration.sh"
