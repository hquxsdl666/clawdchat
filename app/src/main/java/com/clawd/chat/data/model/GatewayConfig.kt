package com.clawd.chat.data.model

import kotlinx.serialization.Serializable

@Serializable
data class GatewayConfig(
    val host: String = "127.0.0.1",
    val port: Int = 18789,
    val useWss: Boolean = false,
    val authToken: String? = null,
    val connectionType: ConnectionType = ConnectionType.AUTO
) {
    fun getWebSocketUrl(): String {
        val protocol = if (useWss) "wss" else "ws"
        return "$protocol://$host:$port/ws"
    }
    
    fun getHttpUrl(): String {
        val protocol = if (useWss) "https" else "http"
        return "$protocol://$host:$port"
    }
}

enum class ConnectionType {
    AUTO,
    LOCAL_WIFI,
    TAILSCALE,
    CLOUDFLARE,
    MANUAL
}

@Serializable
data class ConnectionStatus(
    val state: ConnectionState = ConnectionState.DISCONNECTED,
    val latencyMs: Long? = null,
    val retryCount: Int = 0,
    val errorMessage: String? = null
)

enum class ConnectionState {
    DISCONNECTED,
    CONNECTING,
    CONNECTED,
    RECONNECTING,
    FAILED
}
