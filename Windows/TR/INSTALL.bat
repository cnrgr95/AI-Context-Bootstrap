@echo off
setlocal
chcp 65001 >nul
set "PROJECT_PATH=%~1"
if not defined PROJECT_PATH set /p "PROJECT_PATH=Proje klasorunun tam yolunu girin: "
if not defined PROJECT_PATH exit /b 2
echo 1. Minimal ^(onerilen, en az arac baglami^)
echo 2. Dengeli ^(Graphify + varsa Laravel Boost^)
echo 3. Tam ^(tum Graphify araclari + Laravel Boost^)
set /p "CHOICE=Profil [1]: "
set "PROFILE=Minimal"
if "%CHOICE%"=="2" set "PROFILE=Balanced"
if "%CHOICE%"=="3" set "PROFILE=Full"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\setup-ai-context.ps1" -ProjectPath "%PROJECT_PATH%" -ContextProfile "%PROFILE%"
set "RESULT=%ERRORLEVEL%"
echo.
if "%RESULT%"=="0" (echo Kurulum tamamlandi.) else (echo Kurulum basarisiz. Hata kodu: %RESULT%)
pause
exit /b %RESULT%
