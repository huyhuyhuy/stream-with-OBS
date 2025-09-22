@echo off
title Minimal NGINX-RTMP Setup
color 0A

echo ========================================
echo    MINIMAL NGINX-RTMP FOR OBS + SERVEO
echo ========================================
echo.

REM Create minimal structure
mkdir conf >nul 2>&1
mkdir html >nul 2>&1
mkdir logs >nul 2>&1

echo [STEP 1] Creating minimal nginx.conf...
echo worker_processes 1; > conf\nginx.conf
echo events { worker_connections 1024; } >> conf\nginx.conf
echo rtmp { >> conf\nginx.conf
echo   server { >> conf\nginx.conf
echo     listen 1935; >> conf\nginx.conf
echo     application live { live on; } >> conf\nginx.conf
echo   } >> conf\nginx.conf
echo } >> conf\nginx.conf
echo http { >> conf\nginx.conf
echo   server { >> conf\nginx.conf
echo     listen 8080; >> conf\nginx.conf
echo     location / { >> conf\nginx.conf
echo       return 200 "RTMP Server Running - Stream at rtmp://localhost:1935/live"; >> conf\nginx.conf
echo       add_header Content-Type text/plain; >> conf\nginx.conf
echo     } >> conf\nginx.conf
echo   } >> conf\nginx.conf
echo } >> conf\nginx.conf

echo [STEP 2] Starting nginx...
nginx.exe
echo [OK] Nginx started!

echo.
echo ========================================
echo          READY TO STREAM!
echo ========================================
echo.
echo OBS Settings:
echo - Server: rtmp://localhost:1935/live
echo - Stream Key: live
echo.
echo Public Access:
echo - ssh -R 80:localhost:8080 serveo.net
echo.
echo Local Test: http://localhost:8080
echo.
pause
