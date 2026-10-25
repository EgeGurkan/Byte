:: Starting Parameters
@echo off & chcp 1254 & mode con: cols=55 lines=9 & title Byte Updater & cls

:: Run As Administrator
>nul reg add hkcu\software\classes\.Admin\shell\runas\command /f /ve /d "cmd /x /d /r set \"f0=%%2\" &call \"%%2\" %%3" &set _= %*
>nul fltmc || if "%f0%" neq "%~f0" ( cd.>"%tmp%\runas.Admin" &start "%~n0" /high "%tmp%\runas.Admin" "%~f0" "%_:"=""%" &exit /b )

:: Check Internet Connection
ping -n 1 github.com > nul
if "%errorlevel%" neq "0" goto StartPayload

:: Byte Online
mkdir C:\Byte >Nul 2>&1
mkdir C:\Byte\Update >Nul 2>&1
cd /d C:\Byte\Update >Nul 2>&1

:: Update Files
set "BASE_URL=https://raw.githubusercontent.com/EgeGurkan/Byte/main"
curl.exe -sfL --compressed --retry 5 --retry-delay 5 --connect-timeout 5 -m 60 ^
  -O "%BASE_URL%/Admin.exe" ^
  -O "%BASE_URL%/Byte.reg" ^
  -O "%BASE_URL%/Byte.cmd" ^
  -O "%BASE_URL%/Byte.ps1" ^
  -O "%BASE_URL%/ByteHidden.vbs" ^
  -O "%BASE_URL%/ByteTask.xml" ^
  -O "%BASE_URL%/ByteUpdater.cmd" >Nul 2>&1

if not exist "C:\Byte\Update\Admin.exe" goto StartPayload
if not exist "C:\Byte\Update\Byte.reg" goto StartPayload
if not exist "C:\Byte\Update\Byte.cmd" goto StartPayload
if not exist "C:\Byte\Update\Byte.ps1" goto StartPayload
if not exist "C:\Byte\Update\ByteHidden.vbs" goto StartPayload
if not exist "C:\Byte\Update\ByteTask.xml" goto StartPayload
if not exist "C:\Byte\Update\ByteUpdater.cmd" goto StartPayload

:: Prep
copy /y C:\Byte\Update\ByteHidden.vbs C:\Byte\ >Nul 2>&1

:: File Swapper
(
echo @echo off
echo timeout /t 5 /nobreak ^>Nul
echo del /q /f C:\Byte\*.exe ^>Nul 2^>^&1
echo del /q /f C:\Byte\*.ps1 ^>Nul 2^>^&1
echo del /q /f C:\Byte\*.reg ^>Nul 2^>^&1
echo del /q /f C:\Byte\*.vbs ^>Nul 2^>^&1
echo del /q /f C:\Byte\*.xml ^>Nul 2^>^&1
echo del /q /f C:\Byte\Byte.cmd ^>Nul 2^>^&1
echo del /q /f C:\Byte\ByteUpdater.cmd ^>Nul 2^>^&1
echo move /y C:\Byte\Update\* C:\Byte\ ^>Nul 2^>^&1
echo rd /s /q C:\Byte\Update ^>Nul 2^>^&1
echo.
echo timeout /t 5 /nobreak ^>Nul
echo C:\Byte\Admin.exe --NoLogo --Privileged wscript.exe "C:\Byte\ByteHidden.vbs" "C:\Byte\Byte.cmd" ^>Nul 2^>^&1
echo.
echo del "%%~f0"
) > "C:\Byte\ByteSwapper.cmd"

cd /d C:\Byte >Nul 2>&1
start "" C:\Byte\Admin.exe --NoLogo --Privileged wscript.exe "C:\Byte\ByteHidden.vbs" "C:\Byte\ByteSwapper.cmd"
exit

:: Byte Offline
:StartPayload
C:\Byte\Admin.exe --NoLogo --Privileged wscript.exe "C:\Byte\ByteHidden.vbs" "C:\Byte\Byte.cmd" >Nul 2>&1
exit