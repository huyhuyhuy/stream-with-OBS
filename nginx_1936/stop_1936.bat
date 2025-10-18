@echo off
setlocal EnableDelayedExpansion
title Stopping NGINX-RTMP 1936 (THIS DIRECTORY ONLY)
color 0C

REM Change to script directory
cd /d "%~dp0"

echo ========================================
echo   STOPPING STREAMING (Port 1936) + TUNNEL
echo   (THIS DIRECTORY ONLY - SAFE MODE)
echo ========================================
echo.

REM ============================================
REM STEP 1: Stop Cloudflare tunnel (SMART - only from this directory)
REM ============================================
echo [STEP 1] Looking for Cloudflare tunnel started from THIS directory...
set "CF_STOPPED=0"

REM Get list of all cloudflared.exe PIDs
for /f "skip=3 tokens=2" %%i in ('tasklist /fi "imagename eq cloudflared.exe" 2^>nul') do (
    set "CF_PID=%%i"
    
    REM Skip if PID is not numeric
    echo !CF_PID! | findstr /r "^[0-9][0-9]*$" >nul 2>&1
    if !errorlevel! equ 0 (
        REM Check if this PID's command line contains our directory path
        for /f "tokens=*" %%c in ('wmic process where "ProcessId=!CF_PID!" get CommandLine 2^>nul ^| findstr /i "%~dp0"') do (
            echo [INFO] Found Cloudflare tunnel ^(PID: !CF_PID!^) from this directory
            taskkill /F /PID !CF_PID! >nul 2>&1
            if !errorlevel! equ 0 (
                echo [OK] Cloudflare tunnel stopped ^(PID: !CF_PID!^)
                set "CF_STOPPED=1"
            )
        )
    )
)

if "!CF_STOPPED!"=="0" (
    echo [INFO] No Cloudflare tunnel found from this directory
)

echo.

REM ============================================
REM STEP 2: Stop Nginx (SMART - using PID file)
REM ============================================
echo [STEP 2] Stopping Nginx in THIS directory...

if exist "logs\nginx.pid" (
    echo [INFO] Found nginx PID file: logs\nginx.pid
    
    REM Read master PID from file
    set /p NGINX_PID=<logs\nginx.pid
    
    REM Check if process exists
    tasklist /FI "PID eq !NGINX_PID!" 2>NUL | find "!NGINX_PID!" >NUL
    if !errorlevel! equ 0 (
        echo [INFO] Nginx is running ^(Master PID: !NGINX_PID!^)
        
        REM Try graceful shutdown first (this also stops worker processes)
        echo [INFO] Attempting graceful shutdown...
        .\nginx.exe -s stop >nul 2>&1
        
        REM Wait for graceful shutdown
        timeout /t 2 /nobreak >nul
        
        REM Check if still running
        tasklist /FI "PID eq !NGINX_PID!" 2>NUL | find "!NGINX_PID!" >NUL
        if !errorlevel! equ 0 (
            echo [WARNING] Graceful shutdown failed, force killing...
            taskkill /F /PID !NGINX_PID! >nul 2>&1
            
            REM Also kill any worker processes (they have different PIDs)
            for /f "tokens=2" %%w in ('tasklist /fi "imagename eq nginx.exe" /fo table /nh 2^>nul') do (
                if not "%%w"=="!NGINX_PID!" (
                    REM Check if this is a worker of our master
                    wmic process where "ProcessId=%%w" get ParentProcessId 2>nul | findstr "!NGINX_PID!" >nul
                    if !errorlevel! equ 0 (
                        echo [INFO] Killing worker process ^(PID: %%w^)
                        taskkill /F /PID %%w >nul 2>&1
                    )
                )
            )
        )
        
        echo [OK] Nginx stopped successfully
    ) else (
        echo [INFO] Nginx process not found ^(PID !NGINX_PID! already stopped^)
    )
    
    REM Clean up PID file
    del logs\nginx.pid >nul 2>&1
    echo [INFO] Cleaned up PID file
) else (
    echo [INFO] No nginx PID file found
    echo [INFO] Attempting graceful shutdown anyway...
    .\nginx.exe -s stop >nul 2>&1
    if !errorlevel! equ 0 (
        echo [OK] Nginx stopped successfully
    ) else (
        echo [INFO] Nginx was not running
    )
)

echo.
echo ========================================
echo [✓] Services in THIS directory stopped!
echo ========================================
echo.
echo [IMPORTANT] Other streams are NOT affected:
echo   - nginx-rtmp and nginx-rtmp-2 are independent
echo   - Only THIS directory's services were stopped
echo   - Other directories are still running normally
echo.
echo [INFO] To restart this stream: start-stream.bat
echo [INFO] To stop ALL streams: Use stop-all.bat in parent directory
echo.
pause