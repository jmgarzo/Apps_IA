# Media Recomendator App

Una aplicación móvil en Kotlin Multiplatform que se conecta a un backend con Deepseek R1 y FastMCP para recomendar películas basadas en el estado de ánimo del usuario.

## Características

- **Kotlin Multiplatform**: Comparte código entre Android e iOS
- **Recomendaciones basadas en estado de ánimo**: Utiliza Deepseek R1 para personalizar recomendaciones
- **Integración con TMDB**: Acceso a la base de datos de películas de The Movie Database
- **UI moderna**: Interfaz construida con Jetpack Compose
- **Búsqueda de contenido**: Busca películas y series
- **Sistema de calificaciones**: Marca películas como vistas y califícalas

## Configuración del Backend

Antes de ejecutar la aplicación móvil, asegúrate de que el backend esté funcionando:

1. Navega al directorio del backend:
   ```bash
   cd ../FastMCP+R1
   ```

2. Crea un archivo `.env` con tus credenciales de TMDB:
   ```env
   TMDB_BEARER_TOKEN=tu_bearer_token_aqui
   # O alternativamente:
   # TMDB_API_KEY=tu_api_key_aqui
   TMDB_LANG=es-ES
   TMDB_REGION=ES
   ```

3. Inicia los servicios con Docker:
   ```bash
   docker-compose up -d
   ```

4. Verifica que el servicio esté funcionando:
   ```bash
   curl http://localhost:8080
   ```

## Configuración de la App Móvil

### Para Emulador Android

La aplicación está configurada para conectarse a `http://10.0.2.2:8080` (IP del host desde el emulador).

### Para Dispositivo Físico

Si quieres probar en un dispositivo físico, actualiza la IP en:
`shared/src/commonMain/kotlin/com/jmgarzo/shared/data/api/ApiConfig.kt`

Cambia `BASE_URL_LOCAL` por la IP de tu máquina donde corre Docker.

## Ejecutar la Aplicación

1. Abre el proyecto en Android Studio
2. Sincroniza el proyecto (Sync Now)
3. Ejecuta la aplicación en un emulador o dispositivo

## Uso de la Aplicación

1. **Inicialización**: La app crea automáticamente un usuario al iniciar
2. **Seleccionar estado de ánimo**: Usa los chips para seleccionar cómo te sientes
3. **Obtener recomendaciones**: Las recomendaciones aparecerán automáticamente
4. **Buscar contenido**: Usa la barra de búsqueda para encontrar películas específicas
5. **Calificar películas**: Toca una película para marcarla como vista y calificarla

## Estados de Ánimo Disponibles

- Feliz
- Triste
- Emocionado
- Relajado
- Romántico
- Con ganas de sustos
- Reflexivo
- Nostálgico
- Aventurero
- Con ganas de reír

## Arquitectura

### Módulo Shared (KMP)
- **Data Models**: Modelos de datos para User, Movie, Mood, etc.
- **API Service**: Cliente HTTP para comunicarse con el backend
- **Repository**: Patrón repository para encapsular la lógica de datos
- **ViewModel**: Lógica de presentación compartida

### Módulo App (Android)
- **UI Components**: Componentes de Compose reutilizables
- **Screens**: Pantallas de la aplicación
- **MainActivity**: Punto de entrada de la aplicación

## Próximos Pasos

- [ ] Implementar persistencia local del usuario
- [ ] Añadir soporte para iOS
- [ ] Implementar notificaciones push
- [ ] Añadir más filtros de búsqueda
- [ ] Implementar historial de recomendaciones

