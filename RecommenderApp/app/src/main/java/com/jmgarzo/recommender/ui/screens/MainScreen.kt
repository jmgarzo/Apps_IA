package com.jmgarzo.recommender.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.jmgarzo.shared.presentation.MovieViewModel
import com.jmgarzo.recommender.ui.components.MoodSelector
import com.jmgarzo.recommender.ui.components.MovieCard
import com.jmgarzo.recommender.ui.components.SearchBar
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen(
    viewModel: MovieViewModel,
    modifier: Modifier = Modifier
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val currentUserId by viewModel.currentUserId.collectAsStateWithLifecycle()
    val scope = rememberCoroutineScope()
    
    // Inicializar usuario al cargar la pantalla
    LaunchedEffect(Unit) {
        if (currentUserId == null) {
            viewModel.createUser()
        }
    }
    
    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Text(
            text = "Recommender",
            style = MaterialTheme.typography.headlineLarge,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(bottom = 16.dp)
        )
        
        // Selector de estado de ánimo
        MoodSelector(
            selectedMood = uiState.selectedMood,
            onMoodSelected = { mood ->
                scope.launch {
                    viewModel.getRecommendations(mood)
                }
            },
            modifier = Modifier.padding(bottom = 16.dp)
        )
        
        // Barra de búsqueda
        SearchBar(
            onSearch = { query ->
                scope.launch {
                    viewModel.searchContent(query)
                }
            },
            modifier = Modifier.padding(bottom = 16.dp)
        )
        
        // Indicador de carga
        if (uiState.isLoading) {
            Box(
                modifier = Modifier.fillMaxWidth(),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator()
            }
        }
        
        // Mostrar error si existe
        uiState.error?.let { error ->
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 16.dp),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.errorContainer)
            ) {
                Text(
                    text = error,
                    modifier = Modifier.padding(16.dp),
                    color = MaterialTheme.colorScheme.onErrorContainer
                )
            }
        }
        
        // Lista de contenido
        LazyColumn(
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            // Mostrar recomendaciones si hay estado de ánimo seleccionado
            val selectedMood = uiState.selectedMood
            if (selectedMood != null && uiState.recommendations.isNotEmpty()) {
                item {
                    Text(
                        text = "Recomendaciones para: ${selectedMood.displayName}",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold,
                        modifier = Modifier.padding(vertical = 8.dp)
                    )
                }
                items(uiState.recommendations) { movie ->
                    MovieCard(
                        movie = movie,
                        onMarkAsWatched = { rating ->
                            scope.launch {
                                viewModel.addMovieToWatched(movie, rating)
                            }
                        }
                    )
                }
            }
            
            // Mostrar resultados de búsqueda si existen
            if (uiState.searchResults.isNotEmpty()) {
                item {
                    Text(
                        text = "Resultados de búsqueda",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold,
                        modifier = Modifier.padding(vertical = 8.dp)
                    )
                }
                items(uiState.searchResults) { movie ->
                    MovieCard(
                        movie = movie,
                        onMarkAsWatched = { rating ->
                            scope.launch {
                                viewModel.addMovieToWatched(movie, rating)
                            }
                        }
                    )
                }
            }
            
            // Mensaje cuando no hay contenido
            if (!uiState.isLoading && 
                selectedMood == null && 
                uiState.searchResults.isEmpty() && 
                uiState.error == null) {
                item {
                    Card(
                        modifier = Modifier.fillMaxWidth(),
                        colors = CardDefaults.cardColors(
                            containerColor = MaterialTheme.colorScheme.surfaceVariant
                        )
                    ) {
                        Text(
                            text = "Selecciona un estado de ánimo para obtener recomendaciones personalizadas",
                            modifier = Modifier.padding(16.dp),
                            style = MaterialTheme.typography.bodyLarge
                        )
                    }
                }
            }
        }
    }
}
