@echo off
chcp 65001 >nul
title 诊断构建问题
color 0E
cls

echo.
echo ========================================
echo    诊断构建问题
echo ========================================
echo.

cd /d "%~dp0"

echo 【1. 检查文件完整性】
echo -------------------------------
set ERRORS=0

if exist "gradle\wrapper\gradle-wrapper.jar" (
    echo [OK] gradle-wrapper.jar
    for %%I in ("gradle\wrapper\gradle-wrapper.jar") do echo      大小: %%~zI bytes
) else (
    echo [错误] 缺少 gradle-wrapper.jar
    set ERRORS=1
)

if exist "gradlew" (
    echo [OK] gradlew
) else (
    echo [错误] 缺少 gradlew
    set ERRORS=1
)

if exist "build.gradle.kts" (
    echo [OK] build.gradle.kts
) else (
    echo [错误] 缺少 build.gradle.kts
    set ERRORS=1
)

echo.
echo 【2. 检查GitHub Actions配置】
echo -------------------------------
if exist ".github\workflows\android.yml" (
    echo [OK] android.yml 存在
) else if exist ".github\workflows\build.yml" (
    echo [OK] build.yml 存在
) else (
    echo [错误] 缺少GitHub Actions配置
    set ERRORS=1
)

echo.
echo 【3. 检查Git状态】
echo -------------------------------
git status --short
echo.

echo 【4. 尝试本地构建测试】
echo -------------------------------
echo 这将测试本地是否能构建...
echo.
choice /C YN /M "是否运行本地构建测试" /N
if %errorlevel%==1 (
    echo.
    echo 正在运行本地构建（这可能需要几分钟）...
    echo.
    .\gradlew.bat build --stacktrace 2>&1 | head -50
    echo.
    if %errorlevel%==0 (
        echo [本地构建成功]
    ) else (
        echo [本地构建失败]
        set ERRORS=1
    )
)

echo.
echo ========================================
if %ERRORS%==0 (
    echo [诊断] 未发现明显问题
    echo.
    echo 建议:
    echo 1. 访问GitHub查看详细错误
    echo 2. 点击红色X查看构建日志
    echo.
    start https://github.com/hquxsdl666/clawdchat/actions
) else (
    echo [诊断] 发现 %ERRORS% 个问题需要修复
)
echo ========================================

echo.
pause
