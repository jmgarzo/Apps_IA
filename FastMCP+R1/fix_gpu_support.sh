#!/bin/bash

echo "🔧 Diagnóstico y solución para soporte de GPU en Docker + Ollama"
echo "=================================================================="

# Verificar si nvidia-smi funciona
echo "1. Verificando NVIDIA Driver..."
if command -v nvidia-smi &> /dev/null; then
    echo "✅ NVIDIA Driver encontrado"
    nvidia-smi --query-gpu=name,driver_version --format=csv,noheader,nounits
else
    echo "❌ NVIDIA Driver no encontrado. Instala los drivers de NVIDIA primero."
    exit 1
fi

# Verificar NVIDIA Container Toolkit
echo ""
echo "2. Verificando NVIDIA Container Toolkit..."
if command -v nvidia-container-runtime &> /dev/null; then
    echo "✅ NVIDIA Container Runtime encontrado"
else
    echo "❌ NVIDIA Container Toolkit no encontrado"
    echo "📦 Instalando NVIDIA Container Toolkit..."
    
    # Instalar NVIDIA Container Toolkit
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    
    sudo apt-get update
    sudo apt-get install -y nvidia-container-toolkit
    
    # Configurar Docker para usar NVIDIA runtime
    sudo nvidia-ctk runtime configure --runtime=docker
    sudo systemctl restart docker
    
    echo "✅ NVIDIA Container Toolkit instalado y configurado"
fi

# Verificar configuración de Docker
echo ""
echo "3. Verificando configuración de Docker..."
if sudo docker info | grep -q "nvidia"; then
    echo "✅ Docker configurado para usar NVIDIA"
else
    echo "⚠️  Docker no parece estar configurado para NVIDIA"
    echo "🔄 Reiniciando Docker..."
    sudo systemctl restart docker
fi

# Probar acceso a GPU desde Docker
echo ""
echo "4. Probando acceso a GPU desde Docker..."
if sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi &> /dev/null; then
    echo "✅ Docker puede acceder a la GPU"
else
    echo "❌ Docker no puede acceder a la GPU"
    echo "🔧 Intentando solucionar..."
    
    # Agregar usuario al grupo docker si no está
    sudo usermod -aG docker $USER
    
    # Reiniciar Docker
    sudo systemctl restart docker
    
    echo "⚠️  Es posible que necesites reiniciar la sesión o el sistema"
fi

# Verificar si Ollama está usando GPU
echo ""
echo "5. Verificando uso de GPU en Ollama..."
if sudo docker ps | grep -q ollama; then
    echo "📊 Estado actual de Ollama:"
    sudo docker stats ollama_r1 --no-stream
    
    echo ""
    echo "🔍 Verificando si Ollama detecta la GPU..."
    if sudo docker exec ollama_r1 ollama list &> /dev/null; then
        echo "✅ Ollama está funcionando"
        
        # Verificar si el modelo está cargado
        if sudo docker exec ollama_r1 ollama list | grep -q deepseek-r1; then
            echo "✅ Modelo deepseek-r1 encontrado"
            
            # Probar una inferencia simple
            echo "🧪 Probando inferencia con GPU..."
            echo "¿Cuál es la capital de España?" | sudo docker exec -i ollama_r1 ollama run deepseek-r1:14b --verbose
        else
            echo "⚠️  Modelo deepseek-r1 no encontrado. Descargando..."
            sudo docker exec ollama_r1 ollama pull deepseek-r1:14b
        fi
    else
        echo "❌ Ollama no está funcionando correctamente"
    fi
else
    echo "⚠️  Contenedor de Ollama no está ejecutándose"
    echo "🚀 Iniciando servicios..."
    sudo docker compose up -d
fi

echo ""
echo "🎯 Resumen:"
echo "- Si ves 'GPU-Util' > 0% en nvidia-smi, la GPU está siendo usada"
echo "- Si Ollama responde rápidamente, está usando la GPU"
echo "- Si Ollama es lento, está usando solo CPU"
echo ""
echo "💡 Para monitorear el uso de GPU en tiempo real:"
echo "   watch -n 1 nvidia-smi"

