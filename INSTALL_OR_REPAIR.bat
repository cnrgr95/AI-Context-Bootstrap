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

echo.
echo Context profile / Baglam profili:
echo   1. Minimal  - lowest tool context / en dusuk arac baglami
echo   2. Balanced - Graphify + Laravel Boost when available
echo   3. Full     - all Graphify tools + Laravel Boost
set /p "PROFILE_CHOICE=Choose / Secin [1]: "
set "PROFILE=Minimal"
if "%PROFILE_CHOICE%"=="2" set "PROFILE=Balanced"
if "%PROFILE_CHOICE%"=="3" set "PROFILE=Full"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-ai-context.ps1" -ProjectPath "%PROJECT_PATH%" -ContextProfile "%PROFILE%"
set "RESULT=%ERRORLEVEL%"
echo.
if "%RESULT%"=="0" (
  echo Kurulum veya onarim tamamlandi.
) else (
  echo Kurulum basarisiz. Hata kodu: %RESULT%
)
pause
exit /b %RESULT%
