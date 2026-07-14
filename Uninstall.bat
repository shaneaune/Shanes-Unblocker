@echo off
setlocal

::=================================================
:: Shane's Unblocker
:: Uninstaller
::=================================================

set "VERSION=1.1.0"

title Shane's Unblocker Uninstaller

cls
echo.
echo ==================================================
echo              Shane's Unblocker
echo                 Version %VERSION%
echo ==================================================
echo.
echo Removing right-click menu and saved settings...
echo.

:: Remove the Windows Explorer context-menu entry.
reg delete "HKCU\Software\Classes\Directory\shell\ShanesUnblocker" /f >nul 2>&1

:: Remove saved user settings, including the auto-close preference.
reg delete "HKCU\Software\Shanes-Unblocker" /f >nul 2>&1

echo ================================================
echo Uninstallation completed successfully.
echo ================================================
echo.
echo The program files were not deleted.
echo You may now delete the Shane's Unblocker folder.
echo.
pause
