@echo off
REM Sync HLS .ts files from live subdirectory to root
cd /d "%~dp0html\hls\live"
for %%f in (*.ts) do (
    copy "%%f" "..\%%f" /Y >nul 2>&1
)
