@echo off
setlocal
chcp 65001 >nul
set "PROJECT_PATH=%~1"
if not defined PROJECT_PATH set /p "PROJECT_PATH=Proje klasorunun tam yolunu girin: "
if not defined PROJECT_PATH exit /b 2
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\check-status.ps1" -ProjectPath "%PROJECT_PATH%"
set "RESULT=%ERRORLEVEL%"
echo.
pause
exit /b %RESULT%
