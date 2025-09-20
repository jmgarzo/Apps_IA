# Configuración de GPU para Ollama + Deepseek R1

## 🚨 Problema Identificado

Si Ollama no está usando la GPU NVIDIA RTX 5060 Ti, las operaciones con Deepseek R1 serán extremadamente lentas y causarán timeouts en la aplicación móvil.

## 🔍 Diagnóstico

### 1. Verificar que la GPU esté disponible
```bash
nvidia-smi
```
Deberías ver tu RTX 5060 Ti listada.

### 2. Verificar si Docker puede acceder a la GPU
```bash
sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
```
Si esto falla, necesitas instalar NVIDIA Container Toolkit.

## 🛠️ Solución Paso a Paso

### Paso 1: Instalar NVIDIA Container Toolkit

```bash
# Agregar repositorio de NVIDIA
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# Instalar el toolkit
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# Configurar Docker
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

### Paso 2: Agregar tu usuario al grupo docker
```bash
sudo usermod -aG docker $USER
# Reinicia la sesión o ejecuta: newgrp docker
```

### Paso 3: Usar el script de diagnóstico
```bash
cd /home/jmgarzo/Projects/kmp/TMDB+Deepseek/FastMCP+R1
./fix_gpu_support.sh
```

### Paso 4: Reiniciar los servicios con configuración de GPU mejorada
```bash
# Parar servicios actuales
sudo docker compose down

# Usar la configuración mejorada
sudo docker compose -f docker-compose-gpu.yml up -d

# Verificar que Ollama esté usando la GPU
./monitor_gpu.sh test
```

## 📊 Monitoreo

### Verificar uso de GPU en tiempo real
```bash
# Monitoreo continuo
./monitor_gpu.sh monitor

# O usar nvidia-smi directamente
watch -n 1 nvidia-smi
```

### Indicadores de que está funcionando correctamente:
- ✅ `GPU-Util` > 0% cuando Ollama procesa
- ✅ `Memory-Usage` aumenta cuando se carga el modelo
- ✅ Respuestas de Deepseek R1 en < 10 segundos
- ✅ `nvidia-smi` muestra procesos de Docker usando la GPU

## 🐛 Solución de Problemas

### Si Docker no puede acceder a la GPU:
1. Verifica que NVIDIA Container Toolkit esté instalado
2. Reinicia Docker: `sudo systemctl restart docker`
3. Reinicia la sesión de usuario
4. Verifica permisos: `ls -la /dev/nvidia*`

### Si Ollama sigue siendo lento:
1. Verifica que el modelo esté cargado: `sudo docker exec ollama_r1 ollama list`
2. Descarga el modelo: `sudo docker exec ollama_r1 ollama pull deepseek-r1:14b`
3. Verifica logs: `sudo docker logs ollama_r1`

### Si la aplicación móvil sigue dando timeout:
1. Verifica que el backend esté funcionando: `curl http://localhost:8080`
2. Prueba recomendaciones: `curl "http://localhost:8080/v1/recommendations?user_id=test&mood=feliz"`
3. Si es lento, el problema es la GPU

## 🎯 Resultado Esperado

Una vez configurado correctamente:
- Ollama usará la GPU para procesar Deepseek R1
- Las recomendaciones serán rápidas (< 10 segundos)
- La aplicación móvil no dará timeouts
- `nvidia-smi` mostrará uso de GPU cuando se procesen recomendaciones

## 📝 Notas Adicionales

- La RTX 5060 Ti tiene 16GB de VRAM, suficiente para Deepseek R1 14B
- El modelo se carga en memoria GPU al primer uso
- Las inferencias posteriores serán más rápidas
- Si no hay suficiente VRAM, Ollama usará CPU automáticamente

