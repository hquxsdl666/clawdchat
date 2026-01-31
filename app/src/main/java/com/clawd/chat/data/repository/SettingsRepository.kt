package com.clawd.chat.data.repository

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.clawd.chat.data.model.GatewayConfig
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import javax.inject.Inject
import javax.inject.Singleton

private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "settings")

@Singleton
class SettingsRepository @Inject constructor(
    @ApplicationContext private val context: Context
) {
    private val json = Json { ignoreUnknownKeys = true }
    
    private object Keys {
        val GATEWAY_CONFIG = stringPreferencesKey("gateway_config")
        val CURRENT_MODEL = stringPreferencesKey("current_model")
    }
    
    val gatewayConfig: Flow<GatewayConfig> = context.dataStore.data
        .map { preferences ->
            preferences[Keys.GATEWAY_CONFIG]?.let {
                try {
                    json.decodeFromString(it)
                } catch (e: Exception) {
                    GatewayConfig()
                }
            } ?: GatewayConfig()
        }
    
    val currentModel: Flow<String> = context.dataStore.data
        .map { preferences ->
            preferences[Keys.CURRENT_MODEL] ?: "anthropic/claude-sonnet-4-5"
        }
    
    suspend fun saveGatewayConfig(config: GatewayConfig) {
        context.dataStore.edit { preferences ->
            preferences[Keys.GATEWAY_CONFIG] = json.encodeToString(config)
        }
    }
    
    suspend fun saveCurrentModel(modelId: String) {
        context.dataStore.edit { preferences ->
            preferences[Keys.CURRENT_MODEL] = modelId
        }
    }
}
