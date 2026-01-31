@echo off
chcp 65001 >nul
title 强制重新构建
color 0A
cls

echo.
echo ========================================
echo    强制重新构建（绕过缓存）
echo ========================================
echo.

cd /d "%~dp0"

echo 【1/2】 创建空提交强制触发构建...
git commit --allow-empty -m "Trigger: 强制重新构建，绕过GitHub缓存"
echo [OK]
echo.

echo 【2/2】 推送到GitHub...
git push origin master
echo [OK]
echo.

echo ========================================
echo [完成] 已强制触发新构建！
echo ========================================
echo.
echo 请等待5-10分钟查看结果
echo.
timeout /t 2 >nul
start https://github.com/hquxsdl666/clawdchat/actions

echo.
pause
