@echo off
setlocal EnableDelayedExpansion
title NGINX-RTMP 1938
color 0A
cd /d "%~dp0"

echo ========================================
echo   LIVE STREAMING SERVER + PUBLIC TUNNEL
echo ========================================
echo.

REM Create directories
if not exist "html\hls1938" mkdir "html\hls1938" >nul 2>&1
if not exist "html\dash1938" mkdir "html\dash1938" >nul 2>&1
if not exist "html\recordings" mkdir "html\recordings" >nul 2>&1
if not exist "logs" mkdir "logs" >nul 2>&1
if not exist "temp" mkdir "temp" >nul 2>&1

REM Configure Windows Firewall
echo [SETUP] Configuring Windows Firewall...
netsh advfirewall firewall show rule name="NGINX-RTMP-HTTP-1938" >nul 2>&1
if %errorlevel% neq 0 (
    netsh advfirewall firewall add rule name="NGINX-RTMP-HTTP-1938" dir=in action=allow protocol=TCP localport=8083 >nul 2>&1
    if %errorlevel% equ 0 echo [OK] HTTP firewall rule added
)

netsh advfirewall firewall show rule name="NGINX-RTMP-RTMP-1938" >nul 2>&1
if %errorlevel% neq 0 (
    netsh advfirewall firewall add rule name="NGINX-RTMP-RTMP-1938" dir=in action=allow protocol=TCP localport=1938 >nul 2>&1
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
echo [✓] RTMP Server: rtmp://localhost:1938/stream1938
echo [✓] HTTP Server: http://localhost:8083
echo [✓] Live Stream: http://localhost:8083/hls1938/stream1938.m3u8
echo [✓] Statistics: http://localhost:8083/stat
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
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:8083/' -TimeoutSec 3 -UseBasicParsing -ErrorAction Stop; Write-Host '[OK] Local server responding' } catch { Write-Host '[WARNING] Local server check failed, but continuing...' }"

REM Clean old Cloudflare PID file
if exist "logs\cloudflare.pid" del logs\cloudflare.pid >nul 2>&1

echo [START] Starting Cloudflare tunnel...
echo [INFO] Look for your public URL below:
echo [INFO] PID will be saved to logs\cloudflare.pid for safe stopping
echo.

REM Start cloudflared tunnel
.\cloudflared.exe tunnel --url localhost:8083

echo.
echo ========================================
echo         TUNNEL DISCONNECTED
echo ========================================
echo.
echo [INFO] Cloudflare tunnel has stopped
echo [RESTART] To restart everything: start_1938.bat
echo [STOP ONLY] To stop nginx only: stop_1938.bat
echo.
echo [INFO] This window will close in 2 seconds...
echo [TIP] Press any key to close immediately
timeout /t 2
exit
