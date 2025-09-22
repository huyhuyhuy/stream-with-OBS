@echo off
REM Fix HLS playlist if it doesn't exist
if not exist "%~dp0html\hls\live.m3u8" (
    copy "%~dp0html\hls\live\index.m3u8" "%~dp0html\hls\live.m3u8" /Y >nul 2>&1
    echo Fixed HLS playlist at %date% %time%
)
