@echo off
chcp 65001 >nul
title 最后推送 - 修复AndroidX
color 0A
cls

echo.
echo ========================================
echo    修复AndroidX配置
echo ========================================
echo.
echo 修复内容:
echo - 添加 gradle.properties
echo - 启用 android.useAndroidX=true
echo.

cd /d "%~dp0"

echo 【1/3】 添加文件...
git add gradle.properties
git add .
echo [OK]
echo.

echo 【2/3】 提交修复...
git commit -m "Fix: 添加gradle.properties，启用AndroidX"
echo [OK]
echo.

echo 【3/3】 推送...
git push origin master
echo [OK]
echo.

echo ========================================
echo [完成] 修复已推送！
echo ========================================
echo.
echo 这应该是最后一个问题了！
echo.
timeout /t 2 >nul
start https://github.com/hquxsdl666/clawdchat/actions

echo.
pause
