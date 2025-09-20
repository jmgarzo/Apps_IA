package com.jmgarzo.shared.data.api

import com.jmgarzo.shared.data.models.*
import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.request.*
import io.ktor.http.*

class TmdbApiService(private val httpClient: HttpClient) {
    
    /**
     * Crea un nuevo usuario
     */
    suspend fun createUser(): Result<CreateUserResponse> {
        return try {
            val response = httpClient.post("${ApiConfig.FULL_BASE_URL}${ApiConfig.Endpoints.USERS}")
            Result.success(response.body<CreateUserResponse>())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    /**
     * Añade una vista/rating de una película
     */
    suspend fun addView(viewRequest: ViewRequest): Result<ViewResponse> {
        return try {
            val response = httpClient.post("${ApiConfig.FULL_BASE_URL}${ApiConfig.Endpoints.VIEWS}") {
                contentType(ContentType.Application.Json)
                setBody(viewRequest)
            }
            Result.success(response.body<ViewResponse>())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    /**
     * Busca películas/series
     */
    suspend fun searchContent(query: String, type: String = "multi"): Result<MovieSearchResponse> {
        return try {
            val response = httpClient.get("${ApiConfig.FULL_BASE_URL}${ApiConfig.Endpoints.SEARCH}") {
                parameter("q", query)
                parameter("type", type)
            }
            Result.success(response.body<MovieSearchResponse>())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    /**
     * Obtiene detalles de una película/serie específica
     */
    suspend fun getItemDetails(itemId: Int, type: String = "movie"): Result<Movie> {
        return try {
            val response = httpClient.get("${ApiConfig.FULL_BASE_URL}${ApiConfig.Endpoints.ITEMS}/$itemId") {
                parameter("type", type)
            }
            Result.success(response.body<Movie>())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    /**
     * Obtiene recomendaciones basadas en el estado de ánimo del usuario
     */
    suspend fun getRecommendations(
        userId: String, 
        limit: Int = 12, 
        mood: String? = null
    ): Result<RecommendationsResponse> {
        return try {
            val response = httpClient.get("${ApiConfig.FULL_BASE_URL}${ApiConfig.Endpoints.RECOMMENDATIONS}") {
                parameter("user_id", userId)
                parameter("limit", limit)
                mood?.let { parameter("mood", it) }
            }
            Result.success(response.body<RecommendationsResponse>())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    /**
     * Verifica si el servicio está disponible
     */
    suspend fun healthCheck(): Result<Map<String, Any>> {
        return try {
            val response = httpClient.get(ApiConfig.BASE_URL)
            Result.success(response.body<Map<String, Any>>())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}