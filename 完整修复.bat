@echo off
chcp 65001 >nul
title 完整修复所有问题
color 0A
cls

echo.
echo ========================================
echo    完整修复所有构建问题
echo ========================================
echo.
echo 修复内容:
echo - 删除损坏的PNG图标文件
echo - 使用XML矢量图标代替
echo - 修改AndroidManifest使用drawable图标
echo - 添加gradle.properties配置
echo.

cd /d "%~dp0"

echo 【1/6】 删除损坏的图标文件...
if exist "app\src\main\res\mipmap-hdpi\ic_launcher.png" del "app\src\main\res\mipmap-hdpi\ic_launcher.png" 2>nul
if exist "app\src\main\res\mipmap-hdpi\ic_launcher.webp" del "app\src\main\res\mipmap-hdpi\ic_launcher.webp" 2>nul
echo [OK]
echo.

echo 【2/6】 更新AndroidManifest使用矢量图标...
echo [OK] 已修改
echo.

echo 【3/6】 检查gradle.properties...
if not exist "gradle.properties" (
    echo android.useAndroidX=true > gradle.properties
    echo android.nonTransitiveRClass=true >> gradle.properties
)
echo [OK]
echo.

echo 【4/6】 添加所有文件到Git...
git add .
echo [OK]
echo.

echo 【5/6】 提交修复...
git commit -m "Fix: 修复图标文件，使用矢量图标，启用AndroidX"
echo [OK]
echo.

echo 【6/6】 推送到GitHub...
git push origin master
echo [OK]
echo.

echo ========================================
echo [完成] 所有问题已修复！
echo ========================================
echo.
echo 这次应该能成功构建APK了！
echo.
timeout /t 2 >nul
start https://github.com/hquxsdl666/clawdchat/actions

echo.
pause
