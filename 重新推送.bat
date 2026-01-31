@echo off
chcp 65001 >nul
title 重新推送修复后的代码
color 0A
cls

echo.
echo ========================================
echo    修复后重新推送
echo ========================================
echo.

cd /d "%~dp0"

echo [1/4] 添加所有更改...
git add .
echo [OK]
echo.

echo [2/4] 提交修复...
git commit -m "Fix: 更新GitHub Actions配置" --allow-empty
echo [OK]
echo.

echo [3/4] 推送到GitHub...
git push origin master 2>nul
if %errorlevel% neq 0 (
    git push origin main 2>nul
)
echo [OK]
echo.

echo [4/4] 打开Actions页面...
echo.
echo 正在打开浏览器...
timeout /t 2 >nul
start https://github.com/hquxsdl666/clawdchat/actions

echo.
echo ========================================
echo [完成] 已重新推送！
echo ========================================
echo.
echo 请等待新的构建完成（约5-10分钟）
echo.
pause
