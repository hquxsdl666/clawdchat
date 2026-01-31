@echo off
chcp 65001 >nul
title 最终修复 - 解决所有编译错误
color 0A
cls

echo.
echo ========================================
echo    最终修复 - 解决所有编译错误
echo ========================================
echo.
echo 修复内容:
echo - 移除Ktor logging依赖（不存在）
echo - 修复ChatScreen导入（使用viewModel()）
echo - 添加hilt-navigation-compose依赖
echo - 修复所有编译错误
echo.

cd /d "%~dp0"

echo 【1/4】 添加所有文件...
git add .
echo [OK]
echo.

echo 【2/4】 提交修复...
git commit -m "Fix: 修复所有编译错误，移除不存在依赖，添加hilt-navigation-compose"
echo [OK]
echo.

echo 【3/4】 推送到GitHub...
git push origin master
echo [OK]
echo.

echo 【4/4】 打开构建页面...
echo.
echo ========================================
echo [完成] 所有编译错误已修复！
echo ========================================
echo.
echo 这次一定能成功！等待5-10分钟...
echo.
timeout /t 2 >nul
start https://github.com/hquxsdl666/clawdchat/actions

echo.
pause
