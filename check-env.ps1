# Environment Check Script for ClawdChat Build
param(
    [switch]$Build
)

Write-Host "========================================"
Write-Host "  ClawdChat Build Environment Check"
Write-Host "========================================"
Write-Host ""

$canBuild = $true

# Check Java
Write-Host "Checking Java..." -ForegroundColor Cyan
$javaVersion = $null
try {
    $javaVersion = & java -version 2>&1 | Select-String "version" | ForEach-Object { $_.ToString() }
    if ($javaVersion -match '"(17|21)\."') {
        Write-Host "  ✓ Java 17+ found: $javaVersion" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Java found but may not be 17+: $javaVersion" -ForegroundColor Yellow
        Write-Host "    Recommended: JDK 17" -ForegroundColor Gray
    }
} catch {
    Write-Host "  ✗ Java not found in PATH" -ForegroundColor Red
    $canBuild = $false
}

Write-Host ""

# Check Android SDK
Write-Host "Checking Android SDK..." -ForegroundColor Cyan
$androidSdk = $env:ANDROID_SDK_ROOT
if (-not $androidSdk) {
    $androidSdk = $env:ANDROID_HOME
}

if ($androidSdk -and (Test-Path $androidSdk)) {
    Write-Host "  ✓ Android SDK found: $androidSdk" -ForegroundColor Green
    
    # Check for required components
    $platform34 = Join-Path $androidSdk "platforms\android-34"
    if (Test-Path $platform34) {
        Write-Host "  ✓ Android API 34 found" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Android API 34 not found" -ForegroundColor Yellow
        Write-Host "    Run: sdkmanager "platforms;android-34"" -ForegroundColor Gray
    }
} else {
    Write-Host "  ✗ Android SDK not found" -ForegroundColor Red
    Write-Host "    Set ANDROID_SDK_ROOT environment variable" -ForegroundColor Gray
    $canBuild = $false
}

Write-Host ""

# Check project structure
Write-Host "Checking project structure..." -ForegroundColor Cyan
$projectRoot = $PSScriptRoot
$requiredFiles = @(
    "build.gradle.kts",
    "app/build.gradle.kts",
    "gradle/libs.versions.toml"
)

$allPresent = $true
foreach ($file in $requiredFiles) {
    $path = Join-Path $projectRoot $file
    if (Test-Path $path) {
        Write-Host "  ✓ $file" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $file missing" -ForegroundColor Red
        $allPresent = $false
        $canBuild = $false
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

if ($canBuild) {
    Write-Host "  Environment ready for building!" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Build command:" -ForegroundColor White
    Write-Host "    .\gradlew.bat assembleDebug" -ForegroundColor Yellow
    
    if ($Build) {
        Write-Host ""
        Write-Host "  Starting build..." -ForegroundColor Cyan
        & "$projectRoot\gradlew.bat" assembleDebug
    }
} else {
    Write-Host "  Environment NOT ready" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Recommended options:" -ForegroundColor White
    Write-Host "    1. Install Android Studio (easiest)" -ForegroundColor Yellow
    Write-Host "    2. Or install JDK 17 + Android SDK + set env vars" -ForegroundColor Yellow
    Write-Host "    3. Or use Docker: docker build -t clawdchat-builder ." -ForegroundColor Yellow
}

Write-Host "========================================" -ForegroundColor Cyan
