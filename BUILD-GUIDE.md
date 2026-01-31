# ClawdChat APK构建指南

## 快速开始（推荐）

### 方式一：一键脚本（最简单）

```powershell
cd E:\clawdbot-chat\ClawdChat
.\setup.ps1
```

脚本会引导您选择构建方案并完成所有操作。

---

## 构建方案详解

### 方案1：GitHub Actions（推荐⭐）

**适用场景**：不想安装任何软件，快速获取APK

**步骤**：

1. **创建GitHub仓库**（如果还没有）
   - 访问 https://github.com/new
   - 仓库名：`clawdchat`
   - 选择 Public 或 Private

2. **运行自动脚本**
   ```powershell
   .\setup.ps1 -GitHub
   ```
   或直接运行 `.\setup.ps1` 选择选项1

3. **下载APK**（脚本会自动打开浏览器）
   - 等待 Actions 工作流完成（约3-5分钟）
   - 点击 "Artifacts" 下载 `app-debug.apk`

**优点**：
- ✅ 无需安装任何软件
- ✅ 云端构建，不占用本地资源
- ✅ 自动保存构建历史

---

### 方案2：Docker构建

**适用场景**：不想用GitHub，也不想安装Android Studio

**前提**：安装 Docker Desktop（约300MB）

**步骤**：

1. **安装Docker Desktop**
   - 下载：https://www.docker.com/products/docker-desktop
   - 安装并启动

2. **运行构建**
   ```powershell
   .\setup.ps1 -Docker
   ```
   或 `.\setup.ps1` 选择选项2

3. **获取APK**
   - 构建完成后，APK在 `app-debug.apk`

**优点**：
- ✅ 完全本地构建
- ✅ 环境隔离，不污染系统

---

### 方案3：本地命令行构建

**适用场景**：开发者，需要频繁构建

**步骤**：

```powershell
.\setup.ps1 -Local
```

脚本会自动下载并配置：
- OpenJDK 17
- Android SDK
- Gradle

**构建完成后**：
- APK位置：`app/build/outputs/apk/debug/app-debug.apk`
- 或复制到：`app-debug.apk`

---

## 安装APK到手机

### 方法1：USB调试安装（推荐）

```powershell
# 1. 开启手机USB调试
# 设置 → 开发者选项 → USB调试

# 2. 连接手机，安装APK
adb install app-debug.apk
```

### 方法2：直接传输安装

1. 将APK发送到手机（微信/QQ/邮件/数据线）
2. 在手机上点击APK文件
3. 允许"安装未知来源应用"
4. 完成安装

---

## 配置ClawDBot连接

### Mac端配置

```bash
# 1. 安装Tailscale
brew install tailscale

# 2. 启动并连接
sudo tailscaled
 tailscale up

# 3. 获取IP地址
 tailscale ip -4
# 输出示例：100.64.0.1

# 4. 配置ClawDBot
echo "gateway:
  host: \"$( tailscale ip -4)\" 
  port: 18789
  auth:
    type: token
    token: your-secure-token" > ~/.config/clawdbot/config.yaml

# 5. 启动Gateway
clawdbot gateway
```

### Android端配置

1. 打开ClawdChat App
2. 点击顶部的 "Disconnected" 或设置按钮
3. 输入Mac的Tailscale IP（如 `100.64.0.1`）
4. 端口保持 `18789`
5. 点击 "Connect"
6. 连接成功后即可开始聊天

---

## 故障排除

### 问题1：GitHub Actions构建失败

**解决**：
```powershell
# 检查代码是否完整提交
git status
git add .
git commit -m "Fix build"
git push
```

### 问题2：Docker构建缓慢/失败

**解决**：
- 确保Docker Desktop已启动
- 检查网络连接（需下载约2GB镜像）
- 增加Docker内存限制到4GB+

### 问题3：本地构建Java错误

**解决**：
```powershell
# 手动设置JAVA_HOME
$env:JAVA_HOME = "C:\openjdk17\jdk-17"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
```

### 问题4：连接ClawDBot失败

**解决**：
1. 确认Mac和Android在同一Tailscale网络
2. 检查ClawDBot Gateway是否运行
3. 检查防火墙设置
4. 尝试用浏览器访问 `http://<ip>:18789` 测试连通性

---

## 文件说明

| 文件 | 用途 |
|------|------|
| `setup.ps1` | 主自动化脚本 |
| `Dockerfile` | Docker构建配置 |
| `build.yml` | GitHub Actions配置 |
| `app-debug.apk` | 生成的APK文件 |

---

## 推荐工作流

```powershell
# 开发迭代流程
git add .
git commit -m "Update feature"
git push

# GitHub自动构建 → 下载新APK → 安装测试
```
