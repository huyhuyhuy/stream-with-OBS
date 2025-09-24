@echo off
setlocal EnableDelayedExpansion
title Fix Antivirus Issues
color 0C
cd /d "%~dp0"

echo ========================================
echo        FIX ANTIVIRUS BLOCKING
echo ========================================
echo.

echo [INFO] This script helps fix antivirus blocking issues
echo [INFO] Antivirus may block nginx.exe and cloudflared.exe
echo.

echo ========================================
echo 1. CHECK CURRENT ANTIVIRUS
echo ========================================

echo [CHECK] Detecting antivirus software...

REM Check Windows Defender
sc query "WinDefend" >nul 2>&1
if %errorlevel% equ 0 (
    echo [FOUND] Windows Defender is running
    set "has_defender=1"
) else (
    echo [INFO] Windows Defender not detected
)

REM Check common antivirus processes
for %%a in (avast avgsvc kavfs kavsvc norton mcafee bitdefender) do (
    tasklist /fi "imagename eq %%a.exe" 2>NUL | find /i "%%a.exe" >NUL
    if !errorlevel! equ 0 (
        echo [FOUND] %%a antivirus detected
        set "has_antivirus=1"
    )
)

echo.
echo ========================================
echo 2. ANTIVIRUS WHITELIST GUIDE
echo ========================================

if "%has_defender%"=="1" (
    echo [WINDOWS DEFENDER]
    echo 1. Open Windows Security
    echo 2. Virus ^& threat protection
    echo 3. Virus ^& threat protection settings
    echo 4. Manage settings
    echo 5. Add or remove exclusions
    echo 6. Add an exclusion → Folder
    echo 7. Select this folder: %CD%
    echo.
)

if "%has_antivirus%"=="1" (
    echo [THIRD-PARTY ANTIVIRUS]
    echo 1. Open your antivirus software
    echo 2. Look for "Exclusions" or "Exceptions"
    echo 3. Add folder exclusion: %CD%
    echo 4. Or add file exclusions:
    echo    - nginx.exe
    echo    - cloudflared.exe
    echo    - start-stream.bat
    echo.
)

echo ========================================
echo 3. QUICK TEST METHOD
echo ========================================

echo [TEST] To confirm antivirus is blocking:
echo.
echo 1. Temporarily disable real-time protection
echo 2. Run start-stream.bat
echo 3. If it works → antivirus was blocking
echo 4. Re-enable protection and whitelist properly
echo.

echo ========================================
echo 4. AUTOMATIC WHITELIST (WINDOWS DEFENDER)
echo ========================================

echo [QUESTION] Do you want to auto-whitelist with Windows Defender? (y/n)
set /p "auto_whitelist="

if /i "!auto_whitelist!"=="y" (
    echo [INFO] Adding Windows Defender exclusion...
    powershell -Command "Add-MpPreference -ExclusionPath '%CD%'"
    if %errorlevel% equ 0 (
        echo [SUCCESS] Folder whitelisted in Windows Defender
    ) else (
        echo [ERROR] Failed to add exclusion. Try manual method above.
    )
) else (
    echo [INFO] Skipping automatic whitelist
)

echo.
echo ========================================
echo 5. VERIFICATION
echo ========================================

echo [TEST] Testing if files are accessible...
if exist "nginx.exe" (
    echo [OK] nginx.exe accessible
) else (
    echo [ERROR] nginx.exe not found
)

if exist "cloudflared.exe" (
    echo [OK] cloudflared.exe accessible
) else (
    echo [ERROR] cloudflared.exe not found
)

echo.
echo [TEST] Try running nginx test...
.\nginx.exe -t >nul 2>&1
if %errorlevel% equ 0 (
    echo [SUCCESS] nginx test passed - antivirus not blocking
) else (
    echo [WARNING] nginx test failed - may still be blocked
)

echo.
echo ========================================
echo           NEXT STEPS
echo ========================================
echo.
echo [AFTER WHITELISTING:]
echo 1. Run start-stream.bat as Administrator
echo 2. Test local access: http://localhost:8080
echo 3. Configure OBS with rtmp://localhost:1935/live
echo 4. Start streaming and test public URL
echo.
echo [IF STILL BLOCKED:]
echo 1. Check antivirus quarantine/logs
echo 2. Try running from different folder
echo 3. Contact antivirus support
echo.

pause
