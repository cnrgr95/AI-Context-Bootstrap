@echo off
setlocal
chcp 65001 >nul
set "PROJECT_PATH=%~1"
if not defined PROJECT_PATH set /p "PROJECT_PATH=Enter the full project directory: "
if not defined PROJECT_PATH exit /b 2
echo 1. Minimal ^(recommended, smallest tool context^)
echo 2. Balanced ^(Graphify + Laravel Boost when available^)
echo 3. Full ^(all Graphify tools + Laravel Boost^)
set /p "CHOICE=Profile [1]: "
set "PROFILE=Minimal"
if "%CHOICE%"=="2" set "PROFILE=Balanced"
if "%CHOICE%"=="3" set "PROFILE=Full"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\setup-ai-context.ps1" -ProjectPath "%PROJECT_PATH%" -ContextProfile "%PROFILE%"
set "RESULT=%ERRORLEVEL%"
echo.
if "%RESULT%"=="0" (echo Installation completed.) else (echo Installation failed. Exit code: %RESULT%)
pause
exit /b %RESULT%
