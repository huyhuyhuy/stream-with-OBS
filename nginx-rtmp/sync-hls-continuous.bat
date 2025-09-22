@echo off
:loop
copy "%~dp0html\hls\live\index.m3u8" "%~dp0html\hls\live.m3u8" /Y >nul 2>&1
copy "%~dp0html\hls\live\*.ts" "%~dp0html\hls\" /Y >nul 2>&1
timeout /t 2 /nobreak >nul
goto loop
