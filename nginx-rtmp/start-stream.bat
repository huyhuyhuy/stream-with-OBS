@echo off
setlocal EnableDelayedExpansion
title NGINX-RTMP Live Streaming + Cloudflare Tunnel
color 0A
cd /d "%~dp0"

echo ========================================
echo   LIVE STREAMING SERVER + PUBLIC TUNNEL
echo ========================================
echo.

REM Create directories
if not exist "html\hls" mkdir "html\hls" >nul 2>&1
if not exist "html\dash" mkdir "html\dash" >nul 2>&1
if not exist "html\recordings" mkdir "html\recordings" >nul 2>&1
if not exist "logs" mkdir "logs" >nul 2>&1
if not exist "temp" mkdir "temp" >nul 2>&1

REM Configure Windows Firewall
echo [SETUP] Configuring Windows Firewall...
netsh advfirewall firewall show rule name="NGINX-RTMP-HTTP" >nul 2>&1
if %errorlevel% neq 0 (
    netsh advfirewall firewall add rule name="NGINX-RTMP-HTTP" dir=in action=allow protocol=TCP localport=8081 >nul 2>&1
    if %errorlevel% equ 0 echo [OK] HTTP firewall rule added
)

netsh advfirewall firewall show rule name="NGINX-RTMP-RTMP" >nul 2>&1
if %errorlevel% neq 0 (
    netsh advfirewall firewall add rule name="NGINX-RTMP-RTMP" dir=in action=allow protocol=TCP localport=1936 >nul 2>&1
    if %errorlevel% equ 0 echo [OK] RTMP firewall rule added
)

REM Test nginx configuration
echo [CHECK] Testing nginx configuration...
.\nginx.exe -t >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Nginx configuration has errors!
    .\nginx.exe -t
    pause
    exit /b 1
)
echo [OK] Nginx configuration is valid

REM Stop any running nginx processes
tasklist /fi "imagename eq nginx.exe" 2>NUL | find /i /n "nginx.exe" >NUL
if "%ERRORLEVEL%"=="0" (
    echo [INFO] Stopping existing nginx processes...
    .\nginx.exe -s stop >nul 2>&1
    timeout /t 2 /nobreak >nul
    taskkill /f /im nginx.exe >nul 2>&1
)

REM Start nginx
echo [START] Starting Nginx RTMP Server...
start /b .\nginx.exe
timeout /t 3 /nobreak >nul

REM Verify nginx started
tasklist /fi "imagename eq nginx.exe" 2>NUL | find /i /n "nginx.exe" >NUL
if "%ERRORLEVEL%"=="0" (
    echo [OK] Nginx RTMP Server started successfully
) else (
    echo [ERROR] Nginx failed to start!
    pause
    exit /b 1
)

echo.
echo ========================================
echo          LOCAL SERVER READY
echo ========================================
echo [✓] RTMP Server: rtmp://localhost:1936/live
echo [✓] HTTP Server: http://localhost:8081
echo [✓] Live Stream: http://localhost:8081/hls/live.m3u8
echo [✓] Statistics: http://localhost:8081/stat
echo.

REM Check if cloudflared exists
if not exist "cloudflared.exe" (
    echo [ERROR] cloudflared.exe not found!
    echo [INFO] Please download cloudflared.exe to this folder
    echo [URL] https://github.com/cloudflare/cloudflared/releases/latest
    pause
    exit /b 1
)

echo ========================================
echo        STARTING PUBLIC TUNNEL
echo ========================================
echo [INFO] Creating Cloudflare public tunnel...
echo [INFO] This will create a FREE public HTTPS URL
echo.

REM Test local server first
powershell -Command "try { Invoke-WebRequest -Uri 'http://localhost:8081/health' -TimeoutSec 5 -UseBasicParsing | Out-Null; Write-Host '[OK] Local server responding' } catch { Write-Host '[ERROR] Local server not responding'; exit 1 }"
if %errorlevel% neq 0 (
    echo [ERROR] Local server not ready
    pause
    exit /b 1
)

echo [START] Starting Cloudflare tunnel...
echo [INFO] Look for your public URL below:
echo.

REM Start cloudflared tunnel
.\cloudflared.exe tunnel --url localhost:8081

echo.
echo ========================================
echo         TUNNEL DISCONNECTED
echo ========================================
echo.
echo [INFO] Cloudflare tunnel has stopped
echo [RESTART] To restart everything: start-stream.bat
echo [STOP ONLY] To stop nginx only: stop.bat
echo.
pause
