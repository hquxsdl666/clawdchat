@echo off
chcp 65001 >nul
title 修复版本并重新推送
color 0A
cls

echo.
echo ========================================
echo    修复构建问题并重新推送
echo ========================================
echo.

cd /d "%~dp0"

echo 【修复内容】
echo - 降级Kotlin到1.9.22 (更稳定)
echo - 降级AGP到8.2.2
echo - 使用简化的GitHub Actions配置
echo.

echo 【1/3】 添加所有修复文件...
git add .
git add gradle/wrapper/gradle-wrapper.jar 2>nul
echo [OK]
echo.

echo 【2/3】 提交修复...
git commit -m "Fix: 降级Kotlin版本到1.9.22，修复构建问题"
echo [OK]
echo.

echo 【3/3】 推送到GitHub...
git push origin master
echo [OK]
echo.

echo ========================================
echo [完成] 修复已推送！
echo ========================================
echo.
echo 请等待5-10分钟查看构建结果
echo.
timeout /t 2 >nul
start https://github.com/hquxsdl666/clawdchat/actions

echo.
pause
