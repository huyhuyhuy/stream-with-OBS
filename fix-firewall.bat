@echo off
setlocal EnableDelayedExpansion
title Fix Localhost Firewall for ALL 7 Streams
color 0E
cd /d "%~dp0"

echo ========================================
echo   FIX LOCALHOST FIREWALL - ALL STREAMS
echo   Ports: 1935-1941 / 8080-8086
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

echo [INFO] This will configure Windows Firewall for all 7 streams
echo [INFO] Adding inbound rules for localhost connections
echo.
pause

set "RTMP_PORTS=1935 1936 1937 1938 1939 1940 1941"
set "HTTP_PORTS=8080 8081 8082 8083 8084 8085 8086"
set "ADDED=0"
set "EXISTED=0"

echo.
echo ========================================
echo   CONFIGURING RTMP PORTS (1935-1941)
echo ========================================
echo.

for %%p in (%RTMP_PORTS%) do (
    set "RULE_NAME=NGINX-RTMP-RTMP-%%p"
    
    REM Check if rule exists
    netsh advfirewall firewall show rule name="!RULE_NAME!" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [EXISTS] Port %%p - Rule already exists
        set /a EXISTED+=1
    ) else (
        REM Add new rule
        netsh advfirewall firewall add rule name="!RULE_NAME!" dir=in action=allow protocol=TCP localport=%%p >nul 2>&1
        if !errorlevel! equ 0 (
            echo [ADDED] Port %%p - Firewall rule created
            set /a ADDED+=1
        ) else (
            echo [ERROR] Port %%p - Failed to create rule
        )
    )
)

echo.
echo ========================================
echo   CONFIGURING HTTP PORTS (8080-8086)
echo ========================================
echo.

for %%p in (%HTTP_PORTS%) do (
    set "RULE_NAME=NGINX-RTMP-HTTP-%%p"
    
    REM Check if rule exists
    netsh advfirewall firewall show rule name="!RULE_NAME!" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [EXISTS] Port %%p - Rule already exists
        set /a EXISTED+=1
    ) else (
        REM Add new rule
        netsh advfirewall firewall add rule name="!RULE_NAME!" dir=in action=allow protocol=TCP localport=%%p >nul 2>&1
        if !errorlevel! equ 0 (
            echo [ADDED] Port %%p - Firewall rule created
            set /a ADDED+=1
        ) else (
            echo [ERROR] Port %%p - Failed to create rule
        )
    )
)

echo.
echo ========================================
echo   CONFIGURATION SUMMARY
echo ========================================
echo.
echo Rules added:    !ADDED!
echo Rules existed:  !EXISTED!
echo Total ports:    14 (7 RTMP + 7 HTTP)
echo.
echo ========================================
echo   FIREWALL RULES STATUS
echo ========================================
echo.
echo RTMP Ports:  1935, 1936, 1937, 1938, 1939, 1940, 1941
echo HTTP Ports:  8080, 8081, 8082, 8083, 8084, 8085, 8086
echo.
echo All ports are now allowed through Windows Firewall
echo for localhost connections.
echo.
echo [NOTE] These rules only affect local connections.
echo [NOTE] External access still requires router configuration.
echo.
pause

