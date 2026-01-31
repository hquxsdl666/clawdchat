# ClawdChat

Android client for OpenClaw/ClawDBot Gateway

## Features

- 🔌 Connect to ClawDBot Gateway via WebSocket
- 💬 Real-time chat with AI assistant
- 🔄 Quick model switching (Claude, GPT, etc.)
- 📊 Connection status monitoring
- 🌙 Dark theme optimized

## Project Structure

```
app/src/main/java/com/clawd/chat/
├── data/
│   ├── model/          # Data models
│   ├── remote/         # WebSocket client
│   └── repository/     # Data repositories
├── ui/
│   ├── components/     # Reusable UI components
│   ├── screens/        # Screen composables
│   └── theme/          # Theme configuration
├── di/                 # Dependency injection
└── MainActivity.kt
```

## Tech Stack

- **Language**: Kotlin 2.0
- **UI**: Jetpack Compose (Material3)
- **Architecture**: MVVM + Repository pattern
- **DI**: Hilt
- **Network**: Ktor Client (WebSocket)
- **Storage**: DataStore

## Setup

1. Open project in Android Studio Hedgehog or newer
2. Sync Gradle files
3. Run on emulator or device

## Configuration

On first launch, configure your Gateway:

- **Host**: Your Gateway IP (e.g., `100.64.0.1` for Tailscale)
- **Port**: `18789` (default)
- **Auth Token**: Optional bearer token

## Requirements

- Android 8.0+ (API 26)
- ClawDBot Gateway running on accessible host

## License

MIT
