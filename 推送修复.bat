@echo off
chcp 65001 >nul
title 推送修复版本
color 0A
cls

echo.
echo ========================================
echo    修复Compose编译器问题
echo ========================================
echo.
echo 修复内容:
echo - 移除不兼容的compose-compiler插件
echo - 使用composeOptions.kotlinCompilerExtensionVersion
echo - 修复Kotlin 1.9.22兼容性
echo.

cd /d "%~dp0"

echo 【1/3】 添加文件...
git add .
echo [OK]
echo.

echo 【2/3】 提交修复...
git commit -m "Fix: 修复Compose编译器配置，使用kotlinCompilerExtensionVersion 1.5.8"
echo [OK]
echo.

echo 【3/3】 推送...
git push origin master
echo [OK]
echo.

echo ========================================
echo [完成] 修复已推送！
echo ========================================
echo.
echo 正在打开Actions页面...
timeout /t 2 >nul
start https://github.com/hquxsdl666/clawdchat/actions

echo.
pause
