@echo off
setlocal

::=================================================
:: Shane's Unblocker
:: Installer
::=================================================

set "VERSION=1.0"

title Shane's Unblocker Installer

cls
echo.
echo ==================================================
echo              Shane's Unblocker
echo                   Version %VERSION%
echo ==================================================
echo.
echo Installing right-click menu...
echo.

REM Get the folder this BAT file is running from
set "INSTALLDIR=%~dp0"

REM Remove trailing backslash
if "%INSTALLDIR:~-1%"=="\" set "INSTALLDIR=%INSTALLDIR:~0,-1%"

echo Installation folder:
echo %INSTALLDIR%
echo.

reg add "HKCU\Software\Classes\Directory\shell\ShanesUnblocker" /ve /d "Unlock PDFs" /f

reg add "HKCU\Software\Classes\Directory\shell\ShanesUnblocker" ^
/v Icon ^
/d "\"%INSTALLDIR%\Shanes-Unblocker.ico\"" ^
/f

reg add "HKCU\Software\Classes\Directory\shell\ShanesUnblocker\command" ^
/ve ^
/d "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File \"%INSTALLDIR%\Shanes-Unblocker.ps1\" \"%%1\"" ^
/f

echo.
echo ================================================
echo Installation completed successfully.
echo ================================================
echo.
pause