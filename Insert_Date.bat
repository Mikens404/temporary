@echo off
cd /d "%~dp0"
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd"') do set "TODAY=%%i"

for /f "delims=" %%D in ('dir /b /ad ^| findstr /v /r "_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]$"') do (
    ren "%%D" "%%D_%TODAY%"
)