package com.jmgarzo.recommender

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.compose.viewModel
import com.jmgarzo.recommender.ui.screens.MainScreen
import com.jmgarzo.recommender.ui.theme.RecommenderTheme
import com.jmgarzo.shared.di.AppModule

class MainActivity : ComponentActivity() {
    private val appModule = AppModule()
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            RecommenderTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    MainScreen(
                        viewModel = appModule.movieViewModel,
                        modifier = Modifier.padding(innerPadding)
                    )
                }
            }
        }
    }
}