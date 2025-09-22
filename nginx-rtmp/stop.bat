@echo off
title Stop NGINX-RTMP Server
color 0C

echo ========================================
echo   STOPPING NGINX-RTMP SERVER
echo ========================================
echo.

echo [STEP 1] Stopping Nginx server...
nginx.exe -s stop >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Nginx stopped successfully
) else (
    echo [INFO] Nginx was not running or already stopped
)

echo [STEP 2] Killing any remaining nginx processes...
taskkill /f /im nginx.exe >nul 2>&1
echo [OK] All nginx processes terminated

echo [STEP 3] Stopping HLS sync processes...
taskkill /f /im cmd.exe /fi "WINDOWTITLE eq*sync-hls-continuous*" >nul 2>&1
echo [OK] HLS sync processes stopped

echo.
echo ========================================
echo [✓] All services stopped successfully!
echo ========================================
echo.
pause
