package com.jmgarzo.shared.data.models

import kotlinx.datetime.Instant
import kotlinx.serialization.Serializable

@Serializable
data class ViewRequest(
    val user_id: String,
    val item_id: Int,
    val media_type: String, // "movie" | "tv"
    val rating: Int? = null,
    val watched_at: Instant? = null
)

@Serializable
data class ViewResponse(
    val ok: Boolean
)

