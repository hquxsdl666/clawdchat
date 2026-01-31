# Build APK Guide

## Option 1: Build with Android Studio (Recommended)

1. Open Android Studio
2. File → Open → Select `E:\clawdbot-chat\ClawdChat`
3. Wait for Gradle sync to complete
4. Build → Build Bundle(s) / APK(s) → Build APK(s)
5. APK will be at: `app/build/outputs/apk/debug/app-debug.apk`

## Option 2: Build with Command Line

### Prerequisites
- Android SDK installed
- JDK 17 installed
- Environment variables set:
  - `ANDROID_SDK_ROOT` or `ANDROID_HOME`
  - `JAVA_HOME`

### Build Steps

```powershell
# Navigate to project directory
cd E:\clawdbot-chat\ClawdChat

# Make gradlew executable (if on Linux/Mac)
# chmod +x gradlew

# Build debug APK
.\gradlew.bat assembleDebug

# Or build release APK (requires signing config)
.\gradlew.bat assembleRelease
```

### Output Location
- Debug APK: `app/build/outputs/apk/debug/app-debug.apk`
- Release APK: `app/build/outputs/apk/release/app-release-unsigned.apk`

## Option 3: Build with Docker

```bash
# Create a Dockerfile
docker build -t clawdchat-builder .
docker run -v $(pwd)/app/build/outputs:/outputs clawdchat-builder
```

## Troubleshooting

### Issue: SDK not found
**Solution**: Update `local.properties` with correct SDK path:
```properties
sdk.dir=C\:\\Users\\YourUsername\\AppData\\Local\\Android\\Sdk
```

### Issue: Gradle sync failed
**Solution**: 
1. File → Invalidate Caches → Invalidate and Restart
2. Or run: `.\gradlew.bat clean build`

### Issue: Build failed with "Cannot find symbol"
**Solution**: Clean and rebuild:
```powershell
.\gradlew.bat clean
.\gradlew.bat build
```

## Install APK

### Via ADB
```powershell
adb install app/build/outputs/apk/debug/app-debug.apk
```

### Via File Transfer
1. Copy APK to device
2. Enable "Install from unknown sources" in Settings
3. Tap APK to install
