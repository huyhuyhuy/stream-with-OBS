@echo off
title Cleanup C:\nginx-rtmp
color 0E

echo ========================================
echo    CLEANUP C:\nginx-rtmp FOLDER
echo ========================================
echo.

echo [STEP 1] Stopping all nginx processes on system...
taskkill /f /im nginx.exe >nul 2>&1
echo [OK] Nginx processes killed

echo [STEP 2] Stopping NSSM services...
nssm stop nginx-rtmp >nul 2>&1
nssm remove nginx-rtmp confirm >nul 2>&1
echo [OK] NSSM services stopped

echo [STEP 3] Stopping all CMD processes related to nginx...
taskkill /f /im cmd.exe /fi "WINDOWTITLE eq*nginx*" >nul 2>&1
taskkill /f /im cmd.exe /fi "WINDOWTITLE eq*streaming*" >nul 2>&1
taskkill /f /im cmd.exe /fi "WINDOWTITLE eq*sync*" >nul 2>&1
echo [OK] CMD processes cleaned

echo [STEP 4] Releasing file handles...
timeout /t 3 /nobreak >nul
echo [OK] File handles released

echo [STEP 5] Force removing C:\nginx-rtmp...
if exist "C:\nginx-rtmp" (
    echo [INFO] Attempting to remove C:\nginx-rtmp...
    rmdir /s /q "C:\nginx-rtmp" >nul 2>&1
    if exist "C:\nginx-rtmp" (
        echo [WARNING] Some files still locked, trying alternative method...
        takeown /f "C:\nginx-rtmp" /r /d y >nul 2>&1
        icacls "C:\nginx-rtmp" /grant administrators:F /t >nul 2>&1
        rmdir /s /q "C:\nginx-rtmp" >nul 2>&1
        if exist "C:\nginx-rtmp" (
            echo [ERROR] Cannot remove folder. Manual action needed.
            echo [INFO] Try restarting Windows and run this script again.
        ) else (
            echo [OK] C:\nginx-rtmp removed successfully!
        )
    ) else (
        echo [OK] C:\nginx-rtmp removed successfully!
    )
) else (
    echo [INFO] C:\nginx-rtmp does not exist
)

echo.
echo ========================================
echo [✓] Cleanup completed!
echo ========================================
echo.
pause
