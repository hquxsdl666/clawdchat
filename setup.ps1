# ClawdChat 完整设置与构建脚本
param(
    [switch]$Docker,
    [switch]$Local,
    [switch]$GitHub
)

$ErrorActionPreference = "Stop"

Write-Host @"
========================================
   ClawdChat 自动构建系统
========================================
"@ -ForegroundColor Cyan

# 检查Git
function Test-Git {
    try {
        $gitVersion = git --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Git 已安装: $gitVersion" -ForegroundColor Green
            return $true
        }
    } catch {}
    
    Write-Host "✗ Git 未安装" -ForegroundColor Red
    Write-Host "  正在下载 Git..." -ForegroundColor Yellow
    
    $gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe"
    $gitInstaller = "$env:TEMP\git-installer.exe"
    
    try {
        Invoke-WebRequest -Uri $gitUrl -OutFile $gitInstaller -UseBasicParsing
        Write-Host "  正在安装 Git..." -ForegroundColor Yellow
        Start-Process -FilePath $gitInstaller -ArgumentList "/VERYSILENT", "/NORESTART" -Wait
        $env:PATH = "$env:PATH;C:\Program Files\Git\bin"
        Write-Host "✓ Git 安装完成" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "✗ Git 安装失败，请手动下载: https://git-scm.com/download/win" -ForegroundColor Red
        return $false
    }
}

# 检查Java
function Test-Java {
    try {
        $javaVersion = java -version 2>&1 | Select-String "version" | ForEach-Object { $_.ToString() }
        if ($javaVersion -match '"(17|21)') {
            Write-Host "✓ Java 17+ 已安装" -ForegroundColor Green
            return $true
        }
    } catch {}
    
    Write-Host "⚠ Java 未安装或版本过低" -ForegroundColor Yellow
    return $false
}

# 方案1: GitHub Actions构建
function Build-GitHubActions {
    Write-Host ""
    Write-Host "【方案1】GitHub Actions 云端构建" -ForegroundColor Cyan
    Write-Host "----------------------------------------"
    
    # 配置Git
    Write-Host "配置 Git..." -ForegroundColor Yellow
    
    $gitName = git config user.name 2>$null
    $gitEmail = git config user.email 2>$null
    
    if (-not $gitName) {
        $gitName = Read-Host "请输入您的名字"
        git config user.name "$gitName"
    }
    
    if (-not $gitEmail) {
        $gitEmail = Read-Host "请输入您的邮箱"
        git config user.email "$gitEmail"
    }
    
    # 检查远程仓库
    $remoteUrl = git remote get-url origin 2>$null
    
    if (-not $remoteUrl) {
        Write-Host ""
        Write-Host "首次使用，需要配置GitHub仓库" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "请按以下步骤操作:" -ForegroundColor White
        Write-Host "1. 打开 https://github.com/new" -ForegroundColor Cyan
        Write-Host "2. 创建仓库（如: clawdchat）" -ForegroundColor Cyan
        Write-Host "3. 不要初始化README（保持空仓库）" -ForegroundColor Cyan
        Write-Host ""
        
        $username = Read-Host "输入您的GitHub用户名"
        $repo = Read-Host "输入仓库名（默认: clawdchat）"
        if (-not $repo) { $repo = "clawdchat" }
        
        git remote add origin "https://github.com/$username/$repo.git"
        $remoteUrl = "https://github.com/$username/$repo"
    }
    
    # 提交并推送
    Write-Host ""
    Write-Host "正在提交代码..." -ForegroundColor Yellow
    
    git add .
    git commit -m "Initial commit: ClawdChat v1.0" 2>$null | Out-Null
    
    Write-Host "正在推送到GitHub..." -ForegroundColor Yellow
    try {
        git push -u origin main 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            git push -u origin master 2>&1 | Out-Null
        }
        Write-Host "✓ 代码推送成功!" -ForegroundColor Green
    } catch {
        Write-Host "⚠ 推送可能需要身份验证" -ForegroundColor Yellow
        Write-Host "  请运行: git push -u origin main" -ForegroundColor Cyan
        return
    }
    
    # 打开GitHub Actions页面
    $actionsUrl = "$remoteUrl/actions"
    Write-Host ""
    Write-Host "正在打开GitHub Actions页面..." -ForegroundColor Green
    Start-Process $actionsUrl
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  构建已开始！" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "请在浏览器中:" -ForegroundColor White
    Write-Host "  1. 等待 Actions 工作流完成 (约3-5分钟)" -ForegroundColor Cyan
    Write-Host "  2. 点击最新的运行记录" -ForegroundColor Cyan
    Write-Host "  3. 下载 Artifacts → app-debug.apk" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "APK下载地址: $actionsUrl" -ForegroundColor Yellow
}

# 方案2: Docker构建
function Build-Docker {
    Write-Host ""
    Write-Host "【方案2】Docker 本地构建" -ForegroundColor Cyan
    Write-Host "----------------------------------------"
    
    # 检查Docker
    try {
        $dockerVersion = docker --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Docker 已安装: $dockerVersion" -ForegroundColor Green
        } else {
            throw "Docker not found"
        }
    } catch {
        Write-Host "✗ Docker 未安装" -ForegroundColor Red
        Write-Host "  请下载安装: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
        Write-Host "  安装完成后重新运行此脚本" -ForegroundColor Yellow
        return
    }
    
    Write-Host ""
    Write-Host "正在构建Docker镜像..." -ForegroundColor Yellow
    Write-Host "（首次构建需要下载约2GB镜像，请耐心等待）" -ForegroundColor Gray
    
    docker build -t clawdchat-builder . 2>&1 | ForEach-Object {
        Write-Host $_ -ForegroundColor Gray
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "✗ Docker构建失败" -ForegroundColor Red
        return
    }
    
    Write-Host ""
    Write-Host "正在运行构建容器..." -ForegroundColor Yellow
    
    if (-not (Test-Path "outputs")) {
        New-Item -ItemType Directory -Name "outputs" | Out-Null
    }
    
    docker run --rm -v "${PWD}\outputs:/outputs" clawdchat-builder 2>&1 | ForEach-Object {
        Write-Host $_ -ForegroundColor Gray
    }
    
    if (Test-Path "outputs\apk\debug\app-debug.apk") {
        Copy-Item "outputs\apk\debug\app-debug.apk" "app-debug.apk" -Force
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "  APK构建成功！" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "  文件位置: app-debug.apk" -ForegroundColor Yellow
        Write-Host "  文件大小: $([math]::Round((Get-Item 'app-debug.apk').Length / 1MB, 2)) MB" -ForegroundColor Yellow
    } else {
        Write-Host "✗ APK文件未生成" -ForegroundColor Red
    }
}

# 方案3: 本地命令行构建
function Build-Local {
    Write-Host ""
    Write-Host "【方案3】本地命令行构建" -ForegroundColor Cyan
    Write-Host "----------------------------------------"
    
    if (-not (Test-Java)) {
        Write-Host ""
        Write-Host "Java未安装，正在下载..." -ForegroundColor Yellow
        
        $jdkUrl = "https://download.java.net/openjdk/jdk17/ri/openjdk-17+35_windows-x64_bin.zip"
        $jdkZip = "$env:TEMP\openjdk17.zip"
        $jdkPath = "C:\openjdk17"
        
        try {
            Invoke-WebRequest -Uri $jdkUrl -OutFile $jdkZip -UseBasicParsing
            Expand-Archive -Path $jdkZip -DestinationPath $jdkPath -Force
            $env:JAVA_HOME = "$jdkPath\jdk-17"
            $env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
            Write-Host "✓ Java 17 安装完成" -ForegroundColor Green
        } catch {
            Write-Host "✗ Java安装失败，请手动下载: https://adoptium.net/" -ForegroundColor Red
            return
        }
    }
    
    Write-Host ""
    Write-Host "正在构建APK..." -ForegroundColor Yellow
    Write-Host "（首次构建需要下载依赖，请耐心等待）" -ForegroundColor Gray
    
    .\gradlew.bat assembleDebug 2>&1 | ForEach-Object {
        if ($_ -match "BUILD SUCCESSFUL") {
            Write-Host $_ -ForegroundColor Green
        } elseif ($_ -match "BUILD FAILED|error:") {
            Write-Host $_ -ForegroundColor Red
        } else {
            Write-Host $_ -ForegroundColor Gray
        }
    }
    
    if (Test-Path "app\build\outputs\apk\debug\app-debug.apk") {
        Copy-Item "app\build\outputs\apk\debug\app-debug.apk" "app-debug.apk" -Force
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "  APK构建成功！" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "  文件位置: app-debug.apk" -ForegroundColor Yellow
    } else {
        Write-Host ""
        Write-Host "✗ 构建失败，请检查错误信息" -ForegroundColor Red
    }
}

# 主逻辑
if (-not (Test-Git)) {
    exit 1
}

# 确保Git仓库已初始化
if (-not (Test-Path ".git")) {
    git init
    Write-Host "✓ Git仓库已初始化" -ForegroundColor Green
}

# 选择构建方案
Write-Host ""
Write-Host "请选择构建方案:" -ForegroundColor White
Write-Host "  [1] GitHub Actions (推荐，最简单，无需安装软件)" -ForegroundColor Green
Write-Host "  [2] Docker构建 (需要Docker Desktop)" -ForegroundColor Yellow  
Write-Host "  [3] 本地构建 (需要Java，首次较慢)" -ForegroundColor Yellow
Write-Host ""

if ($GitHub) {
    $choice = "1"
} elseif ($Docker) {
    $choice = "2"
} elseif ($Local) {
    $choice = "3"
} else {
    $choice = Read-Host "输入选项 (1-3，默认: 1)"
    if (-not $choice) { $choice = "1" }
}

switch ($choice) {
    "1" { Build-GitHubActions }
    "2" { Build-Docker }
    "3" { Build-Local }
    default { 
        Write-Host "无效选项，使用默认方案1 (GitHub Actions)" -ForegroundColor Yellow
        Build-GitHubActions 
    }
}

Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
