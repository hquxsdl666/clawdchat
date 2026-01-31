@echo off
chcp 65001 >nul
title 查看GitHub构建错误
color 0E
cls

echo.
echo ========================================
echo    如何查看GitHub构建错误详情
echo ========================================
echo.
echo 步骤1: 打开构建页面
echo -------------------------------
echo 访问: https://github.com/hquxsdl666/clawdchat/actions
echo.

echo 步骤2: 点击失败的任务
echo -------------------------------
echo 1. 点击红色的 X 标记
echo 2. 点击 "Build APK" 任务
echo 3. 展开 "Build Debug APK" 步骤
echo 4. 查看红色错误信息
echo.

echo 步骤3: 常见错误及解决
echo -------------------------------
echo.
echo 错误1: gradlew: Permission denied
echo 解决: 已修复，已添加 chmod +x gradlew
echo.
echo 错误2: Could not find gradle-wrapper.jar
echo 解决: 缺少wrapper jar文件
echo.
echo 错误3: OutOfMemoryError
echo 解决: 已添加内存配置 -Xmx4g
echo.
echo 错误4: Kotlin compilation error
echo 解决: 需要修复代码语法错误
echo.

echo ========================================
echo 按任意键打开GitHub Actions页面...
echo ========================================
pause >nul

start https://github.com/hquxsdl666/clawdchat/actions
