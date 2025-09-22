@echo off
title NGINX-RTMP Installer
color 0B

echo ========================================
echo      NGINX-RTMP INSTALLER v1.0
echo ========================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] This installer should be run as Administrator
    echo [INFO] Right-click and select "Run as administrator"
    echo.
    pause
)

echo [INFO] This will install NGINX-RTMP Live Streaming Server
echo [INFO] Installation directory: %~dp0
echo.
echo Press any key to continue or Ctrl+C to cancel...
pause >nul

echo.
echo [STEP 1] Checking system requirements...
ver | find "Windows" >nul
if %errorlevel% neq 0 (
    echo [ERROR] This installer only works on Windows!
    pause
    exit /b 1
)
echo [OK] Windows detected

echo [STEP 2] Creating directories...
if not exist "html\hls" mkdir "html\hls" >nul 2>&1
if not exist "html\hls\live" mkdir "html\hls\live" >nul 2>&1
if not exist "html\dash" mkdir "html\dash" >nul 2>&1
if not exist "html\recordings" mkdir "html\recordings" >nul 2>&1
if not exist "logs" mkdir "logs" >nul 2>&1
if not exist "temp" mkdir "temp" >nul 2>&1
echo [OK] Directories created

echo [STEP 3] Setting up Windows Firewall...
netsh advfirewall firewall show rule name="NGINX-RTMP-HTTP" >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Adding firewall rule for HTTP port 8080...
    netsh advfirewall firewall add rule name="NGINX-RTMP-HTTP" dir=in action=allow protocol=TCP localport=8080 >nul 2>&1
    if %errorlevel% equ 0 (
        echo [OK] HTTP firewall rule added
    ) else (
        echo [WARNING] Could not add HTTP firewall rule (needs admin rights)
    )
) else (
    echo [OK] HTTP firewall rule already exists
)

netsh advfirewall firewall show rule name="NGINX-RTMP-RTMP" >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Adding firewall rule for RTMP port 1935...
    netsh advfirewall firewall add rule name="NGINX-RTMP-RTMP" dir=in action=allow protocol=TCP localport=1935 >nul 2>&1
    if %errorlevel% equ 0 (
        echo [OK] RTMP firewall rule added
    ) else (
        echo [WARNING] Could not add RTMP firewall rule (needs admin rights)
    )
) else (
    echo [OK] RTMP firewall rule already exists
)

echo [STEP 4] Testing nginx installation...
nginx.exe -t >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Nginx configuration is valid
) else (
    echo [ERROR] Nginx configuration has errors!
    echo [INFO] Running nginx -t for details:
    nginx.exe -t
    pause
    exit /b 1
)

echo [STEP 5] Creating desktop shortcuts...
echo Set WshShell = WScript.CreateObject("WScript.Shell") > "%temp%\CreateShortcut.vbs"
echo Set Shortcut = WshShell.CreateShortcut("%USERPROFILE%\Desktop\Start NGINX-RTMP.lnk") >> "%temp%\CreateShortcut.vbs"
echo Shortcut.TargetPath = "%~dp0start-streaming.bat" >> "%temp%\CreateShortcut.vbs"
echo Shortcut.WorkingDirectory = "%~dp0" >> "%temp%\CreateShortcut.vbs"
echo Shortcut.Description = "Start NGINX-RTMP Live Streaming Server" >> "%temp%\CreateShortcut.vbs"
echo Shortcut.Save >> "%temp%\CreateShortcut.vbs"
cscript //nologo "%temp%\CreateShortcut.vbs" >nul 2>&1
del "%temp%\CreateShortcut.vbs" >nul 2>&1

echo Set WshShell = WScript.CreateObject("WScript.Shell") > "%temp%\CreateShortcut.vbs"
echo Set Shortcut = WshShell.CreateShortcut("%USERPROFILE%\Desktop\Stop NGINX-RTMP.lnk") >> "%temp%\CreateShortcut.vbs"
echo Shortcut.TargetPath = "%~dp0stop.bat" >> "%temp%\CreateShortcut.vbs"
echo Shortcut.WorkingDirectory = "%~dp0" >> "%temp%\CreateShortcut.vbs"
echo Shortcut.Description = "Stop NGINX-RTMP Live Streaming Server" >> "%temp%\CreateShortcut.vbs"
echo Shortcut.Save >> "%temp%\CreateShortcut.vbs"
cscript //nologo "%temp%\CreateShortcut.vbs" >nul 2>&1
del "%temp%\CreateShortcut.vbs" >nul 2>&1
echo [OK] Desktop shortcuts created

echo.
echo ========================================
echo          INSTALLATION COMPLETE!
echo ========================================
echo.
echo [✓] NGINX-RTMP Server installed successfully
echo [✓] Firewall rules configured
echo [✓] Desktop shortcuts created
echo [✓] Ready to use!
echo.
echo ========================================
echo              NEXT STEPS
echo ========================================
echo.
echo 1. Double-click "Start NGINX-RTMP" on desktop
echo 2. Configure OBS with:
echo    Server: rtmp://localhost:1935/live
echo    Stream Key: live
echo 3. Start streaming in OBS
echo 4. View at: http://localhost:8080
echo.
echo Read QUICK-START.txt for detailed instructions.
echo.
pause
