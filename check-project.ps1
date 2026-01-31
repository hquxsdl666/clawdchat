# Project Validation Script
Write-Host "Checking ClawdChat Project Structure..." -ForegroundColor Green

$requiredFiles = @(
    "build.gradle.kts",
    "settings.gradle.kts",
    "app/build.gradle.kts",
    "app/src/main/AndroidManifest.xml",
    "app/src/main/java/com/clawd/chat/MainActivity.kt",
    "app/src/main/java/com/clawd/chat/ClawdChatApplication.kt",
    "app/src/main/java/com/clawd/chat/data/remote/WebSocketClient.kt",
    "app/src/main/java/com/clawd/chat/ui/screens/ChatScreen.kt",
    "gradle/libs.versions.toml"
)

$missingFiles = @()

foreach ($file in $requiredFiles) {
    $path = Join-Path $PSScriptRoot $file
    if (Test-Path $path) {
        Write-Host "  ✓ $file" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $file (MISSING)" -ForegroundColor Red
        $missingFiles += $file
    }
}

Write-Host ""

if ($missingFiles.Count -eq 0) {
    Write-Host "All required files present!" -ForegroundColor Green
    Write-Host ""
    Write-Host "To build APK:" -ForegroundColor Cyan
    Write-Host "  1. Open Android Studio" -ForegroundColor White
    Write-Host "  2. File -> Open -> Select this folder" -ForegroundColor White
    Write-Host "  3. Build -> Build Bundle(s) / APK(s) -> Build APK(s)" -ForegroundColor White
    Write-Host ""
    Write-Host "Or run: .\gradlew.bat assembleDebug" -ForegroundColor Cyan
    exit 0
} else {
    Write-Host "Missing files detected. Please check the project structure." -ForegroundColor Red
    exit 1
}
