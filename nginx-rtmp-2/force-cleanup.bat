@echo off
title Force Cleanup NGINX-RTMP
color 0E

echo ========================================
echo    FORCE CLEANUP NGINX-RTMP PROCESSES
echo ========================================
echo.

echo [STEP 1] Stopping Nginx processes...
taskkill /f /im nginx.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Nginx processes killed
) else (
    echo [INFO] No nginx processes found
)

echo [STEP 2] Stopping all related CMD processes...
taskkill /f /im cmd.exe /fi "WINDOWTITLE eq*nginx*" >nul 2>&1
taskkill /f /im cmd.exe /fi "WINDOWTITLE eq*sync-hls*" >nul 2>&1
taskkill /f /im cmd.exe /fi "WINDOWTITLE eq*streaming*" >nul 2>&1
echo [OK] CMD processes cleaned

echo [STEP 3] Releasing file handles...
timeout /t 2 /nobreak >nul
echo [OK] File handles released

echo [STEP 4] Checking running processes...
echo.
tasklist /fi "imagename eq nginx.exe" 2>NUL | find /i /n "nginx.exe" >NUL
if "%ERRORLEVEL%"=="0" (
    echo [WARNING] Nginx still running!
    tasklist | findstr nginx
) else (
    echo [OK] No nginx processes found
)

echo.
echo ========================================
echo [✓] Cleanup completed!
echo [✓] You can now delete the folder
echo ========================================
echo.
pause
