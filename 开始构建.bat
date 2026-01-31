@echo off
chcp 65001 >nul
title ClawdChat APK构建
color 0A
cls

echo.
echo  ██████╗██╗      █████╗ ██╗    ██╗██████╗  ██████╗██╗  ██╗ █████╗ ████████╗
echo ██╔════╝██║     ██╔══██╗██║    ██║██╔══██╗██╔════╝██║  ██║██╔══██╗╚══██╔══╝
echo ██║     ██║     ███████║██║ █╗ ██║██║  ██║██║     ███████║███████║   ██║   
echo ██║     ██║     ██╔══██║██║███╗██║██║  ██║██║     ██╔══██║██╔══██║   ██║   
echo ╚██████╗███████╗██║  ██║╚███╔███╔╝██████╔╝╚██████╗██║  ██║██║  ██║   ██║   
echo  ╚═════╝╚══════╝╚═╝  ╚═╝ ╚══╝╚══╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   
echo.
echo ========================================
echo    构建方案选择
echo ========================================
echo.
echo  [1] GitHub Actions (推荐) - 云端自动构建
echo      优点: 无需安装软件，最简单
echo.
echo  [2] 本地Docker构建
echo      优点: 完全本地，隐私性好
echo      需要: 安装Docker Desktop
echo.
echo  [3] 手动步骤说明
echo      适合: 想自己控制构建过程
echo.
echo ========================================
echo.

set /p choice="请选择 (1-3): "

if "%choice%"=="1" goto github
if "%choice%"=="2" goto docker
if "%choice%"=="3" goto manual
goto end

:github
color 0B
cls
echo.
echo 【GitHub Actions 云端构建】
echo ========================================
echo.
echo 步骤1: 检查Git...
echo.

where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 未找到Git
    echo 请下载安装: https://git-scm.com/download/win
    echo 安装后重新运行此脚本
    pause
    exit /b 1
)

echo [OK] Git已安装
echo.

if not exist ".git" (
    echo 步骤2: 初始化Git仓库...
    git init
    git config user.email "user@example.com"
    git config user.name "User"
) else (
    echo [OK] Git仓库已存在
)

echo.
echo 步骤3: 提交代码...
git add .
git commit -m "Initial commit" >nul 2>&1
echo [OK] 代码已提交

echo.
echo ========================================
echo 步骤4: 配置GitHub仓库
echo ========================================
echo.
echo 请先在浏览器中:
echo 1. 访问 https://github.com/new
echo 2. 创建仓库 (名字: clawdchat)
echo 3. 不要勾选 README 和 .gitignore
echo.
set /p USERNAME="输入您的GitHub用户名: "

echo.
echo 正在连接远程仓库...
git remote add origin https://github.com/%USERNAME%/clawdchat.git 2>nul

echo 正在推送代码...
git push -u origin master 2>nul
if %errorlevel% neq 0 (
    git push -u origin main 2>nul
)

echo.
echo ========================================
echo [成功] 代码已推送到GitHub!
echo ========================================
echo.
echo 下一步:
echo 1. 浏览器会自动打开GitHub Actions页面
echo 2. 等待约3-5分钟构建完成
echo 3. 下载 app-debug.apk
echo.
start https://github.com/%USERNAME%/clawdchat/actions
pause
goto end

:docker
color 0E
cls
echo.
echo 【Docker本地构建】
echo ========================================
echo.
echo 检查Docker...
docker --version >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] Docker未安装
    echo.
    echo 请下载安装Docker Desktop:
    echo https://www.docker.com/products/docker-desktop
    echo.
    echo 安装完成后重新运行此脚本
    pause
    exit /b 1
)

echo [OK] Docker已安装
echo.
echo 开始构建Docker镜像...
echo (首次构建需要下载约2GB镜像，请耐心等待)
echo.

docker build -t clawdchat-builder .
if %errorlevel% neq 0 (
    echo [错误] Docker构建失败
    pause
    exit /b 1
)

echo.
echo 正在运行构建容器...
if not exist outputs mkdir outputs

docker run --rm -v "%cd%\outputs:/outputs" clawdchat-builder
if %errorlevel% neq 0 (
    echo [错误] 容器运行失败
    pause
    exit /b 1
)

if exist outputs\app-debug.apk (
    copy outputs\app-debug.apk app-debug.apk >nul
    echo.
    echo ========================================
    echo [成功] APK构建完成!
    echo ========================================
    echo.
    echo 文件位置: %cd%\app-debug.apk
    echo.
) else (
    echo [错误] APK文件未生成
)

pause
goto end

:manual
color 0F
cls
echo.
echo 【手动构建步骤】
echo ========================================
echo.
echo 方案A: 使用Android Studio
echo ---------------------------
echo 1. 下载安装Android Studio:
echo    https://developer.android.com/studio
echo.
echo 2. 打开项目:
echo    File -^> Open -^> 选择此文件夹
echo.
echo 3. 等待Gradle同步完成
echo.
echo 4. 点击菜单:
echo    Build -^> Build Bundle(s) / APK(s) -^> Build APK(s)
echo.
echo 5. APK位置:
echo    app\build\outputs\apk\debug\app-debug.apk
echo.
echo.
echo 方案B: 命令行构建
echo ---------------------------
echo 1. 安装JDK 17:
echo    https://adoptium.net/
echo.
echo 2. 设置环境变量:
echo    JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17
echo.
echo 3. 运行构建:
echo    .\gradlew.bat assembleDebug
echo.
echo 4. APK位置:
echo    app\build\outputs\apk\debug\app-debug.apk
echo.
echo ========================================
pause
goto end

:end
