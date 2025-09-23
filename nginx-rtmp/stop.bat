@echo off
title Stopping NGINX-RTMP Server + Cloudflare Tunnel
color 0C

REM Change to script directory
cd /d "%~dp0"

echo ========================================
echo   STOPPING STREAMING + TUNNEL
echo ========================================
echo.

echo [STEP 1] Stopping Cloudflare tunnel...
taskkill /f /im cloudflared.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Cloudflare tunnel stopped
) else (
    echo [INFO] No Cloudflare tunnel running
)

echo [STEP 2] Stopping Nginx server...
.\nginx.exe -s stop >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Nginx stopped successfully
) else (
    echo [INFO] Nginx was not running or already stopped
)

echo [STEP 3] Killing any remaining processes...
taskkill /f /im nginx.exe >nul 2>&1
taskkill /f /im cloudflared.exe >nul 2>&1
echo [OK] All processes terminated

echo.
echo ========================================
echo [✓] All services stopped successfully!
echo ========================================
echo [INFO] To restart: start-stream.bat
echo.
pause