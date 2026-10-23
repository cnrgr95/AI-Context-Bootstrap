@echo off
setlocal
chcp 65001 >nul
set "PROJECT_PATH=%~1"
if not defined PROJECT_PATH set /p "PROJECT_PATH=Proje klasorunun tam yolunu girin: "
if not defined PROJECT_PATH exit /b 2
echo 1. Minimal ^(onerilen, en az arac baglami^)
echo 2. Dengeli ^(Graphify; Boost istege bagli^)
echo 3. Tam ^(tum Graphify araclari; Boost istege bagli^)
set /p "CHOICE=Profil [1]: "
set "PROFILE=Minimal"
if "%CHOICE%"=="2" set "PROFILE=Balanced"
if "%CHOICE%"=="3" set "PROFILE=Full"
set "BOOST_OPTION="
set /p "BOOST_CHOICE=Laravel Boost etkinlestirilsin mi? [H]: "
if /I "%BOOST_CHOICE%"=="E" set "BOOST_OPTION=-EnableLaravelBoost"
if /I "%BOOST_CHOICE%"=="Y" set "BOOST_OPTION=-EnableLaravelBoost"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-ai-context.ps1" -ProjectPath "%PROJECT_PATH%" -ContextProfile "%PROFILE%" %BOOST_OPTION%
set "RESULT=%ERRORLEVEL%"
echo.
if "%RESULT%"=="0" (echo Kurulum tamamlandi.) else (echo Kurulum basarisiz. Hata kodu: %RESULT%)
pause
exit /b %RESULT%
