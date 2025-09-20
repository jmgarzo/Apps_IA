package com.jmgarzo.shared.data.api

import io.ktor.client.*
import io.ktor.client.engine.android.*

actual class HttpClientFactory {
    actual fun create(): HttpClient {
        return HttpClient(Android) {
            engine {
                connectTimeout = 30000 // 30 segundos
                socketTimeout = 180000 // 3 minutos
            }
        }
    }
}
