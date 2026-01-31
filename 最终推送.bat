@echo off
chcp 65001 >nul
title 最终推送 - 修复构建
color 0A
cls

echo.
echo ========================================
echo    最终推送 - 包含所有必要文件
echo ========================================
echo.

cd /d "%~dp0"

echo [1/5] 检查必要文件...
if exist "gradle\wrapper\gradle-wrapper.jar" (
    echo [OK] gradle-wrapper.jar 存在
) else (
    echo [错误] 缺少 gradle-wrapper.jar
    echo 请先运行: 检查并修复.bat
    pause
    exit /b 1
)
echo.

echo [2/5] 添加所有文件...
git add gradle/wrapper/gradle-wrapper.jar
git add .
echo [OK]
echo.

echo [3/5] 提交更改...
git commit -m "Fix: Add gradle-wrapper.jar for CI build"
echo [OK]
echo.

echo [4/5] 推送到GitHub...
git push origin master
echo [OK]
echo.

echo [5/5] 打开构建页面...
echo.
echo ========================================
echo [完成] 已推送！等待构建...
echo ========================================
echo.
echo 构建时间: 5-10分钟
echo.
timeout /t 3 >nul
start https://github.com/hquxsdl666/clawdchat/actions

echo 按任意键退出...
pause >nul
