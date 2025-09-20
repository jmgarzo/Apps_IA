# TMDB + Deepseek R1 - Sistema de Recomendación de Películas

Un sistema completo de recomendación de películas que combina la API de TMDB con Deepseek R1 para generar recomendaciones personalizadas basadas en el estado de ánimo del usuario.

## 🏗️ Arquitectura del Proyecto

```
TMDB+Deepseek/
├── FastMCP+R1/              # Backend con Docker
│   ├── server/              # API FastAPI + FastMCP
│   ├── docker-compose.yml   # Configuración Docker
│   └── .gitignore          # Gitignore para backend
├── MediaRecomendatorApp/    # App móvil KMP
│   ├── app/                 # Módulo Android
│   ├── shared/              # Módulo compartido KMP
│   └── .gitignore          # Gitignore para KMP
└── .gitignore              # Gitignore raíz
```

## 🚀 Componentes

### Backend (FastMCP+R1)
- **FastAPI**: API REST para recomendaciones
- **Deepseek R1**: Modelo de IA para personalización
- **TMDB API**: Base de datos de películas
- **PostgreSQL**: Base de datos de usuarios y vistas
- **Docker**: Contenedores con soporte GPU

### Frontend (MediaRecomendatorApp)
- **Kotlin Multiplatform**: Código compartido Android/iOS
- **Jetpack Compose**: UI moderna para Android
- **Ktor Client**: Cliente HTTP para backend
- **Material Design 3**: Diseño moderno

## 🛠️ Tecnologías

### Backend
- Python 3.11+
- FastAPI 0.115+
- FastMCP 2.0+
- Deepseek R1 14B
- PostgreSQL 16
- Docker + Docker Compose
- NVIDIA Container Toolkit

### Frontend
- Kotlin 2.0+
- Kotlin Multiplatform
- Jetpack Compose
- Ktor Client 3.0+
- Material Design 3
- Coil (carga de imágenes)

## 📋 Requisitos del Sistema

### Hardware
- **GPU NVIDIA** (RTX 5060 Ti o superior recomendada)
- **16GB+ RAM** (para Deepseek R1 14B)
- **50GB+ espacio libre** (para modelos y datos)

### Software
- **Ubuntu 22.04+** (o distribución Linux compatible)
- **Docker 24+** con soporte GPU
- **NVIDIA Driver 580+**
- **NVIDIA Container Toolkit**
- **Android Studio** (para desarrollo móvil)

## 🚀 Instalación y Configuración

### 1. Backend (Docker + GPU)

```bash
cd FastMCP+R1

# Instalar NVIDIA Container Toolkit
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# Configurar variables de entorno
cp .env.example .env
# Editar .env con tus credenciales de TMDB

# Iniciar servicios
sudo docker compose -f docker-compose-gpu.yml up -d

# Verificar que Ollama use GPU
sudo docker exec ollama_r1 ollama list
echo '¿Cuál es la capital de España?' | sudo docker exec -i ollama_r1 ollama run deepseek-r1:14b
```

### 2. Frontend (Kotlin Multiplatform)

```bash
cd MediaRecomendatorApp

# Sincronizar proyecto
./gradlew build

# Ejecutar en Android
./gradlew :app:assembleDebug
```

## 🧪 Pruebas

### Backend
```bash
cd FastMCP+R1
./test_integration.sh
```

### Frontend
```bash
cd MediaRecomendatorApp
./test_integration.sh
```

## 📱 Uso de la Aplicación

1. **Seleccionar estado de ánimo**: Usa los chips para indicar cómo te sientes
2. **Obtener recomendaciones**: Las películas aparecerán automáticamente
3. **Buscar contenido**: Usa la barra de búsqueda para encontrar películas específicas
4. **Calificar películas**: Toca una película para marcarla como vista y calificarla

## 🔧 Configuración Avanzada

### GPU
- Verificar uso: `watch -n 1 nvidia-smi`
- Monitorear Ollama: `./monitor_gpu.sh`

### API
- Documentación: `http://localhost:8080/docs`
- Health check: `http://localhost:8080`

### Base de datos
- Host: `localhost:5432`
- Database: `tmdb`
- Usuario: `tmdb`

## 🐛 Solución de Problemas

### GPU no funciona
1. Verificar drivers NVIDIA: `nvidia-smi`
2. Verificar Docker GPU: `sudo docker run --rm --gpus all ubuntu:22.04 nvidia-smi`
3. Reiniciar Docker: `sudo systemctl restart docker`

### Timeouts en app móvil
1. Verificar backend: `curl http://localhost:8080`
2. Verificar GPU: `nvidia-smi` (debe mostrar uso)
3. Verificar Ollama: `sudo docker exec ollama_r1 ollama list`

### Recomendaciones lentas
1. Verificar que Ollama use GPU
2. Verificar que el modelo esté cargado
3. Verificar logs: `sudo docker logs ollama_r1`

## 📊 Rendimiento

### Con GPU (RTX 5060 Ti)
- **Recomendaciones**: < 10 segundos
- **Búsquedas**: < 2 segundos
- **VRAM usada**: ~14GB

### Sin GPU (solo CPU)
- **Recomendaciones**: 2-5 minutos
- **Búsquedas**: < 2 segundos
- **RAM usada**: ~8GB

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama: `git checkout -b feature/nueva-funcionalidad`
3. Commit cambios: `git commit -m 'Agregar nueva funcionalidad'`
4. Push a la rama: `git push origin feature/nueva-funcionalidad`
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver `LICENSE` para más detalles.

## 🙏 Agradecimientos

- **TMDB** por la API de películas
- **Deepseek** por el modelo R1
- **FastMCP** por la integración
- **Kotlin Multiplatform** por el framework móvil
