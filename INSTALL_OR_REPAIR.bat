@echo off
setlocal
chcp 65001 >nul

set "PROJECT_PATH=%~1"
if not defined PROJECT_PATH set /p "PROJECT_PATH=Proje klasorunun tam yolunu girin: "
if not defined PROJECT_PATH (
  echo Proje yolu verilmedi.
  pause
  exit /b 2
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-ai-context.ps1" -ProjectPath "%PROJECT_PATH%"
set "RESULT=%ERRORLEVEL%"
echo.
if "%RESULT%"=="0" (
  echo Kurulum veya onarim tamamlandi.
) else (
  echo Kurulum basarisiz. Hata kodu: %RESULT%
)
pause
exit /b %RESULT%
