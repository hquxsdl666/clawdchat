# 项目完整性验证脚本
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   ClawdChat 项目验证" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$checks = @()
$allPassed = $true

# 检查项目结构
function Check-Item($name, $path) {
    if (Test-Path $path) {
        Write-Host "  OK $name" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  MISSING $name" -ForegroundColor Red
        return $false
    }
}

Write-Host "【项目文件检查】" -ForegroundColor Yellow
$checks += Check-Item "构建配置" "build.gradle.kts"
$checks += Check-Item "应用构建配置" "app/build.gradle.kts"
$checks += Check-Item "版本管理" "gradle/libs.versions.toml"
$checks += Check-Item "清单文件" "app/src/main/AndroidManifest.xml"
$checks += Check-Item "主Activity" "app/src/main/java/com/clawd/chat/MainActivity.kt"
$checks += Check-Item "WebSocket客户端" "app/src/main/java/com/clawd/chat/data/remote/WebSocketClient.kt"
$checks += Check-Item "聊天界面" "app/src/main/java/com/clawd/chat/ui/screens/ChatScreen.kt"
$checks += Check-Item "自动化脚本" "setup.ps1"
$checks += Check-Item "Docker配置" "Dockerfile"
$checks += Check-Item "GitHub Actions" ".github/workflows/build.yml"

Write-Host ""
Write-Host "【代码统计】" -ForegroundColor Yellow

# 统计文件数量
$ktFiles = (Get-ChildItem -Recurse -Filter "*.kt" -ErrorAction SilentlyContinue).Count
$xmlFiles = (Get-ChildItem -Recurse -Filter "*.xml" -ErrorAction SilentlyContinue).Count
$totalFiles = (Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue).Count

Write-Host "  Kotlin源文件: $ktFiles 个" -ForegroundColor Cyan
Write-Host "  XML资源文件: $xmlFiles 个" -ForegroundColor Cyan
Write-Host "  总文件数: $totalFiles 个" -ForegroundColor Cyan

# 检查Git
Write-Host ""
Write-Host "【环境检查】" -ForegroundColor Yellow

try {
    $gitVersion = git --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  OK Git: $gitVersion" -ForegroundColor Green
    } else {
        Write-Host "  WARN Git: 未安装" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  WARN Git: 未安装" -ForegroundColor Yellow
}

try {
    $javaVersion = java -version 2>&1 | Select-String "version" | ForEach-Object { $_.ToString() }
    if ($javaVersion) {
        Write-Host "  OK Java: $javaVersion" -ForegroundColor Green
    } else {
        Write-Host "  WARN Java: 未安装" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  WARN Java: 未安装" -ForegroundColor Yellow
}

try {
    $dockerVersion = docker --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  OK Docker: $dockerVersion" -ForegroundColor Green
    } else {
        Write-Host "  WARN Docker: 未安装" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  WARN Docker: 未安装" -ForegroundColor Yellow
}

# 检查是否Git仓库
if (Test-Path ".git") {
    Write-Host "  OK Git仓库: 已初始化" -ForegroundColor Green
    $remote = git remote get-url origin 2>$null
    if ($remote) {
        Write-Host "  OK 远程仓库: $remote" -ForegroundColor Green
    } else {
        Write-Host "  WARN 远程仓库: 未配置" -ForegroundColor Yellow
    }
} else {
    Write-Host "  WARN Git仓库: 未初始化" -ForegroundColor Yellow
}

# 总体结果
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

if ($checks -contains $false) {
    Write-Host "  验证结果: 部分文件缺失" -ForegroundColor Red
    $allPassed = $false
} else {
    Write-Host "  验证结果: 项目结构完整" -ForegroundColor Green
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($allPassed) {
    Write-Host "项目已就绪！建议下一步:" -ForegroundColor White
    Write-Host ""
    Write-Host "  1. 运行构建脚本:" -ForegroundColor Yellow
    Write-Host "     .\setup.ps1" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  2. 或直接推送到GitHub:" -ForegroundColor Yellow
    Write-Host "     git add ." -ForegroundColor Cyan
    Write-Host "     git commit -m 'Initial commit'" -ForegroundColor Cyan
    Write-Host "     git push -u origin main" -ForegroundColor Cyan
} else {
    Write-Host "项目文件不完整，请检查缺失的文件" -ForegroundColor Red
}

Write-Host ""
