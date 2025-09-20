package com.jmgarzo.shared.di

import com.jmgarzo.shared.data.api.HttpClientFactory
import com.jmgarzo.shared.data.api.TmdbApiService
import com.jmgarzo.shared.data.api.createHttpClient
import com.jmgarzo.shared.data.repository.MovieRepository
import com.jmgarzo.shared.presentation.MovieViewModel

class AppModule {
    private val httpClientFactory = HttpClientFactory()
    private val httpClient = createHttpClient(httpClientFactory)
    private val apiService = TmdbApiService(httpClient)
    private val repository = MovieRepository(apiService)
    
    val movieViewModel: MovieViewModel = MovieViewModel(repository)
}
