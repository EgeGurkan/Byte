:: Starting Parameters
@echo off & bgcolor(a) & chcp 1254 & mode con: cols=55 lines=9 & title Byte Updater & cls

:: Run As Administrator
>nul reg add hkcu\software\classes\.Admin\shell\runas\command /f /ve /d "cmd /x /d /r set \"f0=%%2\" &call \"%%2\" %%3" &set _= %*
>nul fltmc || if "%f0%" neq "%~f0" ( cd.>"%tmp%\runas.Admin" &start "%~n0" /high "%tmp%\runas.Admin" "%~f0" "%_:"=""%" &exit /b )

:: Check Internet Connection
ping -n 1 github.com > nul
if "%errorlevel%" == "0" goto Connected
if "%errorlevel%" == "1" goto NotConnected

:Connected
::Byte Folder Prep
mkdir C:\Byte >Nul 2>&1
cd /d C:\Byte >Nul 2>&1

:: Clean Slate
del /q /f C:\Byte\*.exe >Nul 2>&1
del /q /f C:\Byte\*.reg >Nul 2>&1
del /q /f C:\Byte\*.vbs >Nul 2>&1
del /q /f C:\Byte\*.xml >Nul 2>&1
del /q /f C:\Byte\Byte.cmd >Nul 2>&1

:: Update Files
curl.exe -sfL --compressed --retry 5 --retry-delay 5 --connect-timeout 5 -m 30 -O https://raw.githubusercontent.com/EgeGurkan/Byte/main/Admin.exe >Nul 2>&1
curl.exe -sfL --compressed --retry 5 --retry-delay 5 --connect-timeout 5 -m 30 -O https://raw.githubusercontent.com/EgeGurkan/Byte/main/Byte.reg >Nul 2>&1
curl.exe -sfL --compressed --retry 5 --retry-delay 5 --connect-timeout 5 -m 30 -O https://raw.githubusercontent.com/EgeGurkan/Byte/main/Byte.cmd >Nul 2>&1
curl.exe -sfL --compressed --retry 5 --retry-delay 5 --connect-timeout 5 -m 30 -O https://raw.githubusercontent.com/EgeGurkan/Byte/main/ByteUpdater.cmd >Nul 2>&1
curl.exe -sfL --compressed --retry 5 --retry-delay 5 --connect-timeout 5 -m 30 -O https://raw.githubusercontent.com/EgeGurkan/Byte/main/ByteHidden.vbs >Nul 2>&1
curl.exe -sfL --compressed --retry 5 --retry-delay 5 --connect-timeout 5 -m 30 -O https://raw.githubusercontent.com/EgeGurkan/Byte/main/ByteTask.xml >Nul 2>&1

:NotConnected
:: Run Commands
C:\Byte\Admin.exe --NoLogo --Privileged wscript.exe "C:\Byte\ByteHidden.vbs" "C:\Byte\Byte.cmd" >Nul 2>&1
goto End

:End
cls & exit