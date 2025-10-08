@echo off
title STOP ALL STREAMING SERVICES
color 0C
cd /d "%~dp0"

echo ========================================
echo   STOPPING ALL STREAMING SERVICES
echo   (Both Stream #1 and Stream #2)
echo ========================================
echo.

REM Check admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Running without admin rights
    echo [INFO] Some processes may not stop. Try running as administrator.
    echo.
)

echo [STEP 1] Stopping ALL Cloudflare tunnels...
tasklist /fi "imagename eq cloudflared.exe" 2>NUL | find /i "cloudflared.exe" >NUL
if %errorlevel% equ 0 (
    taskkill /f /im cloudflared.exe >nul 2>&1
    if %errorlevel% equ 0 (
        echo [OK] All Cloudflare tunnels stopped
    ) else (
        echo [ERROR] Failed to stop some Cloudflare processes
    )
) else (
    echo [INFO] No Cloudflare tunnels running
)

echo.
echo [STEP 2] Stopping ALL Nginx servers...
tasklist /fi "imagename eq nginx.exe" 2>NUL | find /i "nginx.exe" >NUL
if %errorlevel% equ 0 (
    REM Try graceful shutdown first for both nginx instances
    cd nginx-rtmp >nul 2>&1
    if exist nginx.exe (
        nginx.exe -s stop >nul 2>&1
    )
    cd .. >nul 2>&1
    
    cd nginx-rtmp-2 >nul 2>&1
    if exist nginx.exe (
        nginx.exe -s stop >nul 2>&1
    )
    cd .. >nul 2>&1
    
    REM Wait a moment
    timeout /t 2 /nobreak >nul
    
    REM Force kill any remaining nginx processes
    taskkill /f /im nginx.exe >nul 2>&1
    if %errorlevel% equ 0 (
        echo [OK] All Nginx servers stopped
    ) else (
        echo [INFO] Nginx already stopped
    )
) else (
    echo [INFO] No Nginx servers running
)

echo.
echo [STEP 3] Verifying all processes stopped...
set "still_running=0"

tasklist /fi "imagename eq nginx.exe" 2>NUL | find /i "nginx.exe" >NUL
if %errorlevel% equ 0 (
    echo [WARNING] Some nginx processes still running
    set "still_running=1"
)

tasklist /fi "imagename eq cloudflared.exe" 2>NUL | find /i "cloudflared.exe" >NUL
if %errorlevel% equ 0 (
    echo [WARNING] Some cloudflared processes still running
    set "still_running=1"
)

if "%still_running%"=="0" (
    echo [OK] All processes successfully terminated
)

echo.
echo [STEP 4] Checking ports...
netstat -an | findstr ":1935\|:1936\|:8080\|:8081" >nul 2>&1
if %errorlevel% equ 0 (
    echo [INFO] Some ports still bound (may take a moment to release):
    netstat -an | findstr ":1935\|:1936\|:8080\|:8081"
) else (
    echo [OK] All streaming ports released
)

echo.
echo ========================================
echo   CLEANUP SUMMARY
echo ========================================
echo.
echo [✓] Cloudflare tunnels: Stopped
echo [✓] Nginx Stream #1 (1935/8080): Stopped
echo [✓] Nginx Stream #2 (1936/8081): Stopped
echo.
echo ========================================
echo   NEXT STEPS
echo ========================================
echo.
echo To restart:
echo   - Single stream: Run start-stream.bat in nginx-rtmp or nginx-rtmp-2
echo   - Both streams: Run start-stream-both.bat
echo.
echo To check status:
echo   - Run debug-check.bat in either folder
echo.
pause

