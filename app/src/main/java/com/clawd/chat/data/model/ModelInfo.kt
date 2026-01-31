package com.clawd.chat.data.model

import androidx.compose.ui.graphics.Color

data class ModelInfo(
    val id: String,
    val name: String,
    val shortName: String,
    val provider: ModelProvider,
    val color: Color,
    val description: String = ""
)

enum class ModelProvider {
    ANTHROPIC,
    OPENAI,
    OLLAMA,
    CUSTOM
}

object ModelPresets {
    val CLAUDE_OPUS = ModelInfo(
        id = "anthropic/claude-opus-4-5",
        name = "Claude Opus 4.5",
        shortName = "Opus",
        provider = ModelProvider.ANTHROPIC,
        color = Color(0xFFCC785C),
        description = "最强大的模型，适合复杂任务"
    )
    
    val CLAUDE_SONNET = ModelInfo(
        id = "anthropic/claude-sonnet-4-5",
        name = "Claude Sonnet 4.5",
        shortName = "Sonnet",
        provider = ModelProvider.ANTHROPIC,
        color = Color(0xFFCC785C),
        description = "性能与速度均衡"
    )
    
    val GPT4O = ModelInfo(
        id = "openai/gpt-4o",
        name = "GPT-4o",
        shortName = "GPT-4o",
        provider = ModelProvider.OPENAI,
        color = Color(0xFF10A37F),
        description = "支持视觉的多模态模型"
    )
    
    val ALL_MODELS = listOf(CLAUDE_OPUS, CLAUDE_SONNET, GPT4O)
}
