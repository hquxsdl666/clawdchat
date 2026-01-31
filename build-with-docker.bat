@echo off
echo Building ClawdChat APK with Docker...

docker build -t clawdchat-builder .
if errorlevel 1 (
    echo Docker build failed!
    exit /b 1
)

if not exist outputs mkdir outputs

docker run --rm -v "%cd%\outputs:/outputs" clawdchat-builder
if errorlevel 1 (
    echo Docker run failed!
    exit /b 1
)

echo.
echo Build completed!
echo APK location: outputs/apk/debug/app-debug.apk
pause
