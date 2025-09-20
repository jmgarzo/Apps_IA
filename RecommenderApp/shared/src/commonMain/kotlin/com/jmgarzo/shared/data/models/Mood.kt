package com.jmgarzo.shared.data.models

import kotlinx.serialization.Serializable

@Serializable
data class MoodRequest(
    val userId: String,
    val mood: String,
    val limit: Int = 12
)

// Enum para estados de ánimo predefinidos
enum class MoodType(val displayName: String, val description: String) {
    HAPPY("Feliz", "Me siento alegre y optimista"),
    SAD("Triste", "Me siento melancólico o nostálgico"),
    EXCITED("Emocionado", "Quiero algo con mucha acción y aventura"),
    RELAXED("Relajado", "Busco algo tranquilo y relajante"),
    ROMANTIC("Romántico", "Estoy de humor para algo romántico"),
    SCARED("Con ganas de sustos", "Quiero algo que me asuste"),
    THOUGHTFUL("Reflexivo", "Busco algo profundo e intelectual"),
    NOSTALGIC("Nostálgico", "Quiero recordar el pasado"),
    ADVENTUROUS("Aventurero", "Busco explorar nuevos mundos"),
    FUNNY("Con ganas de reír", "Necesito algo divertido y cómico");
    
    companion object {
        fun fromDisplayName(displayName: String): MoodType? {
            return values().find { it.displayName == displayName }
        }
    }
}

