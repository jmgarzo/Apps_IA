#!/bin/bash

echo "🚀 Comandos para Solucionar GPU en Ollama"
echo "========================================="
echo ""
echo "Ejecuta estos comandos en tu terminal:"
echo ""

echo "1. Verificar estado actual:"
echo "   sudo docker ps"
echo ""

echo "2. Reiniciar Docker:"
echo "   sudo systemctl restart docker"
echo ""

echo "3. Verificar acceso a GPU:"
echo "   sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi"
echo ""

echo "4. Parar contenedores actuales:"
echo "   sudo docker compose down"
echo ""

echo "5. Iniciar con configuración de GPU:"
echo "   sudo docker compose -f docker-compose-gpu.yml up -d"
echo ""

echo "6. Verificar estado de servicios:"
echo "   sudo docker compose -f docker-compose-gpu.yml ps"
echo ""

echo "7. Probar Ollama:"
echo "   sudo docker exec ollama_r1 ollama list"
echo ""

echo "8. Descargar modelo si es necesario:"
echo "   sudo docker exec ollama_r1 ollama pull deepseek-r1:14b"
echo ""

echo "9. Probar inferencia:"
echo "   echo '¿Cuál es la capital de España?' | sudo docker exec -i ollama_r1 ollama run deepseek-r1:14b"
echo ""

echo "10. Monitorear GPU:"
echo "    watch -n 1 nvidia-smi"
echo ""

echo "🎯 Indicadores de éxito:"
echo "   ✅ Comando 3 muestra la GPU"
echo "   ✅ Comando 9 responde en < 10 segundos"
echo "   ✅ nvidia-smi muestra uso de GPU"
echo ""

echo "📝 Si el comando 3 falla:"
echo "   - Reinicia la sesión de usuario"
echo "   - O reinicia el sistema"
echo ""

echo "¿Quieres que intente ejecutar estos comandos automáticamente? (y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "🚀 Ejecutando comandos..."
    
    echo "1. Verificando estado actual..."
    sudo docker ps
    
    echo ""
    echo "2. Reiniciando Docker..."
    sudo systemctl restart docker
    sleep 3
    
    echo ""
    echo "3. Verificando acceso a GPU..."
    if sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi; then
        echo "✅ Docker puede acceder a la GPU"
        
        echo ""
        echo "4. Parando contenedores actuales..."
        sudo docker compose down 2>/dev/null || true
        
        echo ""
        echo "5. Iniciando con configuración de GPU..."
        sudo docker compose -f docker-compose-gpu.yml up -d
        
        echo ""
        echo "6. Esperando que se inicien los servicios..."
        sleep 15
        
        echo ""
        echo "7. Verificando estado de servicios..."
        sudo docker compose -f docker-compose-gpu.yml ps
        
        echo ""
        echo "8. Probando Ollama..."
        if sudo docker exec ollama_r1 ollama list; then
            echo "✅ Ollama está funcionando"
            
            echo ""
            echo "9. Verificando modelo deepseek-r1..."
            if sudo docker exec ollama_r1 ollama list | grep -q deepseek-r1; then
                echo "✅ Modelo deepseek-r1 ya está cargado"
            else
                echo "📥 Descargando modelo deepseek-r1..."
                sudo docker exec ollama_r1 ollama pull deepseek-r1:14b
            fi
            
            echo ""
            echo "10. Probando inferencia..."
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
        
    else
        echo "❌ Docker no puede acceder a la GPU"
        echo "🔄 Reinicia la sesión de usuario o el sistema"
    fi
else
    echo "📋 Ejecuta los comandos manualmente cuando estés listo."
fi

