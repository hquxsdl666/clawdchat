package com.clawd.chat.data.repository

import com.clawd.chat.data.model.ChatMessage
import com.clawd.chat.data.model.GatewayConfig
import com.clawd.chat.data.model.MessageRole
import com.clawd.chat.data.remote.WebSocketClient
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.StateFlow
import java.util.UUID
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ChatRepository @Inject constructor(
    private val webSocketClient: WebSocketClient
) {
    val connectionState = webSocketClient.connectionState
    val messages: Flow<ChatMessage> = webSocketClient.messages
    val thinking: StateFlow<String?> = webSocketClient.thinking
    
    suspend fun connect(config: GatewayConfig): Boolean {
        return webSocketClient.connect(config)
    }
    
    suspend fun disconnect() {
        webSocketClient.disconnect()
    }
    
    suspend fun sendMessage(content: String): Result<Unit> {
        return try {
            webSocketClient.sendMessage(content)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    fun createUserMessage(content: String): ChatMessage {
        return ChatMessage(
            id = UUID.randomUUID().toString(),
            content = content,
            role = MessageRole.USER
        )
    }
}
