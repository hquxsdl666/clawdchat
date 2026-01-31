package com.clawd.chat.data.model

import kotlinx.serialization.Serializable

@Serializable
data class ChatMessage(
    val id: String,
    val content: String,
    val role: MessageRole,
    val timestamp: Long = System.currentTimeMillis(),
    val status: MessageStatus = MessageStatus.SENT,
    val metadata: MessageMetadata? = null
)

@Serializable
enum class MessageRole {
    USER,
    ASSISTANT,
    SYSTEM
}

@Serializable
enum class MessageStatus {
    PENDING,
    SENT,
    DELIVERED,
    FAILED
}

@Serializable
data class MessageMetadata(
    val model: String? = null,
    val tokens: Int? = null,
    val thinking: Boolean = false
)

@Serializable
sealed class GatewayMessage {
    @Serializable
    data class SendMessage(
        val type: String = "message",
        val content: String,
        val sessionId: String = "main"
    ) : GatewayMessage()
    
    @Serializable
    data class AssistantMessage(
        val type: String = "assistant_message",
        val content: String,
        val sessionId: String,
        val timestamp: Long,
        val done: Boolean = false
    ) : GatewayMessage()
    
    @Serializable
    data class ThinkingStream(
        val type: String = "thinking",
        val content: String,
        val stage: String = "planning"
    ) : GatewayMessage()
    
    @Serializable
    data class SwitchModel(
        val type: String = "switch_model",
        val model: String,
        val sessionId: String = "main"
    ) : GatewayMessage()
    
    @Serializable
    data class StatusUpdate(
        val type: String = "status",
        val connected: Boolean,
        val currentModel: String? = null,
        val agentState: String? = null
    ) : GatewayMessage()
    
    @Serializable
    data class Error(
        val type: String = "error",
        val code: String,
        val message: String
    ) : GatewayMessage()
}
