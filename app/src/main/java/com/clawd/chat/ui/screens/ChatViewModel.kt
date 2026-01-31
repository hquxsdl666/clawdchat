package com.clawd.chat.ui.screens

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.clawd.chat.data.model.ChatMessage
import com.clawd.chat.data.model.ConnectionState
import com.clawd.chat.data.model.GatewayConfig
import com.clawd.chat.data.model.ModelInfo
import com.clawd.chat.data.model.ModelPresets
import com.clawd.chat.data.repository.ChatRepository
import com.clawd.chat.data.repository.SettingsRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.launch
import javax.inject.Inject

 data class ChatUiState(
    val messages: List<ChatMessage> = emptyList(),
    val inputText: String = "",
    val isConnecting: Boolean = false,
    val isConnected: Boolean = false,
    val connectionError: String? = null,
    val latencyMs: Long? = null,
    val currentModel: ModelInfo = ModelPresets.CLAUDE_SONNET,
    val isThinking: Boolean = false,
    val thinkingText: String? = null
)

@HiltViewModel
class ChatViewModel @Inject constructor(
    private val chatRepository: ChatRepository,
    private val settingsRepository: SettingsRepository
) : ViewModel() {
    
    private val _uiState = MutableStateFlow(ChatUiState())
    val uiState: StateFlow<ChatUiState> = _uiState.asStateFlow()
    
    private val _messages = MutableStateFlow<List<ChatMessage>>(emptyList())
    
    init {
        // Collect connection state
        chatRepository.connectionState.onEach { status ->
            _uiState.value = _uiState.value.copy(
                isConnecting = status.state == ConnectionState.CONNECTING || status.state == ConnectionState.RECONNECTING,
                isConnected = status.state == ConnectionState.CONNECTED,
                connectionError = status.errorMessage,
                latencyMs = status.latencyMs
            )
        }.launchIn(viewModelScope)
        
        // Collect messages
        chatRepository.messages.onEach { message ->
            _messages.value = _messages.value + message
            _uiState.value = _uiState.value.copy(messages = _messages.value)
        }.launchIn(viewModelScope)
        
        // Collect thinking state
        chatRepository.thinking.onEach { thinking ->
            _uiState.value = _uiState.value.copy(
                isThinking = thinking != null,
                thinkingText = thinking
            )
        }.launchIn(viewModelScope)
        
        // Load saved model preference
        settingsRepository.currentModel.onEach { modelId ->
            val model = ModelPresets.ALL_MODELS.find { it.id == modelId } ?: ModelPresets.CLAUDE_SONNET
            _uiState.value = _uiState.value.copy(currentModel = model)
        }.launchIn(viewModelScope)
    }
    
    fun connect(config: GatewayConfig) {
        viewModelScope.launch {
            chatRepository.connect(config)
            settingsRepository.saveGatewayConfig(config)
        }
    }
    
    fun disconnect() {
        viewModelScope.launch {
            chatRepository.disconnect()
        }
    }
    
    fun onInputTextChange(text: String) {
        _uiState.value = _uiState.value.copy(inputText = text)
    }
    
    fun sendMessage() {
        val content = _uiState.value.inputText.trim()
        if (content.isEmpty() || !_uiState.value.isConnected) return
        
        viewModelScope.launch {
            // Add user message to list immediately
            val userMessage = chatRepository.createUserMessage(content)
            _messages.value = _messages.value + userMessage
            _uiState.value = _uiState.value.copy(
                messages = _messages.value,
                inputText = ""
            )
            
            // Send to gateway
            chatRepository.sendMessage(content)
        }
    }
    
    fun switchModel(model: ModelInfo) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(currentModel = model)
            settingsRepository.saveCurrentModel(model.id)
            // Note: Actual model switching will be handled when next message is sent
            // or we could send a switch_model message immediately
        }
    }
}
