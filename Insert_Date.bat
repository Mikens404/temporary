@echo off
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0InsertMain.ps1"
echo.
echo Process finished. Auto closing in 3 seconds...
timeout /t 3 >nul
exit