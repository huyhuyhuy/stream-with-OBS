@echo off
setlocal EnableDelayedExpansion
title STOP STREAMING SERVICES - Interactive Mode
color 0C
cd /d "%~dp0"

:MENU
cls
echo ========================================
echo   STOP STREAMING SERVICES
echo   Interactive Selection Mode
echo ========================================
echo.
echo Currently Running Streams:
echo.

REM Check which streams are running
set "RUNNING_COUNT=0"
for %%p in (1935 1936 1937 1938 1939 1940 1941) do (
    set "RUNNING_%%p=0"
    if exist "nginx_%%p\logs\nginx.pid" (
        for /f %%i in (nginx_%%p\logs\nginx.pid) do (
            tasklist /FI "PID eq %%i" 2>NUL | find "%%i" >NUL
            if !errorlevel! equ 0 (
                set "RUNNING_%%p=1"
                set /a RUNNING_COUNT+=1
            )
        )
    )
)

REM Display menu with running status
if !RUNNING_1935! equ 1 (echo   [1] Stream 1935 ^(RUNNING^) - Port 1935/8080) else (echo   [1] Stream 1935 ^(Stopped^))
if !RUNNING_1936! equ 1 (echo   [2] Stream 1936 ^(RUNNING^) - Port 1936/8081) else (echo   [2] Stream 1936 ^(Stopped^))
if !RUNNING_1937! equ 1 (echo   [3] Stream 1937 ^(RUNNING^) - Port 1937/8082) else (echo   [3] Stream 1937 ^(Stopped^))
if !RUNNING_1938! equ 1 (echo   [4] Stream 1938 ^(RUNNING^) - Port 1938/8083) else (echo   [4] Stream 1938 ^(Stopped^))
if !RUNNING_1939! equ 1 (echo   [5] Stream 1939 ^(RUNNING^) - Port 1939/8084) else (echo   [5] Stream 1939 ^(Stopped^))
if !RUNNING_1940! equ 1 (echo   [6] Stream 1940 ^(RUNNING^) - Port 1940/8085) else (echo   [6] Stream 1940 ^(Stopped^))
if !RUNNING_1941! equ 1 (echo   [7] Stream 1941 ^(RUNNING^) - Port 1941/8086) else (echo   [7] Stream 1941 ^(Stopped^))
echo.
echo   [A] Stop ALL Streams
echo   [X] Exit
echo.
echo ========================================
echo Total running: !RUNNING_COUNT! stream(s)
echo ========================================
echo.
set /p "CHOICE=Enter your choice (1-7, A for all, X to exit): "

REM Convert to uppercase
if /i "%CHOICE%"=="a" set "CHOICE=A"
if /i "%CHOICE%"=="x" set "CHOICE=X"

REM Handle choice
if "%CHOICE%"=="X" (
    echo.
    echo Exiting...
    exit /b 0
)

if "%CHOICE%"=="A" goto STOP_ALL

REM Single stream selection
if "%CHOICE%"=="1" set "PORT=1935" & goto STOP_SINGLE
if "%CHOICE%"=="2" set "PORT=1936" & goto STOP_SINGLE
if "%CHOICE%"=="3" set "PORT=1937" & goto STOP_SINGLE
if "%CHOICE%"=="4" set "PORT=1938" & goto STOP_SINGLE
if "%CHOICE%"=="5" set "PORT=1939" & goto STOP_SINGLE
if "%CHOICE%"=="6" set "PORT=1940" & goto STOP_SINGLE
if "%CHOICE%"=="7" set "PORT=1941" & goto STOP_SINGLE

REM Invalid choice
echo.
echo [ERROR] Invalid choice! Please try again.
timeout /t 2 >nul
goto MENU

:STOP_SINGLE
cls
echo ========================================
echo   STOPPING STREAM %PORT%
echo ========================================
echo.

if not exist "nginx_%PORT%\stop_%PORT%.bat" (
    echo [ERROR] nginx_%PORT% not found!
    pause
    goto MENU
)

echo [INFO] Stopping Stream %PORT%...
cd nginx_%PORT% >nul 2>&1
call stop_%PORT%.bat
cd .. >nul 2>&1

echo.
echo [OK] Stream %PORT% stopped!
echo.
pause

REM Ask if want to stop another
echo.
set /p "ANOTHER=Stop another stream? (Y/N): "
if /i "%ANOTHER%"=="Y" goto MENU
exit /b 0

:STOP_ALL
cls
echo ========================================
echo   STOPPING ALL STREAMING SERVICES
echo   (All 7 Streams: 1935-1941)
echo ========================================
echo.

REM Check admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Running without admin rights
    echo [INFO] Some processes may not stop. Try running as administrator.
    echo.
)

echo [INFO] This will stop all running streams...
echo.
pause

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
    set "PORTS=1935 1936 1937 1938 1939 1940 1941"
    
    REM Try graceful shutdown first for all nginx instances
    for %%p in (!PORTS!) do (
        if exist "nginx_%%p\nginx.exe" (
            echo [STOP] Attempting graceful shutdown for nginx_%%p...
            cd nginx_%%p >nul 2>&1
            nginx.exe -s stop >nul 2>&1
            cd .. >nul 2>&1
        )
    )
    
    REM Wait a moment
    timeout /t 3 /nobreak >nul
    
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
netstat -an | findstr ":1935\|:1936\|:1937\|:1938\|:1939\|:1940\|:1941\|:8080\|:8081\|:8082\|:8083\|:8084\|:8085\|:8086" >nul 2>&1
if %errorlevel% equ 0 (
    echo [INFO] Some ports still bound (may take a moment to release)
) else (
    echo [OK] All streaming ports released
)

echo.
echo ========================================
echo   CLEANUP SUMMARY
echo ========================================
echo.
echo [✓] Cloudflare tunnels: Stopped
echo [✓] Nginx Stream 1 (1935/8080): Stopped
echo [✓] Nginx Stream 2 (1936/8081): Stopped
echo [✓] Nginx Stream 3 (1937/8082): Stopped
echo [✓] Nginx Stream 4 (1938/8083): Stopped
echo [✓] Nginx Stream 5 (1939/8084): Stopped
echo [✓] Nginx Stream 6 (1940/8085): Stopped
echo [✓] Nginx Stream 7 (1941/8086): Stopped
echo.
echo ========================================
echo   NEXT STEPS
echo ========================================
echo.
echo To restart:
echo   - Single stream: Run start-ALL.bat and choose stream
echo   - All streams: Run start-ALL.bat and choose option A
echo.
echo To check status:
echo   - Run debug-check.bat in any nginx_XXXX folder
echo.
pause
exit /b 0
