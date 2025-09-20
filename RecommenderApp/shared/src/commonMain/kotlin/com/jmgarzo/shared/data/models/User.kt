package com.jmgarzo.shared.data.models

import kotlinx.serialization.Serializable

@Serializable
data class User(
    val userId: String
)

@Serializable
data class CreateUserResponse(
    val user_id: String
)

