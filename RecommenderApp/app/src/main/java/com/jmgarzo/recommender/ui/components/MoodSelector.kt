package com.jmgarzo.recommender.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.jmgarzo.shared.data.models.MoodType

@Composable
fun MoodSelector(
    selectedMood: MoodType?,
    onMoodSelected: (MoodType?) -> Unit,
    modifier: Modifier = Modifier
) {
    Column(modifier = modifier) {
        Text(
            text = "¿Cómo te sientes hoy?",
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.SemiBold,
            modifier = Modifier.padding(bottom = 8.dp)
        )
        
        LazyRow(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            contentPadding = PaddingValues(horizontal = 4.dp)
        ) {
            // Opción para limpiar selección
            item {
                MoodChip(
                    mood = null,
                    isSelected = selectedMood == null,
                    onClick = { onMoodSelected(null) }
                )
            }
            
            // Chips para cada estado de ánimo
            items(MoodType.values().toList()) { mood ->
                MoodChip(
                    mood = mood,
                    isSelected = selectedMood == mood,
                    onClick = { onMoodSelected(mood) }
                )
            }
        }
    }
}

@Composable
private fun MoodChip(
    mood: MoodType?,
    isSelected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val chipColors = if (isSelected) {
        AssistChipDefaults.assistChipColors(
            containerColor = MaterialTheme.colorScheme.primary,
            labelColor = MaterialTheme.colorScheme.onPrimary
        )
    } else {
        AssistChipDefaults.assistChipColors()
    }
    
    AssistChip(
        onClick = onClick,
        label = {
            Text(
                text = mood?.displayName ?: "Todos",
                fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal
            )
        },
        colors = chipColors,
        modifier = modifier
    )
}
