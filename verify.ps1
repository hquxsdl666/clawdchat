# Project Verification Script
Write-Host "========================================"
Write-Host "   ClawdChat Project Verification"
Write-Host "========================================"
Write-Host ""

# Check files
Write-Host "[File Check]"
$files = @(
    @("Build Config", "build.gradle.kts"),
    @("App Build", "app/build.gradle.kts"),
    @("Versions", "gradle/libs.versions.toml"),
    @("Manifest", "app/src/main/AndroidManifest.xml"),
    @("MainActivity", "app/src/main/java/com/clawd/chat/MainActivity.kt"),
    @("WebSocket", "app/src/main/java/com/clawd/chat/data/remote/WebSocketClient.kt"),
    @("ChatScreen", "app/src/main/java/com/clawd/chat/ui/screens/ChatScreen.kt"),
    @("Setup Script", "setup.ps1"),
    @("Dockerfile", "Dockerfile"),
    @("GitHub Actions", ".github/workflows/build.yml")
)

$allOk = $true
foreach ($file in $files) {
    $name = $file[0]
    $path = $file[1]
    if (Test-Path $path) {
        Write-Host "  OK $name" -ForegroundColor Green
    } else {
        Write-Host "  MISSING $name" -ForegroundColor Red
        $allOk = $false
    }
}

# Count files
Write-Host ""
Write-Host "[Statistics]"
$kt = (Get-ChildItem -Recurse -Filter "*.kt" -ErrorAction SilentlyContinue).Count
$xml = (Get-ChildItem -Recurse -Filter "*.xml" -ErrorAction SilentlyContinue).Count
$total = (Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue).Count
Write-Host "  Kotlin files: $kt"
Write-Host "  XML files: $xml"
Write-Host "  Total files: $total"

# Environment check
Write-Host ""
Write-Host "[Environment]"
try {
    $v = git --version 2>$null
    if ($LASTEXITCODE -eq 0) { Write-Host "  OK Git: $v" -ForegroundColor Green }
    else { Write-Host "  WARN Git not installed" -ForegroundColor Yellow }
} catch { Write-Host "  WARN Git not installed" -ForegroundColor Yellow }

try {
    $v = docker --version 2>$null
    if ($LASTEXITCODE -eq 0) { Write-Host "  OK Docker: $v" -ForegroundColor Green }
    else { Write-Host "  WARN Docker not installed" -ForegroundColor Yellow }
} catch { Write-Host "  WARN Docker not installed" -ForegroundColor Yellow }

# Result
Write-Host ""
Write-Host "========================================"
if ($allOk) {
    Write-Host "  Project is READY!" -ForegroundColor Green
    Write-Host "========================================"
    Write-Host ""
    Write-Host "Next step: Run .\setup.ps1"
} else {
    Write-Host "  Project incomplete" -ForegroundColor Red
}
Write-Host ""
