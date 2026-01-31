@echo off
chcp 65001 >nul
title 推送到GitHub
color 0A
cls

echo.
echo ========================================
echo    推送到GitHub并构建APK
echo ========================================
echo.

set USERNAME=hquxsdl666

echo 用户名: %USERNAME%
echo.

REM 检查Git
echo [1/5] 检查Git...
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] Git未安装
    echo 请下载: https://git-scm.com/download/win
    pause
    exit /b 1
)
echo [OK] Git已安装
echo.

REM 初始化Git
echo [2/5] 初始化Git仓库...
if not exist ".git" (
    git init
    git config user.email "user@example.com"
    git config user.name "User"
    echo [OK] Git仓库已初始化
) else (
    echo [OK] Git仓库已存在
)
echo.

REM 提交代码
echo [3/5] 提交代码...
git add .
git commit -m "Initial commit: ClawdChat v1.0" >nul 2>&1
echo [OK] 代码已提交
echo.

REM 添加远程仓库
echo [4/5] 连接远程仓库...
git remote remove origin 2>nul
git remote add origin https://github.com/%USERNAME%/clawdchat.git
echo [OK] 远程仓库已配置
echo.

REM 推送代码
echo [5/5] 推送到GitHub...
echo 正在推送，请稍候...
git push -u origin master 2>nul
if %errorlevel% neq 0 (
    git push -u origin main 2>nul
)

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo [成功] 代码已推送到GitHub!
    echo ========================================
    echo.
    echo 正在打开GitHub Actions页面...
    timeout /t 2 >nul
    start https://github.com/%USERNAME%/clawdchat/actions
    echo.
    echo 请等待3-5分钟构建完成，然后下载APK
) else (
    echo.
    echo [错误] 推送失败
    echo.
    echo 可能原因:
    echo 1. 仓库不存在 - 请先创建仓库
    echo    访问: https://github.com/new
    echo    仓库名: clawdchat
    echo.
    echo 2. 需要身份验证
    echo    请使用GitHub Token或配置SSH
)

echo.
pause
