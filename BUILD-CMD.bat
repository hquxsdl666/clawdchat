@echo off
chcp 65001 >nul
title ClawdChat Builder
color 0A

echo ========================================
echo    ClawdChat 构建工具
echo ========================================
echo.

REM Check Git
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 未找到Git
    echo 请安装Git: https://git-scm.com/download/win
    pause
    exit /b 1
)

echo [1/3] Git 已安装

REM Check if git repo initialized
if not exist ".git" (
    echo [2/3] 初始化Git仓库...
    git init
    git config user.email "user@example.com"
    git config user.name "User"
) else (
    echo [2/3] Git仓库已存在
)

echo.
echo [3/3] 准备推送代码到GitHub...
echo.
echo 请按以下步骤操作:
echo.
echo 1. 访问 https://github.com/new 创建仓库
echo    仓库名: clawdchat
echo.
echo 2. 创建后，输入您的GitHub用户名:
set /p USERNAME="GitHub用户名: "

echo.
echo 3. 正在配置远程仓库...
git remote add origin https://github.com/%USERNAME%/clawdchat.git 2>nul

echo.
echo 4. 正在提交代码...
git add .
git commit -m "Initial commit" >nul 2>&1

echo.
echo 5. 正在推送到GitHub...
git push -u origin master 2>nul || git push -u origin main 2>nul

echo.
echo ========================================
echo    代码已推送!
echo ========================================
echo.
echo 接下来:
echo 1. 打开浏览器访问: https://github.com/%USERNAME%/clawdchat/actions
echo 2. 等待构建完成 (约3-5分钟)
echo 3. 下载 app-debug.apk
echo.
pause
