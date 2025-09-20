#!/bin/bash

echo "🔍 Monitoreo de GPU para Ollama + Deepseek R1"
echo "============================================="

# Función para mostrar el estado de la GPU
show_gpu_status() {
    echo "📊 Estado de la GPU:"
    nvidia-smi --query-gpu=name,utilization.gpu,memory.used,memory.total,temperature.gpu --format=csv,noheader,nounits | while read line; do
        echo "   GPU: $line"
    done
    echo ""
}

# Función para verificar si Ollama está usando la GPU
check_ollama_gpu() {
    echo "🤖 Verificando Ollama:"
    if sudo docker ps | grep -q ollama_r1; then
        echo "   ✅ Contenedor Ollama ejecutándose"
        
        # Verificar si el modelo está cargado
        if sudo docker exec ollama_r1 ollama list | grep -q deepseek-r1; then
            echo "   ✅ Modelo deepseek-r1 cargado"
        else
            echo "   ⚠️  Modelo deepseek-r1 no encontrado"
        fi
        
        # Mostrar estadísticas del contenedor
        echo "   📈 Estadísticas del contenedor:"
        sudo docker stats ollama_r1 --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
    else
        echo "   ❌ Contenedor Ollama no está ejecutándose"
    fi
    echo ""
}

# Función para probar una inferencia
test_inference() {
    echo "🧪 Probando inferencia con Deepseek R1:"
    echo "   Pregunta: '¿Cuál es la capital de España?'"
    
    start_time=$(date +%s)
    echo "¿Cuál es la capital de España?" | sudo docker exec -i ollama_r1 ollama run deepseek-r1:14b --verbose 2>/dev/null | head -3
    end_time=$(date +%s)
    
    duration=$((end_time - start_time))
    echo "   ⏱️  Tiempo de respuesta: ${duration} segundos"
    
    if [ $duration -lt 10 ]; then
        echo "   ✅ Respuesta rápida - probablemente usando GPU"
    elif [ $duration -lt 30 ]; then
        echo "   ⚠️  Respuesta moderada - posiblemente usando GPU parcialmente"
    else
        echo "   ❌ Respuesta lenta - probablemente usando solo CPU"
    fi
    echo ""
}

# Función principal de monitoreo
monitor_loop() {
    while true; do
        clear
        echo "🔍 Monitoreo de GPU para Ollama + Deepseek R1"
        echo "============================================="
        echo "Presiona Ctrl+C para salir"
        echo ""
        
        show_gpu_status
        check_ollama_gpu
        
        echo "🔄 Actualizando en 5 segundos..."
        sleep 5
    done
}

# Verificar argumentos
case "${1:-monitor}" in
    "test")
        show_gpu_status
        check_ollama_gpu
        test_inference
        ;;
    "monitor")
        monitor_loop
        ;;
    *)
        echo "Uso: $0 [monitor|test]"
        echo "  monitor: Monitoreo continuo (por defecto)"
        echo "  test: Prueba única"
        ;;
esac

