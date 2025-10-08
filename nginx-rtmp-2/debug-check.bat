@echo off
setlocal EnableDelayedExpansion
title Debug Check - Live Streaming #2 Issues
color 0E
cd /d "%~dp0"

echo ========================================
echo        DEBUG CHECK - LIVE STREAMING #2
echo ========================================
echo.

echo [CHECK 1] Nginx processes:
tasklist /fi "imagename eq nginx.exe" 2>NUL | find /i "nginx.exe" || echo No nginx processes found

echo.
echo [CHECK 2] Port status:
netstat -an | findstr ":1936\|:8081" || echo No ports bound

echo.
echo [CHECK 3] Local HTTP server:
powershell -Command "try { Invoke-WebRequest -Uri 'http://localhost:8081/health' -TimeoutSec 5 -UseBasicParsing | Out-Null; Write-Host '[OK] HTTP server #2 responding' } catch { Write-Host '[ERROR] HTTP server #2 not responding:' $_.Exception.Message }"

echo.
echo [CHECK 4] HLS files:
if exist "html\hls2\live2.m3u8" (
    echo [OK] live2.m3u8 exists
    echo [INFO] File size: 
    dir "html\hls2\live2.m3u8" | findstr "live2.m3u8"
) else (
    echo [ERROR] live2.m3u8 NOT FOUND
)

echo.
echo [CHECK 5] TS segments:
set /a segment_count=0
for %%f in ("html\hls2\live2-*.ts") do set /a segment_count+=1
echo [INFO] TS segments found: !segment_count!
if !segment_count! gtr 0 (
    echo [OK] HLS segments being created
) else (
    echo [ERROR] No TS segments found
)

echo.
echo [CHECK 6] Cloudflare tunnel:
tasklist /fi "imagename eq cloudflared.exe" 2>NUL | find /i "cloudflared.exe" || echo No cloudflared processes found

echo.
echo [CHECK 7] Windows Firewall:
netsh advfirewall firewall show rule name="NGINX-RTMP-HTTP" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] HTTP firewall rule exists
) else (
    echo [WARNING] HTTP firewall rule missing
)

netsh advfirewall firewall show rule name="NGINX-RTMP-RTMP" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] RTMP firewall rule exists
) else (
    echo [WARNING] RTMP firewall rule missing
)

echo.
echo ========================================
echo           DIAGNOSIS
echo ========================================

echo.
echo [TROUBLESHOOTING GUIDE:]
echo.
echo ❌ If nginx not running:
echo    → Run start-stream.bat as Administrator
echo.
echo ❌ If ports not bound:
echo    → Check Windows Firewall
echo    → Run start-stream.bat as Administrator
echo.
echo ❌ If HTTP server not responding:
echo    → nginx failed to start
echo    → Check antivirus blocking nginx.exe
echo.
echo ❌ If live2.m3u8 not found:
echo    → OBS not streaming to rtmp://localhost:1936/live2
echo    → Check OBS has video source
echo    → Check OBS Stream Key = "live"
echo.
echo ❌ If no TS segments:
echo    → OBS not actually streaming
echo    → Add video source to OBS
echo    → Make sure OBS shows "Streaming" status
echo.
echo ❌ If cloudflared not running:
echo    → Tunnel disconnected
echo    → Restart start-stream.bat
echo.

echo ========================================
echo.
echo [QUICK FIXES:]
echo.
echo 1. Run as Administrator:
echo    Right-click start-stream.bat → Run as administrator
echo.
echo 2. Check OBS Settings:
echo    Server: rtmp://localhost:1936/live2
echo    Stream Key: live2
echo    Add video source (Camera, Screen Capture)
echo.
echo 3. Whitelist in Antivirus:
echo    Add nginx.exe and cloudflared.exe to exceptions
echo.
echo 4. Test local first:
echo    Open http://localhost:8081 in browser
echo.

pause
