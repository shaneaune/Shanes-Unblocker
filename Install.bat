@echo off
setlocal

::=================================================
:: Shane's Unblocker
:: Installer
::=================================================

set "VERSION=1.2.0"

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

REM Add a separate context-menu command for individual PDF files.
REM This does not change the default PDF file association.
reg add "HKCU\Software\Classes\SystemFileAssociations\.pdf\shell\ShanesUnblocker" /ve /d "Unlock PDF" /f

reg add "HKCU\Software\Classes\SystemFileAssociations\.pdf\shell\ShanesUnblocker" ^
/v Icon ^
/d "\"%INSTALLDIR%\Shanes-Unblocker.ico\"" ^
/f

reg add "HKCU\Software\Classes\SystemFileAssociations\.pdf\shell\ShanesUnblocker\command" ^
/ve ^
/d "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File \"%INSTALLDIR%\Shanes-Unblocker.ps1\" \"%%1\"" ^
/f

echo.
echo ================================================
echo Installation completed successfully.
echo ================================================
echo.
pause