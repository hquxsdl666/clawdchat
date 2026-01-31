# ClawdChat 快速开始指南

## 方案 A: GitHub Actions 云端构建（推荐，5分钟）

### 步骤 1: 创建GitHub仓库（1分钟）
1. 访问 https://github.com/new
2. 仓库名称: `clawdchat`
3. 选择 "Public" 或 "Private"
4. 点击 "Create repository"

### 步骤 2: 上传代码（2分钟）
```powershell
cd E:\clawdbot-chat\ClawdChat

# 初始化git
git init

# 添加所有文件
git add .

# 提交
git commit -m "Initial commit"

# 连接远程仓库（替换 YOUR_USERNAME 为您的GitHub用户名）
git remote add origin https://github.com/YOUR_USERNAME/clawdchat.git

# 推送代码
git push -u origin main
```

### 步骤 3: 获取APK（2分钟）
1. 打开GitHub仓库页面
2. 点击 "Actions" 标签
3. 等待工作流完成（约3-5分钟）
4. 点击最新的工作流运行
5. 在 "Artifacts" 部分下载 `app-debug.apk`

---

## 方案 B: 本地命令行构建（需下载SDK）

### 步骤 1: 下载Android SDK Command Line Tools
```powershell
# 创建目录
mkdir C:\android-sdk
cd C:\android-sdk

# 下载命令行工具 (约200MB)
# 手动下载地址: https://developer.android.com/studio#command-tools
# 解压后放到 C:\android-sdk\cmdline-tools\latest\
```

### 步骤 2: 设置环境变量
```powershell
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", "C:\android-sdk", "User")
[Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";C:\android-sdk\cmdline-tools\latest\bin;C:\android-sdk\platform-tools", "User")
```

### 步骤 3: 安装SDK组件
```powershell
sdkmanager "platforms;android-34" "build-tools;34.0.0" "platform-tools"
```

### 步骤 4: 构建APK
```powershell
cd E:\clawdbot-chat\ClawdChat
.\gradlew.bat assembleDebug
```

APK将生成在: `app/build/outputs/apk/debug/app-debug.apk`

---

## 方案 C: Android Studio（功能最全）

### 步骤 1: 下载安装
https://developer.android.com/studio

### 步骤 2: 打开项目
```
File → Open → E:\clawdbot-chat\ClawdChat
```

### 步骤 3: 构建APK
```
Build → Build Bundle(s) / APK(s) → Build APK(s)
```

---

## 安装到手机

### 方法 1: USB安装（需开启USB调试）
```powershell
adb install app-debug.apk
```

### 方法 2: 直接安装
1. 将APK发送到手机（微信/QQ/邮件）
2. 在手机上点击APK文件
3. 允许"安装未知来源应用"

---

## 配置ClawDBot连接

### Mac端配置
```bash
# 安装Tailscale
brew install tailscale

# 启动并获取IP
sudo tailscaled
 tailscale up
 tailscale ip -4
# 输出示例: 100.64.0.1

# 配置ClawDBot
echo "gateway:
  host: \"100.64.0.1\"
  port: 18789" > ~/.config/clawdbot/config.yaml

# 启动Gateway
clawdbot gateway
```

### Android端连接
1. 打开ClawdChat App
2. 点击 "Configure"
3. 输入Mac的Tailscale IP (如 100.64.0.1)
4. 端口 18789
5. 点击 "Connect"

---

## 故障排除

### 问题: git push失败
**解决**: 
```powershell
git config --global user.email "your@email.com"
git config --global user.name "Your Name"
```

### 问题: GitHub Actions构建失败
**解决**: 检查项目文件是否完整提交
```powershell
git status
git add .
git commit -m "Fix missing files"
git push
```

### 问题: 无法连接到Gateway
**解决**:
1. 确认Mac和Android在同一Tailscale网络
2. 检查ClawDBot Gateway是否运行
3. 检查防火墙设置

---

## 推荐路径

| 用户类型 | 推荐方案 | 耗时 |
|---------|---------|------|
| 有GitHub账号 | 方案A (GitHub Actions) | 5分钟 |
| 不想用GitHub | 方案B (命令行) | 20分钟 |
| 需要调试开发 | 方案C (Android Studio) | 30分钟 |
