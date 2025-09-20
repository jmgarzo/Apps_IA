# 🧪 Testing: Llama 3.2 3B

## 📋 **Descripción**

Este directorio contiene todos los archivos necesarios para probar el modelo **Llama 3.2 3B** como alternativa al modelo actual **DeepSeek-R1 14B** en el sistema de recomendaciones de películas.

## 🎯 **Objetivo**

Comparar el rendimiento entre:
- **Modelo actual:** DeepSeek-R1 14B (puerto 11434)
- **Modelo alternativo:** Llama 3.2 3B (puerto 11435)

## 📁 **Archivos**

- `docker-compose-test.yml` - Configuración Docker para el modelo de testing
- `test_alternative_models.py` - Script de comparación de rendimiento
- `setup_test_environment.sh` - Script de configuración automática
- `README.md` - Este archivo

## 🚀 **Uso Rápido**

### **1. Configurar entorno de testing**
```bash
cd /home/jmgarzo/Projects/kmp/TMDB+Deepseek/testing/llama3.2-3b
chmod +x setup_test_environment.sh
./setup_test_environment.sh
```

### **2. Ejecutar comparación manual**
```bash
python3 test_alternative_models.py
```

### **3. Ver logs en tiempo real**
```bash
# Ollama original (DeepSeek-R1 14B)
docker logs -f ollama_r1

# Ollama testing (Llama 3.2 3B)
docker logs -f ollama_test
```

## 📊 **Métricas de Comparación**

El script de testing compara:
- **Velocidad:** Tiempo de respuesta promedio
- **Calidad:** Tasa de éxito en tareas de ranking
- **Consistencia:** Estabilidad de las respuestas
- **Recursos:** Uso de GPU y memoria

## 🎬 **Tareas de Testing**

### **Prompts de Ranking:**
1. "Ordena estas películas según el estado de ánimo 'feliz': Matrix, Titanic, Inception, Toy Story, The Dark Knight"
2. "Ordena estas películas según el estado de ánimo 'triste': Matrix, Titanic, Inception, Toy Story, The Dark Knight"
3. "Ordena estas películas según el estado de ánimo 'acción': Matrix, Titanic, Inception, Toy Story, The Dark Knight"
4. "Ordena estas películas según el estado de ánimo 'romance': Matrix, Titanic, Inception, Toy Story, The Dark Knight"
5. "Ordena estas películas según el estado de ánimo 'comedia': Matrix, Titanic, Inception, Toy Story, The Dark Knight"

## 🔧 **Configuración**

### **Puertos:**
- **Original:** 11434 (DeepSeek-R1 14B)
- **Testing:** 11435 (Llama 3.2 3B)

### **Volúmenes:**
- **Original:** `ollama` (sistema principal)
- **Testing:** `ollama-test` (sistema de testing)

## 📈 **Resultados Esperados**

### **Llama 3.2 3B (Esperado):**
- **Velocidad:** 2-5 segundos (vs 30+ segundos)
- **Tamaño:** 3B parámetros (vs 14B)
- **Memoria:** ~6GB VRAM (vs ~12GB)
- **Calidad:** Buena para ranking simple

### **DeepSeek-R1 14B (Actual):**
- **Velocidad:** 30+ segundos
- **Tamaño:** 14B parámetros
- **Memoria:** ~12GB VRAM
- **Calidad:** Excelente para razonamiento complejo

## 🎯 **Criterios de Migración**

**Migrar a Llama 3.2 3B si:**
- ✅ Velocidad > 5x más rápido
- ✅ Tasa de éxito >= 90%
- ✅ Calidad de ranking aceptable
- ✅ Uso de recursos < 50%

**Mantener DeepSeek-R1 14B si:**
- ❌ Velocidad < 3x más rápido
- ❌ Tasa de éxito < 80%
- ❌ Calidad de ranking inaceptable
- ❌ Uso de recursos > 80%

## 🧹 **Limpieza**

### **Parar contenedores de testing:**
```bash
cd /home/jmgarzo/Projects/kmp/TMDB+Deepseek/testing/llama3.2-3b
docker compose -f docker-compose-test.yml down
```

### **Eliminar volúmenes de testing:**
```bash
docker volume rm tmdb-deepseek-test_ollama-test
```

## 📝 **Notas**

- El sistema original sigue funcionando durante las pruebas
- Los contenedores de testing son independientes
- Se pueden probar múltiples modelos en paralelo
- Los resultados se guardan en logs detallados

---

**Fecha de creación:** 20 de Septiembre de 2025  
**Modelo objetivo:** Llama 3.2 3B  
**Propósito:** Optimización de rendimiento del sistema de recomendaciones
