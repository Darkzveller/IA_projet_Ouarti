@echo off
title Installation - PC Bureautique
echo.
echo Lancement du script d'installation...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install-bureau-windows.ps1"
echo.
echo ===============================================
echo  Script termine (ou interrompu).
echo  Lisez les messages ci-dessus.
echo ===============================================
pause
