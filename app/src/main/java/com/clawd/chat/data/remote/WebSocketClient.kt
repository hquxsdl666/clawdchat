package com.clawd.chat.data.remote

import android.util.Log
import com.clawd.chat.data.model.ChatMessage
import com.clawd.chat.data.model.GatewayConfig
import com.clawd.chat.data.model.GatewayMessage
import com.clawd.chat.data.model.MessageRole
import io.ktor.client.HttpClient
import io.ktor.client.engine.okhttp.OkHttp
import io.ktor.client.plugins.websocket.DefaultClientWebSocketSession
import io.ktor.client.plugins.websocket.WebSockets
import io.ktor.client.plugins.websocket.webSocketSession
import io.ktor.websocket.Frame
import io.ktor.websocket.close
import io.ktor.websocket.readText
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.jsonPrimitive
import java.util.UUID
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class WebSocketClient @Inject constructor() {
    
    companion object {
        private const val TAG = "WebSocketClient"
        private const val RECONNECT_DELAY_MS = 5000L
        private const val HEARTBEAT_INTERVAL_MS = 30000L
    }
    
    private val json = Json { 
        ignoreUnknownKeys = true 
        isLenient = true
    }
    
    private var client: HttpClient? = null
    private var session: DefaultClientWebSocketSession? = null
    private var currentConfig: GatewayConfig? = null
    
    private val _connectionState = MutableStateFlow(com.clawd.chat.data.model.ConnectionStatus())
    val connectionState: StateFlow<com.clawd.chat.data.model.ConnectionStatus> = _connectionState.asStateFlow()
    
    private val _messages = MutableSharedFlow<ChatMessage>()
    val messages: Flow<ChatMessage> = _messages.asSharedFlow()
    
    private val _thinking = MutableStateFlow<String?>(null)
    val thinking: StateFlow<String?> = _thinking.asStateFlow()
    
    private var reconnectJob: Job? = null
    private var heartbeatJob: Job? = null
    private val scope = CoroutineScope(Dispatchers.IO)
    
    suspend fun connect(config: GatewayConfig): Boolean {
        Log.d(TAG, "Connecting to ${config.getWebSocketUrl()}")
        currentConfig = config
        _connectionState.value = com.clawd.chat.data.model.ConnectionStatus(
            state = com.clawd.chat.data.model.ConnectionState.CONNECTING
        )
        
        client = HttpClient(OkHttp) {
            install(WebSockets) {
                pingInterval = HEARTBEAT_INTERVAL_MS
            }
        }
        
        return try {
            val startTime = System.currentTimeMillis()
            session = client!!.webSocketSession(config.getWebSocketUrl())
            val latency = System.currentTimeMillis() - startTime
            
            _connectionState.value = com.clawd.chat.data.model.ConnectionStatus(
                state = com.clawd.chat.data.model.ConnectionState.CONNECTED,
                latencyMs = latency
            )
            
            startListening()
            startHeartbeat()
            true
        } catch (e: Exception) {
            Log.e(TAG, "Connection failed", e)
            _connectionState.value = com.clawd.chat.data.model.ConnectionStatus(
                state = com.clawd.chat.data.model.ConnectionState.FAILED,
                errorMessage = e.message
            )
            scheduleReconnect()
            false
        }
    }
    
    suspend fun sendMessage(content: String) {
        val message = GatewayMessage.SendMessage(
            content = content,
            sessionId = "main"
        )
        send(message)
    }
    
    suspend fun switchModel(modelId: String) {
        val message = GatewayMessage.SwitchModel(model = modelId)
        send(message)
    }
    
    private suspend fun send(message: GatewayMessage) {
        try {
            val jsonStr = json.encodeToString(GatewayMessage.serializer(), message)
            session?.outgoing?.send(Frame.Text(jsonStr))
        } catch (e: Exception) {
            Log.e(TAG, "Send failed", e)
            _connectionState.value = _connectionState.value.copy(
                errorMessage = "Send failed: ${e.message}"
            )
        }
    }
    
    private fun startListening() {
        scope.launch {
            try {
                val currentSession = session ?: return@launch
                currentSession.incoming.collect { frame ->
                    if (frame is Frame.Text) {
                        handleMessage(frame.readText())
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Listen error", e)
                handleDisconnect()
            }
        }
    }
    
    private fun handleMessage(jsonStr: String) {
        try {
            val jsonObject = json.decodeFromString<JsonObject>(jsonStr)
            val type = jsonObject["type"]?.jsonPrimitive?.content ?: "unknown"
            
            when (type) {
                "assistant_message" -> {
                    val content = jsonObject["content"]?.jsonPrimitive?.content ?: ""
                    val timestamp = jsonObject["timestamp"]?.jsonPrimitive?.content?.toLongOrNull() 
                        ?: System.currentTimeMillis()
                    val chatMessage = ChatMessage(
                        id = UUID.randomUUID().toString(),
                        content = content,
                        role = MessageRole.ASSISTANT,
                        timestamp = timestamp
                    )
                    scope.launch { _messages.emit(chatMessage) }
                    _thinking.value = null
                }
                "thinking" -> {
                    val content = jsonObject["content"]?.jsonPrimitive?.content ?: ""
                    _thinking.value = content
                }
                "status" -> {
                    Log.d(TAG, "Status update received")
                }
                "error" -> {
                    val message = jsonObject["message"]?.jsonPrimitive?.content ?: "Unknown error"
                    Log.e(TAG, "Gateway error: $message")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Parse error: $jsonStr", e)
        }
    }
    
    private fun startHeartbeat() {
        heartbeatJob?.cancel()
        heartbeatJob = scope.launch {
            while (isActive) {
                delay(HEARTBEAT_INTERVAL_MS)
                try {
                    session?.outgoing?.send(Frame.Ping(ByteArray(0)))
                } catch (e: Exception) {
                    Log.e(TAG, "Heartbeat failed", e)
                    handleDisconnect()
                    break
                }
            }
        }
    }
    
    private fun handleDisconnect() {
        if (_connectionState.value.state == com.clawd.chat.data.model.ConnectionState.CONNECTED) {
            _connectionState.value = com.clawd.chat.data.model.ConnectionStatus(
                state = com.clawd.chat.data.model.ConnectionState.DISCONNECTED
            )
            scheduleReconnect()
        }
    }
    
    private fun scheduleReconnect() {
        reconnectJob?.cancel()
        reconnectJob = scope.launch {
            _connectionState.value = _connectionState.value.copy(
                state = com.clawd.chat.data.model.ConnectionState.RECONNECTING,
                retryCount = _connectionState.value.retryCount + 1
            )
            delay(RECONNECT_DELAY_MS)
            currentConfig?.let { connect(it) }
        }
    }
    
    suspend fun disconnect() {
        reconnectJob?.cancel()
        heartbeatJob?.cancel()
        session?.close()
        session = null
        client?.close()
        client = null
        _connectionState.value = com.clawd.chat.data.model.ConnectionStatus(
            state = com.clawd.chat.data.model.ConnectionState.DISCONNECTED
        )
    }
}
