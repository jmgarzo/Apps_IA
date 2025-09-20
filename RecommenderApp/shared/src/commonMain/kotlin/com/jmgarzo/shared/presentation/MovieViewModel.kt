package com.jmgarzo.shared.presentation

import com.jmgarzo.shared.data.models.Movie
import com.jmgarzo.shared.data.models.MoodType
import com.jmgarzo.shared.data.repository.MovieRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class MovieViewModel(private val repository: MovieRepository) {
    
    private val _uiState = MutableStateFlow(MovieUiState())
    val uiState: StateFlow<MovieUiState> = _uiState.asStateFlow()
    
    private val _currentUserId = MutableStateFlow<String?>(null)
    val currentUserId: StateFlow<String?> = _currentUserId.asStateFlow()
    
    fun initializeUser() {
        // Si ya tenemos un usuario, no crear uno nuevo
        if (_currentUserId.value != null) return
        
        // TODO: En una app real, aquí deberías persistir el userId localmente
        // y cargarlo al inicializar la app
    }
    
    suspend fun createUser() {
        _uiState.value = _uiState.value.copy(isLoading = true, error = null)
        
        repository.createUser()
            .onSuccess { userId ->
                _currentUserId.value = userId
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    isUserCreated = true
                )
            }
            .onFailure { error ->
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    error = error.message ?: "Error desconocido"
                )
            }
    }
    
    suspend fun searchContent(query: String) {
        if (query.isBlank()) return
        
        _uiState.value = _uiState.value.copy(isLoading = true, error = null)
        
        repository.searchContent(query)
            .onSuccess { movies ->
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    searchResults = movies
                )
            }
            .onFailure { error ->
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    error = error.message ?: "Error en la búsqueda"
                )
            }
    }
    
    suspend fun getRecommendations(mood: MoodType?) {
        val userId = _currentUserId.value ?: return
        
        _uiState.value = _uiState.value.copy(isLoading = true, error = null)
        
        repository.getRecommendations(userId, mood?.name?.lowercase(), 12)
            .onSuccess { movies ->
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    recommendations = movies,
                    selectedMood = mood
                )
            }
            .onFailure { error ->
                val errorMessage = when {
                    error.message?.contains("timeout", ignoreCase = true) == true -> 
                        "El servidor está tardando más de lo esperado. Intenta de nuevo."
                    error.message?.contains("connect", ignoreCase = true) == true -> 
                        "No se puede conectar al servidor. Verifica tu conexión."
                    else -> error.message ?: "Error obteniendo recomendaciones"
                }
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    error = errorMessage
                )
            }
    }
    
    suspend fun addMovieToWatched(movie: Movie, rating: Int? = null) {
        val userId = _currentUserId.value ?: return
        
        repository.addView(userId, movie.id, "movie", rating)
            .onSuccess {
                // Actualizar la UI para reflejar que la película fue marcada como vista
                _uiState.value = _uiState.value.copy(
                    watchedMovies = _uiState.value.watchedMovies + movie.id
                )
            }
            .onFailure { error ->
                _uiState.value = _uiState.value.copy(
                    error = error.message ?: "Error marcando película como vista"
                )
            }
    }
    
    fun clearError() {
        _uiState.value = _uiState.value.copy(error = null)
    }
    
    fun clearSearchResults() {
        _uiState.value = _uiState.value.copy(searchResults = emptyList())
    }
}

data class MovieUiState(
    val isLoading: Boolean = false,
    val isUserCreated: Boolean = false,
    val recommendations: List<Movie> = emptyList(),
    val searchResults: List<Movie> = emptyList(),
    val selectedMood: MoodType? = null,
    val watchedMovies: Set<Int> = emptySet(),
    val error: String? = null
)
