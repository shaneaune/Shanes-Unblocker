@echo off
setlocal

::=================================================
:: Shane's Unblocker
:: Uninstaller
::=================================================

set "VERSION=1.0"

title Shane's Unblocker Uninstaller

cls
echo.
echo ==================================================
echo              Shane's Unblocker
echo                   Version %VERSION%
echo ==================================================
echo.
echo Removing right-click menu...
echo.

reg delete "HKCU\Software\Classes\Directory\shell\ShanesUnblocker" /f

echo.

if %ERRORLEVEL%==0 (
    echo ================================================
    echo Uninstallation completed successfully.
    echo ================================================
) else (
    echo ================================================
    echo Shane's Unblocker is not currently installed.
    echo ================================================
)

echo.
pause