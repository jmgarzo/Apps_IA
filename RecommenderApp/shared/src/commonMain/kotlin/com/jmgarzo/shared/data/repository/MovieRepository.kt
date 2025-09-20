package com.jmgarzo.shared.data.repository

import com.jmgarzo.shared.data.api.TmdbApiService
import com.jmgarzo.shared.data.models.*
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow

class MovieRepository(private val apiService: TmdbApiService) {
    
    /**
     * Crea un nuevo usuario y retorna su ID
     */
    suspend fun createUser(): Result<String> {
        return apiService.createUser().map { it.user_id }
    }
    
    /**
     * Busca contenido (películas/series) por query
     */
    suspend fun searchContent(query: String, type: String = "multi"): Result<List<Movie>> {
        return apiService.searchContent(query, type).map { it.results }
    }
    
    /**
     * Obtiene recomendaciones basadas en el estado de ánimo
     */
    suspend fun getRecommendations(userId: String, mood: String?, limit: Int = 12): Result<List<Movie>> {
        return apiService.getRecommendations(userId, limit, mood).map { it.results }
    }
    
    /**
     * Obtiene recomendaciones como Flow para UI reactiva
     */
    fun getRecommendationsFlow(userId: String, mood: String?, limit: Int = 12): Flow<Result<List<Movie>>> = flow {
        emit(getRecommendations(userId, mood, limit))
    }
    
    /**
     * Añade una vista/rating de una película
     */
    suspend fun addView(userId: String, itemId: Int, mediaType: String, rating: Int? = null): Result<Boolean> {
        val viewRequest = ViewRequest(
            user_id = userId,
            item_id = itemId,
            media_type = mediaType,
            rating = rating
        )
        return apiService.addView(viewRequest).map { it.ok }
    }
    
    /**
     * Obtiene detalles de una película/serie específica
     */
    suspend fun getMovieDetails(itemId: Int, type: String = "movie"): Result<Movie> {
        return apiService.getItemDetails(itemId, type)
    }
    
    /**
     * Verifica la conectividad con el servicio
     */
    suspend fun checkServiceHealth(): Result<Boolean> {
        return apiService.healthCheck().map { true }
    }
}

