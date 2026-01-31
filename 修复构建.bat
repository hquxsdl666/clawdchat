@echo off
chcp 65001 >nul
title 修复构建错误
color 0C
cls

echo.
echo ========================================
echo    构建失败修复工具
echo ========================================
echo.
echo 常见问题：
echo 1. Gradle版本问题
echo 2. Java版本不兼容
echo 3. 依赖下载失败
echo.
echo 正在修复...
echo.

REM 修复1: 更新Gradle Wrapper
echo [1/3] 检查Gradle配置...
if not exist "gradle\wrapper\gradle-wrapper.properties" (
    echo 创建Gradle Wrapper配置...
    mkdir "gradle\wrapper" 2>nul
    (
        echo distributionBase=GRADLE_USER_HOME
        echo distributionPath=wrapper/dists
        echo distributionUrl=https\://services.gradle.org/distributions/gradle-8.4-bin.zip
        echo networkTimeout=10000
        echo validateDistributionUrl=true
        echo zipStoreBase=GRADLE_USER_HOME
        echo zipStorePath=wrapper/dists
    ) > "gradle\wrapper\gradle-wrapper.properties"
)
echo [OK]
echo.

REM 修复2: 添加gradle-wrapper.jar
echo [2/3] 检查Gradle Wrapper JAR...
if not exist "gradle\wrapper\gradle-wrapper.jar" (
    echo 警告: 缺少gradle-wrapper.jar
    echo 请从以下地址下载：
    echo https://raw.githubusercontent.com/gradle/gradle/v8.4.0/gradle/wrapper/gradle-wrapper.jar
    echo.
    echo 或者使用本地Gradle构建：
    echo gradle assembleDebug
)
echo [OK]
echo.

REM 修复3: 清理并重新提交
echo [3/3] 准备重新推送...
echo.
echo 执行以下操作：
echo 1. 删除.github/workflows/build.yml 中的错误配置
echo 2. 使用简化的构建配置
echo 3. 重新推送代码
echo.

pause
