@echo off
title NGINX-RTMP Live Streaming Server
color 0A

echo ========================================
echo   NGINX-RTMP LIVE STREAMING SERVER
echo ========================================
echo.

REM Check if nginx is already running
tasklist /fi "imagename eq nginx.exe" 2>NUL | find /i /n "nginx.exe" >NUL
if "%ERRORLEVEL%"=="0" (
    echo [INFO] Nginx is already running, stopping it first...
    nginx.exe -s stop >nul 2>&1
    timeout /t 2 /nobreak >nul
    echo [OK] Nginx stopped
)

echo [STEP 1] Starting Nginx RTMP Server...
start /b nginx.exe
if %errorlevel% neq 0 (
    echo [ERROR] Failed to start Nginx!
    pause
    exit /b 1
)
timeout /t 3 /nobreak >nul
echo [OK] Nginx RTMP Server started on port 1935

echo [STEP 2] Starting HTTP Server...
echo [OK] HTTP Server started on port 8080

echo [STEP 3] Creating necessary directories...
if not exist "html\hls" mkdir "html\hls" >nul 2>&1
if not exist "html\hls\live" mkdir "html\hls\live" >nul 2>&1
if not exist "html\dash" mkdir "html\dash" >nul 2>&1
if not exist "html\recordings" mkdir "html\recordings" >nul 2>&1
echo [OK] Directories created

echo [STEP 4] Starting HLS file sync process...
start /min cmd /c "%~dp0sync-hls-continuous.bat"
echo [OK] HLS sync process started

echo.
echo ========================================
echo          SERVER STATUS
echo ========================================
echo [✓] RTMP Server: rtmp://localhost:1935/live
echo [✓] HTTP Server: http://localhost:8080
echo [✓] Live Stream: http://localhost:8080/hls/live.m3u8
echo [✓] Statistics: http://localhost:8080/stat
echo [✓] HLS Sync: Running in background
echo.
echo ========================================
echo          OBS SETTINGS
echo ========================================
echo Server: rtmp://localhost:1935/live
echo Stream Key: live (or any name you want)
echo.
echo ========================================
echo          SHARE LINKS
echo ========================================
echo Local: http://localhost:8080
echo.
echo To expose to internet, run one of these:
echo - ngrok http 8080
echo - ssh -R 80:localhost:8080 serveo.net
echo - cloudflared tunnel --url http://localhost:8080
echo.
echo ========================================
echo Press any key to open monitoring...
pause >nul

REM Open monitoring tools
echo.
echo [INFO] Opening monitoring tools...
start http://localhost:8080
start http://localhost:8080/stat

echo.
echo [INFO] Server is running!
echo [INFO] HLS sync is running in background
echo [INFO] Press Ctrl+C to stop or close this window
echo.

REM Keep the window open and show status
:monitor
echo [%date% %time%] Server running... (Press Ctrl+C to stop)
timeout /t 10 /nobreak >nul
goto monitor
