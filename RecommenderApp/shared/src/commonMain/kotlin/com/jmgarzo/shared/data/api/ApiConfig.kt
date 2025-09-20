package com.jmgarzo.shared.data.api

object ApiConfig {
    // Para desarrollo local, usa la IP de tu máquina en lugar de localhost
    // Puedes cambiar esto por la IP real de tu máquina donde corre Docker
    private const val BASE_URL_LOCAL = "http://10.0.2.2:8080" // Para emulador Android
    private const val BASE_URL_DEVICE = "http://192.168.1.100:8080" // Para dispositivo físico - cambiar por tu IP
    
    // Por defecto usamos la configuración para emulador
    const val BASE_URL = BASE_URL_LOCAL
    
    const val API_VERSION = "v1"
    const val FULL_BASE_URL = "$BASE_URL/$API_VERSION"
    
    // Endpoints
    object Endpoints {
        const val USERS = "/users"
        const val VIEWS = "/views"
        const val SEARCH = "/search"
        const val ITEMS = "/items"
        const val RECOMMENDATIONS = "/recommendations"
        const val EVENTS_STREAM = "/events/stream"
    }
}

