@echo off
title Fix Localhost Firewall for Serveo
color 0E

echo ========================================
echo   FIX LOCALHOST FIREWALL FOR SERVEO
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

echo [INFO] Adding localhost firewall rules for port 8081...

REM Allow inbound connections to port 8081 from localhost
netsh advfirewall firewall add rule name="NGINX-RTMP-2 Localhost Inbound" dir=in action=allow protocol=TCP localport=8081 remoteip=127.0.0.1 >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Localhost inbound rule added
) else (
    echo [INFO] Localhost inbound rule already exists or failed
)

REM Allow inbound connections to port 8081 from any local address
netsh advfirewall firewall add rule name="NGINX-RTMP-2 Local Network Inbound" dir=in action=allow protocol=TCP localport=8081 remoteip=localsubnet >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Local network inbound rule added
) else (
    echo [INFO] Local network inbound rule already exists or failed
)

REM Allow the nginx.exe program specifically
netsh advfirewall firewall add rule name="NGINX-RTMP-2 Program Allow" dir=in action=allow program="%~dp0nginx.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Nginx program rule added
) else (
    echo [INFO] Nginx program rule already exists or failed
)

REM Allow loopback interface specifically
netsh advfirewall firewall add rule name="NGINX-RTMP-2 Loopback" dir=in action=allow protocol=TCP localport=8081 interfacetype=loopback >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Loopback interface rule added
) else (
    echo [INFO] Loopback interface rule already exists or failed
)

echo.
echo [INFO] Testing localhost connection...
powershell -Command "try { Invoke-WebRequest -Uri 'http://localhost:8081' -TimeoutSec 5 -UseBasicParsing | Out-Null; Write-Host '[OK] Localhost connection works!' } catch { Write-Host '[ERROR] Localhost connection failed:' $_.Exception.Message }"

echo.
echo [INFO] Now test your serveo link again!
echo [INFO] The external requests should now reach nginx.
echo.
echo ========================================
echo [✓] Localhost firewall rules configured!
echo ========================================
echo.
pause
