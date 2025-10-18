@echo off
setlocal EnableDelayedExpansion
title MULTI STREAM LAUNCHER - Interactive Mode
color 0D
cd /d "%~dp0"

:MENU
cls
echo ========================================
echo   MULTI STREAM LAUNCHER
echo   Interactive Selection Mode
echo ========================================
echo.
echo Available Streams:
echo.
echo   [1] Stream 1935 - rtmp://localhost:1935/stream1935 (HTTP: 8080)
echo   [2] Stream 1936 - rtmp://localhost:1936/stream1936 (HTTP: 8081)
echo   [3] Stream 1937 - rtmp://localhost:1937/stream1937 (HTTP: 8082)
echo   [4] Stream 1938 - rtmp://localhost:1938/stream1938 (HTTP: 8083)
echo   [5] Stream 1939 - rtmp://localhost:1939/stream1939 (HTTP: 8084)
echo   [6] Stream 1940 - rtmp://localhost:1940/stream1940 (HTTP: 8085)
echo   [7] Stream 1941 - rtmp://localhost:1941/stream1941 (HTTP: 8086)
echo.
echo   [A] Start ALL 7 Streams
echo   [X] Exit
echo.
echo ========================================
echo.
set /p "CHOICE=Enter your choice (1-7, A for all, X to exit): "

REM Convert to uppercase
if /i "%CHOICE%"=="a" set "CHOICE=A"
if /i "%CHOICE%"=="x" set "CHOICE=X"

REM Check admin rights first
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] This script requires Administrator rights!
    echo [INFO] Right-click and select "Run as administrator"
    pause
    exit /b 1
)

REM Handle choice
if "%CHOICE%"=="X" (
    echo.
    echo Exiting...
    exit /b 0
)

if "%CHOICE%"=="A" goto START_ALL

REM Single stream selection
if "%CHOICE%"=="1" set "PORT=1935" & goto START_SINGLE
if "%CHOICE%"=="2" set "PORT=1936" & goto START_SINGLE
if "%CHOICE%"=="3" set "PORT=1937" & goto START_SINGLE
if "%CHOICE%"=="4" set "PORT=1938" & goto START_SINGLE
if "%CHOICE%"=="5" set "PORT=1939" & goto START_SINGLE
if "%CHOICE%"=="6" set "PORT=1940" & goto START_SINGLE
if "%CHOICE%"=="7" set "PORT=1941" & goto START_SINGLE

REM Invalid choice
echo.
echo [ERROR] Invalid choice! Please try again.
timeout /t 2 >nul
goto MENU

:START_SINGLE
cls
echo ========================================
echo   STARTING STREAM %PORT%
echo ========================================
echo.

if not exist "nginx_%PORT%\start_%PORT%.bat" (
    echo [ERROR] nginx_%PORT% not found!
    pause
    goto MENU
)

REM Add firewall rules for this stream
echo [SETUP] Configuring Windows Firewall for Stream %PORT%...
call :ADD_FIREWALL_SINGLE %PORT%
echo.

echo [INFO] Launching Stream %PORT% in new window...
start "NGINX-RTMP %PORT%" cmd /k "cd /d nginx_%PORT% && start_%PORT%.bat"

echo.
echo [OK] Stream %PORT% window opened!
echo.
echo Check the new window for Cloudflare URL.
echo.
echo OBS Configuration:
echo   Server: rtmp://localhost:%PORT%/stream%PORT%
echo   Key: stream%PORT%
echo.
pause

REM Ask if want to start another
echo.
set /p "ANOTHER=Start another stream? (Y/N): "
if /i "%ANOTHER%"=="Y" goto MENU
exit /b 0

:START_ALL
cls
echo ========================================
echo   STARTING ALL 7 STREAMS
echo ========================================
echo.
echo [INFO] This will start 7 independent streams:
echo.
echo   Stream 1: rtmp://localhost:1935/stream1935 (HTTP: 8080)
echo   Stream 2: rtmp://localhost:1936/stream1936 (HTTP: 8081)
echo   Stream 3: rtmp://localhost:1937/stream1937 (HTTP: 8082)
echo   Stream 4: rtmp://localhost:1938/stream1938 (HTTP: 8083)
echo   Stream 5: rtmp://localhost:1939/stream1939 (HTTP: 8084)
echo   Stream 6: rtmp://localhost:1940/stream1940 (HTTP: 8085)
echo   Stream 7: rtmp://localhost:1941/stream1941 (HTTP: 8086)
echo.
echo [INFO] Seven separate command windows will open.
echo [INFO] Each will show its own Cloudflare tunnel URL.
echo.
echo [WARNING] This will consume significant system resources:
echo   - CPU: ~60-80%% (i9 recommended)
echo   - RAM: ~20-25 GB
echo   - Bandwidth: ~30-40 Mbps upload
echo.
pause

echo.
echo ========================================
echo   CONFIGURING WINDOWS FIREWALL
echo ========================================
echo [SETUP] Adding firewall rules for all 7 streams...
call :ADD_FIREWALL_ALL
echo [OK] Firewall configuration complete!
echo.
timeout /t 2 /nobreak >nul

set "PORTS=1935 1936 1937 1938 1939 1940 1941"
set "INDEX=1"

for %%p in (%PORTS%) do (
    echo.
    echo ========================================
    echo   STARTING STREAM !INDEX! (Port %%p)
    echo ========================================
    echo [START] Launching Stream !INDEX! in new window...
    start "NGINX-RTMP %%p" cmd /k "cd /d nginx_%%p && start_%%p.bat"
    
    REM Wait between starts to avoid resource spike
    if !INDEX! LSS 7 (
        echo [WAIT] Waiting 8 seconds before starting next stream...
        timeout /t 8 /nobreak >nul
    )
    
    set /a INDEX+=1
)

echo.
echo ========================================
echo   ALL 7 STREAMS LAUNCHING
echo ========================================
echo.
echo [✓] Stream 1 window opened (nginx_1935)
echo [✓] Stream 2 window opened (nginx_1936)
echo [✓] Stream 3 window opened (nginx_1937)
echo [✓] Stream 4 window opened (nginx_1938)
echo [✓] Stream 5 window opened (nginx_1939)
echo [✓] Stream 6 window opened (nginx_1940)
echo [✓] Stream 7 window opened (nginx_1941)
echo.
echo [INFO] Check the seven new windows for Cloudflare URLs
echo [INFO] It may take 1-2 minutes for all to initialize
echo.
echo ========================================
echo   OBS CONFIGURATION
echo ========================================
echo.
echo OBS #1: rtmp://localhost:1935/stream1935 (key: stream1935)
echo OBS #2: rtmp://localhost:1936/stream1936 (key: stream1936)
echo OBS #3: rtmp://localhost:1937/stream1937 (key: stream1937)
echo OBS #4: rtmp://localhost:1938/stream1938 (key: stream1938)
echo OBS #5: rtmp://localhost:1939/stream1939 (key: stream1939)
echo OBS #6: rtmp://localhost:1940/stream1940 (key: stream1940)
echo OBS #7: rtmp://localhost:1941/stream1941 (key: stream1941)
echo.
echo ========================================
echo   IMPORTANT NOTES
echo ========================================
echo.
echo 1. Wait for ALL Cloudflare tunnels to show URLs
echo 2. Each stream will have its own unique URL
echo 3. Configure 7 separate OBS instances (or use OBS portable)
echo 4. To stop: Use stop-all.bat or close windows individually
echo 5. Monitor CPU/RAM usage - system should handle it well
echo.
echo [TIP] Keep this window open for reference
echo.
pause
exit /b 0

REM ========================================
REM   FIREWALL CONFIGURATION SUBROUTINES
REM ========================================

:ADD_FIREWALL_SINGLE
REM Add firewall rules for a single port
REM Usage: call :ADD_FIREWALL_SINGLE <rtmp_port>
set "RTMP_PORT=%~1"
set /a HTTP_PORT=%RTMP_PORT% - 1935 + 8080

REM Add RTMP rule
netsh advfirewall firewall show rule name="NGINX-RTMP-RTMP-%RTMP_PORT%" >nul 2>&1
if %errorlevel% neq 0 (
    netsh advfirewall firewall add rule name="NGINX-RTMP-RTMP-%RTMP_PORT%" dir=in action=allow protocol=TCP localport=%RTMP_PORT% >nul 2>&1
    if %errorlevel% equ 0 (
        echo [OK] RTMP port %RTMP_PORT% - Firewall rule added
    )
) else (
    echo [INFO] RTMP port %RTMP_PORT% - Rule already exists
)

REM Add HTTP rule
netsh advfirewall firewall show rule name="NGINX-RTMP-HTTP-%RTMP_PORT%" >nul 2>&1
if %errorlevel% neq 0 (
    netsh advfirewall firewall add rule name="NGINX-RTMP-HTTP-%RTMP_PORT%" dir=in action=allow protocol=TCP localport=%HTTP_PORT% >nul 2>&1
    if %errorlevel% equ 0 (
        echo [OK] HTTP port %HTTP_PORT% - Firewall rule added
    )
) else (
    echo [INFO] HTTP port %HTTP_PORT% - Rule already exists
)

exit /b 0

:ADD_FIREWALL_ALL
REM Add firewall rules for all 7 streams
set "ALL_RTMP=1935 1936 1937 1938 1939 1940 1941"
set "ADDED=0"
set "EXISTED=0"

for %%p in (%ALL_RTMP%) do (
    set "RTMP=%%p"
    set /a HTTP=%%p - 1935 + 8080
    
    REM Check RTMP rule
    netsh advfirewall firewall show rule name="NGINX-RTMP-RTMP-%%p" >nul 2>&1
    if !errorlevel! neq 0 (
        netsh advfirewall firewall add rule name="NGINX-RTMP-RTMP-%%p" dir=in action=allow protocol=TCP localport=%%p >nul 2>&1
        if !errorlevel! equ 0 set /a ADDED+=1
    ) else (
        set /a EXISTED+=1
    )
    
    REM Check HTTP rule
    netsh advfirewall firewall show rule name="NGINX-RTMP-HTTP-%%p" >nul 2>&1
    if !errorlevel! neq 0 (
        netsh advfirewall firewall add rule name="NGINX-RTMP-HTTP-%%p" dir=in action=allow protocol=TCP localport=!HTTP! >nul 2>&1
        if !errorlevel! equ 0 set /a ADDED+=1
    ) else (
        set /a EXISTED+=1
    )
)

echo [INFO] Firewall rules: %ADDED% added, %EXISTED% already existed
exit /b 0
