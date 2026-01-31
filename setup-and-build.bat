@echo off
chcp 65001 >nul
echo ========================================
echo   ClawdChat 自动构建脚本
echo ========================================
echo.

REM Check if git is installed
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 未找到Git，请先安装Git
    echo 下载地址: https://git-scm.com/download/win
    pause
    exit /b 1
)

REM Check if GitHub repo is configured
git remote -v >nul 2>nul
if %errorlevel% neq 0 (
    echo [提示] 未配置GitHub仓库
    echo.
    echo 请按以下步骤操作:
    echo 1. 访问 https://github.com/new 创建仓库
    echo 2. 输入您的GitHub用户名:
    set /p USERNAME="GitHub用户名: "
    set /p REPO="仓库名 (默认: clawdchat): "
    if "!REPO!"=="" set REPO=clawdchat
    
    git init
    git add .
    git commit -m "Initial commit"
    git remote add origin https://github.com/%USERNAME%/%REPO%.git
)

echo.
echo [步骤 1/3] 正在推送代码到GitHub...
git add .
git commit -m "Update project" 2>nul
git push -u origin main

if %errorlevel% neq 0 (
    echo.
    echo [错误] 推送失败，请检查:
    echo - GitHub仓库是否已创建
    echo - 用户名/仓库名是否正确
    echo - 是否已登录GitHub
    pause
    exit /b 1
)

echo.
echo [步骤 2/3] 代码推送成功！
echo.
echo [步骤 3/3] 请在浏览器中完成以下操作:
echo.
echo 1. 打开GitHub仓库页面:
for /f "tokens=*" %%a in ('git remote get-url origin') do (
    set URL=%%a
)
echo    %URL%
echo.
echo 2. 点击 "Actions" 标签
echo.
echo 3. 等待构建完成（约3-5分钟）
echo.
echo 4. 点击最新的工作流运行
echo.
echo 5. 在 "Artifacts" 部分下载 app-debug.apk
echo.

REM Open browser
start %URL%

echo ========================================
echo   构建完成后，下载APK安装到手机即可！
echo ========================================
pause
