:: Starting Parameters
@echo off & bgcolor(a) & chcp 1254 & mode con: cols=55 lines=9 & title Byte & cls

:: Run As Administrator
>nul reg add hkcu\Software\classes\.Admin\shell\runas\command /f /ve /d "cmd /x /d /r set \"f0=%%2\" &call \"%%2\" %%3" &set _= %*
>nul fltmc || if "%f0%" neq "%~f0" ( cd.>"%tmp%\runas.Admin" &start "%~n0" /high "%tmp%\runas.Admin" "%~f0" "%_:"=""%" &exit /b )

:: Stop Ads From MS
>nul powershell -Command "Get-AppxPackage *Microsoft.WindowsStore* | Reset-AppxPackage"

:: Remove And Disable Widgets
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Dsh" /v AllowNewsAndInterests /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Windows Feeds" /v EnableFeeds /t REG_DWORD /d 0 /f >NUL 2>&1
>nul powershell -noprofile -executionpolicy bypass -command "Get-AppxPackage -Name *WebExperience* | Foreach {Remove-AppxPackage $_.PackageFullName}"
>nul powershell -noprofile -executionpolicy bypass -command "Get-ProvisionedAppxPackage -Online | Where-Object { $_.PackageName -match 'WebExperience' } | ForEach-Object { Remove-ProvisionedAppxPackage -Online -PackageName $_.PackageName }"

:: Remove And Disable Chat
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarMn /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Windows Chat" /v ChatIcon /t REG_DWORD /d 3 /f >NUL 2>&1

:: Uninstall Teams
goto SkipTeamsUninstall
taskkill /F /IM "Teams.exe" >NUL 2>&1
taskkill /F /IM "MSTeams.exe" >NUL 2>&1
taskkill /F /IM "Update.exe" >NUL 2>&1
taskkill /F /IM "Squirrel.exe" >NUL 2>&1
taskkill /F /IM "MSTeamsUpdate.exe" >NUL 2>&1

reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Communications" /v ConfigureChatAutoInstall /t REG_DWORD /d 0 /f >Nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Office\Teams" /v PreventInstallationFromMsi /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Office\16.0\Common\OfficeUpdate" /v PreventTeamsInstall /t REG_DWORD /d 1 /f >NUL 2>&1

"%localappdata%\Microsoft\Teams\Update.exe" --uninstall --force-uninstall --system-level >NUL 2>&1
>nul powershell -nop -c "Get-WmiObject -Query ' select * from Win32_Product where Name like \"%%Team%%\" ' | ForEach-Object { ($_).Uninstall()}"
>nul powershell -noprofile -executionpolicy bypass -command "Get-AppxPackage -Name *Team* -AllUsers | Foreach {Remove-AppxPackage $_.PackageFullName -AllUsers}"
>nul powershell -noprofile -executionpolicy bypass -command "Get-ProvisionedAppxPackage -Online | Where-Object { $_.PackageName -match 'Team' } | ForEach-Object { Remove-ProvisionedAppxPackage -Online -AllUsers -PackageName $_.PackageName }"

@RD /S /Q "%localappdata%\Microsoft\Teams\*" >NUL 2>&1
@RD /S /Q "%localappdata%\Packages\MicrosoftTeams_8wekyb3d8bbwe\*" >NUL 2>&1
@RD /S /Q "%localappdata%\Microsoft\TeamsMeetingAddin\*" >NUL 2>&1
@RD /S /Q "%localappdata%\Microsoft\TeamsPresenceAddin\*" >NUL 2>&1
@RD /S /Q "%appdata%\Teams\*" >NUL 2>&1
@RD /S /Q "%appdata%\Microsoft\Teams\*" >NUL 2>&1
del /f /q "%localappdata%\Microsoft\Teams\*" >NUL 2>&1
del /f /q "%localappdata%\Packages\MicrosoftTeams_8wekyb3d8bbwe\*" >NUL 2>&1
del /f /q "%localappdata%\Microsoft\TeamsMeetingAddin\*" >NUL 2>&1
del /f /q "%localappdata%\Microsoft\TeamsPresenceAddin\*" >NUL 2>&1
del /f /q "%appdata%\Teams\*" >NUL 2>&1
del /f /q "%appdata%\Microsoft\Teams\*" >NUL 2>&1
:SkipTeamsUninstall

:: Uninstall Microsoft Edge Browser
taskkill /F /IM "MicrosoftEdgeUpdate.exe" >NUL 2>&1
taskkill /F /IM "MicrosoftEdgeUpdateCore.exe" >NUL 2>&1
taskkill /F /IM "MicrosoftEdgeUpdateOnDemand.exe" >NUL 2>&1
taskkill /F /IM "MicrosoftEdgeUpdateBroker.exe" >NUL 2>&1
taskkill /F /IM "msedge_pwa_launcher.exe" >NUL 2>&1
taskkill /F /IM "pwahelper.exe" >NUL 2>&1
taskkill /F /IM "msedgewebview2.exe" >NUL 2>&1
taskkill /F /IM "msedge.exe" >NUL 2>&1

set "u_path=%LocalAppData%\Microsoft"
set "s_path=C:\Program Files (x86)\Microsoft"
if /i %PROCESSOR_ARCHITECTURE%==x86 (if not defined PROCESSOR_ARCHITEW6432 (
  set "s_path=C:\Program Files\Microsoft"
  )
)

for /D %%i in ("%u_path%\Edge SxS\Application\*") do if exist "%%i\installer\setup.exe" (
start "" /w "%%i\installer\setup.exe" --uninstall --msedge-sxs --verbose-logging --force-uninstall --delete-profile
)
for /D %%i in ("%u_path%\Edge Internal\Application\*") do if exist "%%i\installer\setup.exe" (
start "" /w "%%i\installer\setup.exe" --uninstall --msedge-internal --verbose-logging --force-uninstall --delete-profile
)
for /D %%i in ("%u_path%\Edge Dev\Application\*") do if exist "%%i\installer\setup.exe" (
start "" /w "%%i\installer\setup.exe" --uninstall --msedge-dev --verbose-logging --force-uninstall --delete-profile
)
for /D %%i in ("%u_path%\Edge Beta\Application\*") do if exist "%%i\installer\setup.exe" (
start "" /w "%%i\installer\setup.exe" --uninstall --msedge-beta --verbose-logging --force-uninstall --delete-profile
)
for /D %%i in ("%u_path%\Edge\Application\*") do if exist "%%i\installer\setup.exe" (
start "" /w "%%i\installer\setup.exe" --uninstall --verbose-logging --force-uninstall --delete-profile
)
for /D %%i in ("%s_path%\Edge\Application\*") do if exist "%%i\installer\setup.exe" (
start "" /w "%%i\installer\setup.exe" --uninstall --system-level --verbose-logging --force-uninstall --delete-profile
)
for /D %%i in ("%s_path%\Edge Beta\Application\*") do if exist "%%i\installer\setup.exe" (
start "" /w "%%i\installer\setup.exe" --uninstall --msedge-beta --system-level --verbose-logging --force-uninstall --delete-profile
)
for /D %%i in ("%s_path%\Edge Dev\Application\*") do if exist "%%i\installer\setup.exe" (
start "" /w "%%i\installer\setup.exe" --uninstall --msedge-dev --system-level --verbose-logging --force-uninstall --delete-profile
)
for /D %%i in ("%s_path%\Edge Internal\Application\*") do if exist "%%i\installer\setup.exe" (
start "" /w "%%i\installer\setup.exe" --uninstall --msedge-internal --system-level --verbose-logging --force-uninstall --delete-profile
)

>nul powershell -nop -c "Get-WmiObject -Query ' select * from Win32_Product where Name like \"%%MicrosoftEdge%%\" ' | ForEach-Object { ($_).Uninstall()}"
>nul powershell -noprofile -executionpolicy bypass -command "Get-AppxPackage -Name *MicrosoftEdge* -AllUsers | Foreach {Remove-AppxPackage $_.PackageFullName -AllUsers}"
>nul powershell -noprofile -executionpolicy bypass -command "Get-ProvisionedAppxPackage -Online | Where-Object { $_.PackageName -match 'MicrosoftEdge' } | ForEach-Object { Remove-ProvisionedAppxPackage -Online -AllUsers -PackageName $_.PackageName }"

del /f /q "%AppData%\Microsoft\Internet Explorer\Quick Launch\Microsoft Edge*.lnk" >NUL 2>&1
del /f /q "C:\Windows\System32\config\systemprofile\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\Microsoft Edge*.lnk" >NUL 2>&1

:: Uninstall OneDrive
taskkill /im OneDriveSetup.exe >Nul 2>&1
tskill /a OneDriveSetup >Nul 2>&1

"%windir%\SysWOW64\OneDriveSetup.exe" /uninstall >Nul 2>&1
"C:\Windows\System32\OneDriveSetup.exe" /uninstall >Nul 2>&1
for /D %%I in ("%localappdata%\Microsoft\OneDrive\*") do "%%~I\OneDriveSetup.exe" /uninstall >Nul 2>&1

>nul powershell -nop -c "Get-WmiObject -Query ' select * from Win32_Product where Name like \"%%OneDrive%%\" ' | ForEach-Object { ($_).Uninstall()}"
>nul powershell -noprofile -executionpolicy bypass -command "Get-AppxPackage -Name *OneDrive* -AllUsers | Foreach {Remove-AppxPackage $_.PackageFullName -AllUsers}"
>nul powershell -noprofile -executionpolicy bypass -command "Get-ProvisionedAppxPackage -Online | Where-Object { $_.PackageName -match 'OneDrive' } | ForEach-Object { Remove-ProvisionedAppxPackage -Online -AllUsers -PackageName $_.PackageName }"

Reg Delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f >Nul 2>&1
Reg Delete "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f >Nul 2>&1
Reg Delete "HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f >Nul 2>&1

@RD /S /Q "%localappdata%\Microsoft\OneDrive\*" >NUL 2>&1
del /f /q "%localappdata%\Microsoft\OneDrive\*" >NUL 2>&1

DEL /F /S /Q "%appdata%\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" >Nul 2>&1
DEL /F /S /Q "%windir%\SysWOW64\OneDriveSetup.exe" >Nul 2>&1
DEL /F /S /Q "C:\Windows\System32\OneDriveSetup.exe" >Nul 2>&1

:: Tweak Google Chrome
taskkill /f /im Software_reporter_tool.exe >NUL 2>&1
icacls "%localappdata%\Google\Software Reporter Tool" /inheritance:e >NUL 2>&1
icacls "%localappdata%\Google\Chrome\User Data\SwReporter" /inheritance:e >NUL 2>&1
icacls "%localappdata%\Google\Chrome\User Data\OptGuideOnDeviceModel" /inheritance:e >NUL 2>&1
@RD /S /Q "%localappdata%\Google\Software Reporter Tool\*" >NUL 2>&1
del /f /q "%localappdata%\Google\Software Reporter Tool\*" >NUL 2>&1
@RD /S /Q "%localappdata%\Google\Chrome\User Data\SwReporter\*" >NUL 2>&1
del /f /q "%localappdata%\Google\Chrome\User Data\SwReporter\*" >NUL 2>&1
@RD /S /Q "%localappdata%\Google\Chrome\User Data\OptGuideOnDeviceModel\*" >NUL 2>&1
del /f /q "%localappdata%\Google\Chrome\User Data\OptGuideOnDeviceModel\*" >NUL 2>&1
mkdir "%localappdata%\Google\Software Reporter Tool" >NUL 2>&1
mkdir "%localappdata%\Google\Chrome\User Data\SwReporter" >NUL 2>&1
mkdir "%localappdata%\Google\Chrome\User Data\OptGuideOnDeviceModel" >NUL 2>&1
icacls "%localappdata%\Google\Software Reporter Tool" /inheritance:r >NUL 2>&1
icacls "%localappdata%\Google\Chrome\User Data\SwReporter" /inheritance:r >NUL 2>&1
icacls "%localappdata%\Google\Chrome\User Data\OptGuideOnDeviceModel" /inheritance:r >NUL 2>&1

:: UnRegister Apps
:: Reserved - SecHealthUI - MicrosoftPowerBIForWindows
set key=HKLM\Software\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\InboxApplications
FOR %%i IN (3DBuilder 549981C3F5F10 BingNews BingWeather Clipchamp.Clipchamp Cortana DolbyAudioExtensions GetHelp Getstarted microsoftskydrive Microsoft.549981C3F5F10 Microsoft3DViewer MicrosoftCorporationII.MailforSurfaceHub MicrosoftCorporationII.MicrosoftFamily MicrosoftCorporationII.QuickAssist MicrosoftEdge MicrosoftEdgeDevToolsClient MicrosoftEdge.Stable MicrosoftOfficeHub MicrosoftPowerBIForWindows MicrosoftSolitaireCollection MicrosoftStickyNotes MicrosoftTeams MicrosoftTeamsforSurfaceHub MicrosoftWindows.Client.WebExperience Office.Excel Office.PowerPoint Office.Word Office.OneNote OneConnect OneDriveSync OutlookForWindows Paint People PeopleExperienceHost PowerAutomateDesktop Print3D ScreenSketch SkypeApp SpotifyAB.SpotifyMusic SpotifyMusic Todos Wallet Whiteboard Windows.Alarms Windows.CommunicationsApps Windows.FeedbackHub Windows.Maps Windows.MSPaint Windows.Paint Windows.ParentalControls Windows.Photos Windows.ScreenSketch Windows.SoundRecorder Windows.Terminal WindowsCalculator WindowsDevHome YourPhone ZuneMusic ZuneVideo) DO (FOR /F %%a IN ('reg query "%key%" /f %%i /k 2^>nul ^| find /i "InboxApplications"') DO IF NOT ERRORLEVEL 1 (reg delete %%a /f 2>nul))

:: Refresh Byte
:: Check Internet Connection
ping -n 1 google.com > nul
if "%errorlevel%" == "0" goto Connected
if "%errorlevel%" == "1" goto NotConnected
:Connected
:NotConnected
C:\Byte\Admin.exe --NoLogo --Privileged regedit.exe /s C:\Byte\Byte.reg >Nul 2>&1
C:\Byte\Admin.exe --NoLogo --TrustedInstaller --Privileged regedit.exe /s C:\Byte\Byte.reg >Nul 2>&1
schtasks /Delete /TN "\Microsoft\Windows\Byte\ByteTask" /f >Nul 2>&1
schtasks /Create /XML C:\Byte\ByteTask.xml /tn "\Microsoft\Windows\Byte\ByteTask" >Nul 2>&1

:: Update Byte Updater
:: Check Internet Connection
ping -n 1 github.com > nul
if "%errorlevel%" == "0" goto Connected
if "%errorlevel%" == "1" goto NotConnected

:Connected
cd C:\Byte >Nul 2>&1
curl.exe -sfL --compressed --retry 5 --retry-delay 5 --connect-timeout 5 -m 30 -O https://raw.githubusercontent.com/EgeGurkan/Byte/main/ByteUpdater.cmd >Nul 2>&1

:NotConnected
goto End

:End
cls & exit