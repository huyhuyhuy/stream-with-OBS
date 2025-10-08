@echo off
setlocal EnableDelayedExpansion
title DUAL STREAM LAUNCHER - Start Both Streams
color 0D
cd /d "%~dp0"

echo ========================================
echo   DUAL STREAM LAUNCHER
echo   Starting BOTH Streaming Servers
echo ========================================
echo.

REM Check admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] This script requires Administrator rights!
    echo [INFO] Right-click and select "Run as administrator"
    pause
    exit /b 1
)

echo [INFO] This will start:
echo   - Stream #1: rtmp://localhost:1935/live  (HTTP: 8080)
echo   - Stream #2: rtmp://localhost:1936/live2 (HTTP: 8081)
echo.
echo [INFO] Two separate command windows will open.
echo [INFO] Each will show its own Cloudflare tunnel URL.
echo.

pause

echo.
echo ========================================
echo   STARTING STREAM #1
echo ========================================
echo [START] Launching Stream #1 in new window...
start "Stream #1 - Port 1935/8080" cmd /k "cd /d nginx-rtmp && start-stream.bat"

echo [WAIT] Waiting 5 seconds before starting Stream #2...
timeout /t 5 /nobreak >nul

echo.
echo ========================================
echo   STARTING STREAM #2
echo ========================================
echo [START] Launching Stream #2 in new window...
start "Stream #2 - Port 1936/8081" cmd /k "cd /d nginx-rtmp-2 && start-stream.bat"

echo.
echo ========================================
echo   BOTH STREAMS LAUNCHING
echo ========================================
echo.
echo [✓] Stream #1 window opened (nginx-rtmp)
echo [✓] Stream #2 window opened (nginx-rtmp-2)
echo.
echo [INFO] Check the two new windows for Cloudflare URLs
echo.
echo ========================================
echo   OBS CONFIGURATION
echo ========================================
echo.
echo OBS #1:
echo   Server: rtmp://localhost:1935/live
echo   Stream Key: live
echo.
echo OBS #2:
echo   Server: rtmp://localhost:1936/live2
echo   Stream Key: live2
echo.
echo ========================================
echo   IMPORTANT NOTES
echo ========================================
echo.
echo 1. Wait for BOTH Cloudflare tunnels to show URLs
echo 2. Each stream will have its own unique URL
echo 3. Configure 2 separate OBS instances
echo 4. To stop: Use stop-all.bat or close both windows
echo.
echo [TIP] Keep this window open for reference
echo.
pause

