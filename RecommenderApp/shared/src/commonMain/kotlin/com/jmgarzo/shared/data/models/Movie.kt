package com.jmgarzo.shared.data.models

import kotlinx.serialization.Serializable

@Serializable
data class Movie(
    val id: Int,
    val title: String? = null,
    val name: String? = null, // Para TV shows
    val overview: String? = null,
    val poster_path: String? = null,
    val backdrop_path: String? = null,
    val release_date: String? = null,
    val first_air_date: String? = null, // Para TV shows
    val vote_average: Double? = null,
    val vote_count: Int? = null,
    val popularity: Double? = null,
    val genre_ids: List<Int>? = null,
    val adult: Boolean? = null,
    val video: Boolean? = null,
    val original_language: String? = null,
    val original_title: String? = null,
    val media_type: String? = null
) {
    val displayTitle: String
        get() = title ?: name ?: "Título no disponible"
    
    val displayDate: String?
        get() = release_date ?: first_air_date
    
    val fullPosterUrl: String?
        get() = poster_path?.let { "https://image.tmdb.org/t/p/w500$it" }
    
    val fullBackdropUrl: String?
        get() = backdrop_path?.let { "https://image.tmdb.org/t/p/w780$it" }
}

@Serializable
data class MovieSearchResponse(
    val page: Int,
    val results: List<Movie>,
    val total_pages: Int,
    val total_results: Int
)

@Serializable
data class RecommendationsResponse(
    val results: List<Movie>
)

