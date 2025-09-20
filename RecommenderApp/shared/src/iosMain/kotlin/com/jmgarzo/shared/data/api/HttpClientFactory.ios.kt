package com.jmgarzo.shared.data.api

import io.ktor.client.*
import io.ktor.client.engine.darwin.*

actual class HttpClientFactory {
    actual fun create(): HttpClient {
        return HttpClient(Darwin)
    }
}

