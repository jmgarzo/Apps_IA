#!/bin/bash

echo "🔧 Solución Manual para GPU en Docker + Ollama"
echo "=============================================="
echo ""
echo "Ejecuta estos comandos uno por uno:"
echo ""

echo "1. Verificar estado actual de Docker:"
echo "   sudo systemctl status docker"
echo ""

echo "2. Reiniciar Docker para aplicar configuración de GPU:"
echo "   sudo systemctl restart docker"
echo ""

echo "3. Verificar que Docker puede acceder a la GPU:"
echo "   sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi"
echo ""

echo "4. Parar contenedores actuales (si están ejecutándose):"
echo "   sudo docker compose down"
echo ""

echo "5. Iniciar servicios con configuración de GPU mejorada:"
echo "   sudo docker compose -f docker-compose-gpu.yml up -d"
echo ""

echo "6. Verificar que Ollama esté usando la GPU:"
echo "   ./monitor_gpu.sh test"
echo ""

echo "7. Monitorear uso de GPU en tiempo real:"
echo "   watch -n 1 nvidia-smi"
echo ""

echo "🎯 Indicadores de éxito:"
echo "   ✅ Docker puede ejecutar nvidia-smi"
echo "   ✅ Ollama responde en < 10 segundos"
echo "   ✅ nvidia-smi muestra uso de GPU cuando Ollama procesa"
echo "   ✅ La app móvil no da timeouts"
echo ""

echo "📝 Notas importantes:"
echo "   - Si el paso 3 falla, reinicia la sesión de usuario"
echo "   - Si Ollama sigue siendo lento, verifica que el modelo esté cargado"
echo "   - La primera inferencia puede tardar más (carga del modelo)"
echo ""

echo "¿Quieres que ejecute estos comandos automáticamente? (y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "🚀 Ejecutando comandos automáticamente..."
    
    echo "1. Reiniciando Docker..."
    sudo systemctl restart docker
    sleep 2
    
    echo "2. Verificando acceso a GPU..."
    if sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi; then
        echo "✅ Docker puede acceder a la GPU"
    else
        echo "❌ Docker no puede acceder a la GPU. Reinicia la sesión."
        exit 1
    fi
    
    echo "3. Parando contenedores actuales..."
    sudo docker compose down 2>/dev/null || true
    
    echo "4. Iniciando servicios con GPU..."
    sudo docker compose -f docker-compose-gpu.yml up -d
    
    echo "5. Esperando que los servicios se inicien..."
    sleep 10
    
    echo "6. Verificando estado de Ollama..."
    ./monitor_gpu.sh test
    
    echo "✅ Configuración completada!"
else
    echo "📋 Ejecuta los comandos manualmente cuando estés listo."
fi

