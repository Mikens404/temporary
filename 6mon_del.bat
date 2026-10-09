@echo off
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0DeleteMain.ps1"
echo.
pause
exit