@echo off
chcp 65001 >nul
title 本地构建测试
color 0B
cls

echo.
echo ========================================
echo    本地构建测试（查看详细错误）
echo ========================================
echo.

cd /d "%~dp0"

echo 这个测试会在本地运行Gradle构建，
echo 可以查看具体的错误信息。
echo.
echo 按任意键开始构建...
echo.
pause >nul
cls

echo.
echo [开始构建...]
echo.
echo ========================================
echo.

:: 尝试构建
.\gradlew.bat assembleDebug --stacktrace --info 2>&1

echo.
echo ========================================
echo.

if %errorlevel% equ 0 (
    echo [成功] 构建完成！
    echo.
    echo APK位置: app\build\outputs\apk\debug\app-debug.apk
) else (
    echo [失败] 构建出错，请查看上面的错误信息
    echo.
    echo 常见错误:
    echo - 缺少Java: 请安装JDK 17
    echo - 内存不足: 关闭其他程序再试
    echo - 依赖下载失败: 检查网络连接
)

echo.
pause
