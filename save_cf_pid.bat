@echo off
setlocal EnableDelayedExpansion

REM ========================================
REM  CLOUDFLARE PID SAVER - Centralized
REM ========================================
REM
REM This script maps Cloudflare processes to their corresponding nginx streams
REM by using metrics ports (127.0.0.1:202XX) which are created in sequential order
REM
REM Usage: save_cf_pid.bat PORT1 PORT2 PORT3 ...
REM Example: save_cf_pid.bat 1935 1937 1941
REM
REM The script will:
REM 1. Wait for Cloudflare metrics ports to be ready
REM 2. Get all metrics ports sorted in ascending order
REM 3. Match each port with corresponding PID
REM 4. Save PID to nginx_XXXX\logs\cloudflare.pid
REM ========================================

REM Check if parameters provided
if "%~1"=="" (
    echo [ERROR] No ports specified!
    echo Usage: save_cf_pid.bat PORT1 PORT2 ...
    exit /b 1
)

REM Wait for Cloudflare metrics ports to be fully established
echo [INFO] Waiting for Cloudflare metrics ports to establish...
timeout /t 3 /nobreak >nul

REM Build array of ports from parameters
set "PORT_LIST=%*"
set "PORT_COUNT=0"
for %%p in (%PORT_LIST%) do (
    set /a PORT_COUNT+=1
    set "PORT_!PORT_COUNT!=%%p"
)

echo [INFO] Processing %PORT_COUNT% stream(s): %PORT_LIST%
echo.

REM Get sorted list of metrics ports and their PIDs
REM Metrics ports are 127.0.0.1:202XX and are created in sequential order
set "PID_INDEX=0"
for /f "tokens=2,5" %%a in ('netstat -ano ^| findstr "127.0.0.1:202" ^| findstr "LISTENING" ^| sort') do (
    set /a PID_INDEX+=1
    set "PID_!PID_INDEX!=%%b"
    echo [DEBUG] Metrics port %%a ^(20%%a:~-3%%^) mapped to PID %%b
)

echo.
echo [INFO] Found %PID_INDEX% Cloudflare instance(s)
echo.

REM Verify we have matching number of PIDs
if not "%PID_INDEX%"=="%PORT_COUNT%" (
    echo [WARNING] Mismatch: Expected %PORT_COUNT% PIDs, found %PID_INDEX%
    echo [INFO] This may happen if some streams failed to start
    echo.
)

REM Map PIDs to corresponding nginx directories
set "MATCH_COUNT=0"
for /L %%i in (1,1,%PORT_COUNT%) do (
    if defined PORT_%%i (
        if defined PID_%%i (
            REM Write PID without trailing space or newline
            <nul set /p "=!PID_%%i!" > "nginx_!PORT_%%i!\logs\cloudflare.pid"
            echo [OK] Saved PID !PID_%%i! to nginx_!PORT_%%i!\logs\cloudflare.pid
            set /a MATCH_COUNT+=1
        ) else (
            echo [ERROR] No PID found for nginx_!PORT_%%i!
        )
    )
)

echo.
echo ========================================
echo [SUMMARY] Saved %MATCH_COUNT% of %PORT_COUNT% PIDs
echo ========================================

exit /b 0

