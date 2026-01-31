@echo off
chcp 65001 >nul
title 检查并修复项目
color 0A
cls

echo.
echo ========================================
echo    检查项目完整性
echo ========================================
echo.

cd /d "%~dp0"

set MISSING=0

echo [检查必要文件...]
echo.

if not exist "gradlew" (
    echo 缺少: gradlew
    set MISSING=1
) else (
    echo OK: gradlew
)

if not exist "gradle\wrapper\gradle-wrapper.properties" (
    echo 缺少: gradle-wrapper.properties
    set MISSING=1
) else (
    echo OK: gradle-wrapper.properties
)

if not exist "gradle\wrapper\gradle-wrapper.jar" (
    echo 警告: gradle-wrapper.jar 不存在
    echo 这会导致GitHub Actions构建失败！
    echo.
    echo 尝试下载...
    echo.
    
    if not exist "gradle\wrapper" mkdir "gradle\wrapper"
    
    powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/gradle/gradle/v8.4.0/gradle/wrapper/gradle-wrapper.jar' -OutFile 'gradle/wrapper/gradle-wrapper.jar' -UseBasicParsing" 2>nul
    
    if exist "gradle\wrapper\gradle-wrapper.jar" (
        echo OK: 已下载 gradle-wrapper.jar
    ) else (
        echo 失败: 无法下载，请手动下载
        echo 地址: https://services.gradle.org/distributions/gradle-8.4-bin.zip
        set MISSING=1
    )
) else (
    echo OK: gradle-wrapper.jar
)

echo.

if %MISSING%==1 (
    echo ========================================
    echo [警告] 有文件缺失，请修复后再推送
    echo ========================================
) else (
    echo ========================================
    echo [完成] 所有必要文件都已存在
    echo ========================================
    echo.
    echo 现在可以重新推送代码:
    echo.
    echo   git add .
    echo   git commit -m "Fix: Add missing files"
    echo   git push origin master
)

echo.
pause
