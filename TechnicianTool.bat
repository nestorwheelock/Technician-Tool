:: FILE    :  TechnicianTool
::===============================================================================================================
::  DEFINE SYSTEM ENVIRONMENT
	@echo off
	setlocal enabledelayedexpansion
	set SCRIPT_VERSION=4.0.1.2
	Title  ------- GEEKS ON SITE ------ Version %SCRIPT_VERSION%
	mode con: cols=46 lines=2
	color 9F&prompt $v
	cd /d %~dp0
	set "MAC=00:00:00:00:00:00"
	set "TechnicianToolpath=%~dp0"
	set "TechnicianToolpath=%TechnicianToolpath:~0,-1%"
	set "TechnicianToolname=%~n0.bat"
::  GET ADMINISTRATIVE RIGHTS
	>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
	if "%errorlevel%" NEQ "0" (
	echo   Requesting Administrative Privileges...
    goto UACPrompt
	) else (goto GotAdmin)
: UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%TechnicianToolname%", "", "%TechnicianToolpath%", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
	del "%temp%\getadmin.vbs"
    exit /B
: GotAdmin
    if exist "%temp%\getadmin.vbs" (del "%temp%\getadmin.vbs")
	pushd "%TechnicianToolpath%"
	cls
::  FORCE PATHS	
	set "WMIC=%SystemRoot%\System32\wbem\wmic.exe"
::  FIND OPERATING SYSTEM ARCHITECTURE 
	reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > nul && set "OSA=32-bit" || set "OSA=64-bit"
::  FIND OPERATING SYSTEM VERSION AND NUMBER
	set W_V=
	for /f "tokens=3*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName ^| Find "ProductName"') do set W_V=%%i %%j
::  FIND OPERATING MODE 
	set "SAFE_MODE=no"
	if /i "%SAFEBOOT_OPTION%"=="MINIMAL" set "SAFE_MODE=yes"
	if /i "%SAFEBOOT_OPTION%"=="NETWORK" set "SAFE_MODE=yes"
::  ADD GOS FOLDER PATH FOR ALL USERS EXCEPT ON XP 
	if /i "%W_V:~0,7%"=="Microsoft" goto GOS_Cleanup
	echo ;%PATH%; | find /C /I ";c:\gos;" >nul
	if %ERRORLEVEL% NEQ 0 setx path "%path%;c:\gos"	
::  REMOVE 24 HOUR COOLDOWN TIMER FROM SYSTEM RESTORE POINT CREATION(Only for 8, 8.1 and 10.)
	if /i "%W_V:~0,9%"=="Windows V" goto GOS_Cleanup
	if /i "%W_V:~0,9%"=="Windows 7" goto GOS_Cleanup
	reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /t reg_dword /v SystemRestorePointCreationFrequency /d 0 /f >nul 2>&1
	cls
::  REMOVES INCOMPATIBLE PROGRAMS FROM THE GOS FOLDER AND REMOVES ARCHITECTURE INDICATOR
: GOS_Cleanup
	pushd c:\gos\
	if exist "1  TeamViewer_GOS.exe" goto Connection_Cleanup
	if exist "1 - TeamViewer-GOS.exe" ren "1 - TeamViewer-GOS.exe" "1 - TeamViewer_GOS.exe" 
	if "%OSA%"=="32-bit"  del /q /f *-64.exe
	if "%OSA%"=="64-bit"  del /q /f *-32.exe
	if "%OSA%"=="32-bit"  ren *-32.exe  *-.exe
	if "%OSA%"=="64-bit"  ren *-64.exe  *-.exe
	for %%a in (*-*) do (
	set file=%%a
	ren "!file!" "!file:-=!"
	)	
	popd
	cls
::  ADD REGISTRY FAVORITES
: Add_Reg_Fav
	cls
	echo Windows Registry Editor Version 5.00 > Registry_Favorites.txt
	echo. >> Registry_Favorites.txt
    echo [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit\Favorites] >> Registry_Favorites.txt
    echo "Printers - Environments"="Computer\\HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Print\\Environments" >> Registry_Favorites.txt
    echo "Uninstall"="Computer\\HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall" >> Registry_Favorites.txt
    echo "Upper and Lower Filters"="Computer\\HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Class" >> Registry_Favorites.txt
	ren Registry_Favorites.txt Registry_Favorites.reg
	regedit.exe /s Registry_Favorites.reg
	del /q /f Registry_Favorites.reg
: Connection_Cleanup
	if exist "%USERPROFILE%\Downloads\Support-LogMeInRescue*.exe" del /q /f "%USERPROFILE%\Downloads\Support-LogMeInRescue*.exe"
	if exist "%USERPROFILE%\Downloads\TeamViewer*.exe"            del /q /f "%USERPROFILE%\Downloads\TeamViewer*.exe" 
::===============================================================================================================
:================================================================================================================
:: TECHNICIAN TOOL - CONTROL CENTER 
: Control_Center
	Title  ------- GEEKS ON SITE ------ Version %SCRIPT_VERSION%	
	mode con: cols=86 lines=38
	color 9F&prompt $v
	set "file=Control Center"
	call :top_box
	echo 	  บ  1.  Printer Repair                                            บ
	echo 	  บ  2.  Internet Repair                                           บ
	echo 	  บ  3.  Operating System Repair                                   บ
	echo 	  บ  4.  Tune up mode                                              บ
	echo 	  บ  5.  Tools                                                     บ
	echo 	  บ  6.  Reports                                                   บ
	echo 	  บ  7.  Create System Restore                                     บ
	echo 	  บ  8.  System Info                                               บ
	echo 	  บ  9.  About                                                     บ
	echo 	  บ  0.  Clean Up and Exit                                         บ
	call :bottom_box
	if "%option%"=="1"   goto Printer_Repair 
	if "%option%"=="2"   goto Internet_Repair  
	if "%option%"=="3"   goto Repair_OS 
	if "%option%"=="4"   goto Auto_Tools
	if "%option%"=="5"   goto GOS_Tools_No_Job
	if "%option%"=="6"   goto Reports
	if "%option%"=="7"	 goto Restore_Point
	if "%option%"=="8"	 goto System_Info
	if "%option%"=="9"	 goto about
	if "%option%"=="0"   goto Clean_Exit
	call :bad_choice
	goto Control_Center
::===============================================================================================================
:================================================================================================================
:: CONTROL CENTER 1 - OPENS PRINTER REPAIR MENU
: Printer_Repair
	cls
	set "file=Printer Repair Options"
	call :top_box
	echo 	  บ  1. Open Print Spooler Folder                                  บ
	echo 	  บ  2. Clear Printer Spooler                                      บ
	echo 	  บ  3. Repair Print Spooler Error: 1068                           บ
	echo 	  บ  0. Cancel                                                     บ 
	call :bottom_box
	if "%option%"=="1"  goto Print_Spooler_Location
	if "%option%"=="2"  goto Clear_Printer
	if "%option%"=="3"  goto Repair_Spooler 	
	if "%option%"=="0"  goto Control_Center
	call :bad_choice
	goto Printer_Repair
::===============================================================================================================
:: PRINTER REPAIR OPTION  1 - OPENS PRINTER SPOOLER FOLDER IN GUI 
: Print_Spooler_Location
	start %windir%\System32\spool\PRINTERS
	goto Printer_Repair
:: PRINTER REPAIR OPTION  2 - REFRESH PRINT SPOOLER
: Clear_Printer
	net stop spooler
	del %systemroot%\System32\spool\printers\* /Q /F /S
	net start spooler
	pause
	goto Printer_Repair
:: PRINTER REPAIR OPTION 3 - REPAIR PRINT SPOOLER ERROR 1068
: Repair_Spooler
	net stop spooler
	sc config spooler depend= RPCSS
	net start spooler
	pause
	goto Printer_Repair
::===============================================================================================================
:================================================================================================================
:: CONTROL CENTER 2 - INTERNET REPAIR MENU
: Internet_Repair
	cls
	set "file=Internet Repair"
	call :top_box
	echo 	  บ  1.  Host File                                                 บ
	echo 	  บ  2.  Repair FTP                                                บ
	echo 	  บ  3.  Set DNS IPV4                                              บ
	echo 	  บ  4.  Remove Proxy                                              บ
	echo 	  บ  5.  Uninstall IE Browser                                      บ
	echo 	  บ  6.  Reset Browser                                             บ
	echo 	  บ  7.  Ping Test and IP Info                                     บ
	echo 	  บ  8.  Flush IP DNS and Reset Winsock (Auto Reboot)              บ
	echo 	  บ  9.  Fix access to HTTPS sites                                 บ
	echo 	  บ  0.  Cancel                                                    บ 
	call :bottom_box
	if "%option%"=="1"   goto Host
	if "%option%"=="2"   goto Repair_FTP
	if "%option%"=="3"   goto Set_DNS
	if "%option%"=="4"   goto Remove_Proxy   
	if "%option%"=="5"   goto Uninstall_Browser
	if "%option%"=="6"   goto Reset_Browser
	if "%option%"=="7"   goto Ping_Test
	if "%option%"=="8"   goto Flush_and_Reset
	if "%option%"=="9"   goto Repair_HTTPS
	if "%option%"=="0"   goto Control_Center
	call :bad_choice
	goto Internet_Repair
::===============================================================================================================
:================================================================================================================
:: INTERNET REPAIR 1 - HOST FILE MENU
: Host
	cls
	set "file=Uninstall Browser"
	call :top_box
	echo 	  บ  1.  Host - Inspect                                            บ
	echo 	  บ  2.  Host - Reset Permisions                                   บ
	echo 	  บ  3.  Host - Replace and Repair Internet (Auto Reboot)          บ
	echo 	  บ  0.  Cancel                                                    บ 
	call :bottom_box
	if "%option%"=="1"  goto Inspect_Host
	if "%option%"=="2"  goto Host_Permisions
	if "%option%"=="3"  goto Host_Replace
	if "%option%"=="0"  goto Internet_Repair
	call :bad_choice
	goto Internet_Repair
::===============================================================================================================
:================================================================================================================
:: HOST REPAIR - 1 OPENS HOST FILE IN GUI
: Inspect_Host
	notepad C:\Windows\System32\drivers\etc\hosts
	goto Host
:: HOST REPAIR 2 - RESET HOST FILE PERMISSIONS 
: Host_Permisions
	echo,Y|cacls "%WinDir%\system32\drivers\etc\hosts" /G everyone:f
	attrib -s -h -r "%WinDir%\system32\drivers\etc\hosts"
	echo The Permissions on the HOSTS file have been reset.
	pause
	goto Host
:: HOST REPAIR 3 - REPLACE HOST FILE
: Host_Replace
	pushd\windows\system32\drivers\etc
	echo,Y|cacls "%WinDir%\system32\drivers\etc\hosts" /G everyone:f
	attrib -s -h -r "%WinDir%\system32\drivers\etc\hosts"
	echo 127.0.0.1 localhost>HOSTS
	attrib +s +h +r hosts
	popd
	ipconfig /release
	ipconfig /renew
	ipconfig /flushdns
	netsh winsock reset all
	netsh int ip reset all
	shutdown -r -t 1
::===============================================================================================================
:: INTERNET REPAIR 2 - REPAIR FTP WHEN IT OPENS TO A WEB BROWSER 
: Repair_FTP
	echo Importing Registry Settings, Please Wait ....
	cls
:: Check Windows Version
	if /i "%W_V:~0,9%"=="Microsoft" goto XP_Fix_FTP
	if /i "%W_V:~0,7%"=="Windows"   goto Newer_Fix_FTP
	goto warn
: Newer_Fix_FTP
	echo Windows Registry Editor Version 5.00> FTP_Fix.txt
	echo [HKEY_CLASSES_ROOT\ftp]>> FTP_Fix.txt
	echo @="URL:File Transfer Protocol">> FTP_Fix.txt
	echo "AppUserModelID"="Microsoft.InternetExplorer.Default">> FTP_Fix.txt
	echo "EditFlags"=dword:00000002>> FTP_Fix.txt
	echo "FriendlyTypeName"="@C:\\Windows\\system32\\ieframe.dll,-905">> FTP_Fix.txt
	echo "ShellFolder"="{63da6ec0-2e98-11cf-8d82-444553540000}">> FTP_Fix.txt
	echo "Source Filter"="{E436EBB6-524F-11CE-9F53-0020AF0BA770}">> FTP_Fix.txt
	echo "URL Protocol"="">> FTP_Fix.txt
	echo [HKEY_CLASSES_ROOT\ftp\DefaultIcon]>> FTP_Fix.txt
	echo @=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\>> FTP_Fix.txt
	echo   00,5c,00,73,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,75,00,72,00,\>> FTP_Fix.txt
	echo   6c,00,2e,00,64,00,6c,00,6c,00,2c,00,30,00,00,00>> FTP_Fix.txt
	echo [HKEY_CLASSES_ROOT\ftp\shell]>> FTP_Fix.txt
	echo @="open">> FTP_Fix.txt
	set model=[HKEY_CLASSES_ROOT\ftp\shell\open]
	echo.|set/p x=%model%>>FTP_Fix.txt
	goto FTP_Import
::===============================================================================================================
: XP_Fix_FTP
	echo Windows Registry Editor Version 5.00 FTP_Fix.txt
	echo [HKEY_CLASSES_ROOT\ftp]>> FTP_Fix.txt
	echo @="URL:File Transfer Protocol">> FTP_Fix.txt
	echo "EditFlags"=dword:00000002>> FTP_Fix.txt
	echo "ShellFolder"="{63da6ec0-2e98-11cf-8d82-444553540000}">> FTP_Fix.txt
	echo "Source Filter"="{E436EBB6-524F-11CE-9F53-0020AF0BA770}">> FTP_Fix.txt
	echo "FriendlyTypeName"="@C:\\WINDOWS\\system32\\ieframe.dll.mui,-905" >> FTP_Fix.txt
	echo "URL Protocol"="">> FTP_Fix.txt
	echo [HKEY_CLASSES_ROOT\ftp\DefaultIcon]>> FTP_Fix.txt
	echo @=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\>> FTP_Fix.txt
	echo 00,5c,00,73,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,75,00,72,00,\>> FTP_Fix.txt
	echo 6c,00,2e,00,64,00,6c,00,6c,00,2c,00,30,00,00,00>> FTP_Fix.txt
	echo [HKEY_CLASSES_ROOT\ftp\Extensions]>> FTP_Fix.txt
	echo ".IVF"="{C69E8F40-D5C8-11D0-A520-145405C10000}">> FTP_Fix.txt
	echo [HKEY_CLASSES_ROOT\ftp\shell]>> FTP_Fix.txt
	echo @="open">> FTP_Fix.txt
	echo [HKEY_CLASSES_ROOT\ftp\shell\open]>> FTP_Fix.txt
	echo [HKEY_CLASSES_ROOT\ftp\shell\open\command]>> FTP_Fix.txt
	echo @="\"C:\\Program Files\\Internet Explorer\\IEXPLORE.EXE\" %1">> FTP_Fix.txt
	echo [HKEY_CLASSES_ROOT\ftp\shell\open\ddeexec]>> FTP_Fix.txt
	echo @="\"%1\",,-1,0,,,,">> FTP_Fix.txt
	echo "NoActivateHandler"="">> FTP_Fix.txt
	echo [HKEY_CLASSES_ROOT\ftp\shell\open\ddeexec\Application]>> FTP_Fix.txt
	echo @="IExplore">> FTP_Fix.txt
	echo [HKEY_CLASSES_ROOT\ftp\shell\open\ddeexec\ifExec]>> FTP_Fix.txt
	echo @="*">> FTP_Fix.txt
	echo [HKEY_CLASSES_ROOT\ftp\shell\open\ddeexec\Topic]>> FTP_Fix.txt
	set model=@="WWW_OpenURL"
	echo.|set/p x=%model%>>FTP_Fix.txt
	goto FTP_Import
::===============================================================================================================
: FTP_Import
	ren FTP_Fix.txt FTP_Fix.reg
	regedit.exe /s FTP_Fix.reg
	echo Importing FTP Fix
	pause
	del /q /f FTP_Fix.reg
	echo Import Complete.
	pause
	goto Internet_Repair
::===============================================================================================================
:: INTERNET REPAIR 3 - SET DNS TO GOOGLE OR DEFAULT 
: Set_DNS
	set /P "ANSWER=What state do you want the DNS? " (G) Google or (D) Default ... "  
	echo You chose: %ANSWER% 
	if /i "%ANSWER%"=="G" goto Google_DNS 
	if /i "%ANSWER%"=="D" goto Default_DNS 
	echo.
	echo "%choice%" is not valid...please try again
	pause
	cls
	goto Internet_Repair
::===============================================================================================================	
:: SET GOOGLE DNS
: Google_DNS
	set "DNS1=8.8.8.8."
	set "DNS2=8.8.4.4."
	for /f "tokens=1,2,3*" %%i in ('netsh int show interface') do (
		if %%i equ Enabled (
			echo Changing "%%l" : %DNS1% + %DNS2%
			netsh int ipv4 set dns name="%%l" static %DNS1% primary validate=no
			netsh int ipv4 add dns name="%%l" %DNS2% index=2 validate=no
		)
	)
	ipconfig /flushdns
	goto Internet_Repair
::===============================================================================================================
:: SET DEFAULT DNS
: Default_DNS
	set "DNS1=0.0.0.0."
	set "DNS2=0.0.0.0."
	for /f "tokens=1,2,3*" %%i in ('netsh int show interface') do (
		if %%i equ Enabled (
			echo Changing "%%l" : %DNS1% + %DNS2%
			netsh int ipv4 set dns name="%%l" static %DNS1% primary validate=no
			netsh int ipv4 add dns name="%%l" %DNS2% index=2 validate=no
		)
	)
	ipconfig /flushdns
	goto Internet_Repair
::===============================================================================================================
:: INTERNET REPAIR 4 - UNCHECK PROXY CHECK BOX IN LOCAL AREA NETOWORK SETTINGS 
: Remove_Proxy
	REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f
	cls
	goto Internet_Repair
::===============================================================================================================
:================================================================================================================
:: INTERNET REPAIR 5 - OPENS UNINSTAL BROWSER MENU
: Uninstall_Browser
	cls
	set "file=Uninstall Browser"
	echo.
	call :top_box
	echo 	  บ  1. IE 11                                                      บ
	echo 	  บ  2. IE 10                                                      บ
	echo 	  บ  3. IE 9                                                       บ
	echo 	  บ  4. IE 8                                                       บ
	echo 	  บ  5. IE 7                                                       บ
	echo 	  บ  0. Cancel                                                     บ 
	call :bottom_box
	if "%option%"=="1"  goto IE_11
	if "%option%"=="2"  goto IE_10    
	if "%option%"=="3"  goto IE_9
	if "%option%"=="4"  goto IE_8
	if "%option%"=="5"  goto IE_7
	if "%option%"=="0"  goto Internet_Repair
	call :bad_choice
	goto Uninstall_Browser
::===============================================================================================================
:================================================================================================================
:: UNINSTALL BROWSER 1 - UNINSTALL INTERNET EXPLORER 11 (no reboot)
: IE_11
	if /i "%W_V:~0,9%"=="Microsoft" goto Unsupported
	if /i "%W_V:~0,9%"=="Windows V" goto Unsupported
	FORFILES /P %WINDIR%\servicing\Packages /M Microsoft-Windows-InternetExplorer-*11.*.mum /c "cmd /c echo Uninstalling package @fname && start /w pkgmgr /up:@fname /quiet /norestart"
	pause
	goto Uninstall_Browser 
:: UNINSTALL BROWSER 2 - UNINSTALL INTERNET EXPLORER 10 (no reboot)
: IE_10
	if /i "%W_V:~0,9%"=="Microsoft" goto Unsupported
	if /i "%W_V:~0,9%"=="Windows V" goto Unsupported
	FORFILES /P %WINDIR%\servicing\Packages /M Microsoft-Windows-InternetExplorer-*10.*.mum /c "cmd /c echo Uninstalling package @fname && start /w pkgmgr /up:@fname /quiet /norestart"
	pause
	goto Uninstall_Browser
:: UNINSTALL BROWSER 3 - UNINSTALL INTERNET EXPLORER 9 (no reboot)
: IE_9
	if /i "%W_V:~0,9%"=="Microsoft" goto Unsupported
	FORFILES /P %WINDIR%\servicing\Packages /M Microsoft-Windows-InternetExplorer-*9.*.mum /c "cmd /c echo Uninstalling package @fname && start /w pkgmgr /up:@fname /norestart"
	pause
	goto Uninstall_Browser
:: UNINSTALL BROWSER 4 - UNINSTALL INTERNET EXPLORER 8 (no reboot)
: IE_8
	%windir%\ie8\spuninst\spuninst.exe
	pause
	goto Uninstall_Browser	
:: UNINSTALL BROWSER 5 - UNINSTALL INTERNET EXPLORER 7 (no reboot)
: IE_7
	%windir%\ie7\spuninst\spuninst.exe
	pause
	goto Uninstall_Browser	
::===============================================================================================================
:================================================================================================================
:: INTERNET REPAIR 6 - OPENS RESET BROWSER MENU
: Reset_Browser
	cls
	set "file=Reset Browser"
	call :top_box
	echo 	  บ  1. Reset Chrome                                               บ
	echo 	  บ  2. Reset Firefox                                              บ
	echo 	  บ  3. Delete IE Cache                                            บ
	echo 	  บ  4. Delete Google Chrome Cache                                 บ
	echo 	  บ  5. Delete Firefox Cache                                       บ
	echo 	  บ  0. Cancel                                                     บ 
	call :bottom_box
	if "%option%"=="1"  goto  Reset_Chrome  
	if "%option%"=="2"  goto  Reset_Firefox
	if "%option%"=="3"  goto  Delete_IE_Cache
	if "%option%"=="4"  goto  Delete_Google_Cache
	if "%option%"=="5"  goto  Delete_Firefox_Cache
	if "%option%"=="0"  goto  Internet_Repair
	call :bad_choice
	goto Reset_Browser
::===============================================================================================================
:================================================================================================================
:: RESET BROWSER 1 - DELETES GOOGLE CHROME USER DATA FOLDER
: Reset_Chrome
	rd /S /Q "%UserProfile%\AppData\Local\Google\Chrome\User Data"
	goto Reset_Browser
:: RESET BROWSER 2 - OPENS FIREFOX RESET OPTION
: Reset_Firefox
	Firefox -safe-mode 
	goto Reset_Browser
:: RESET BROWSER 3 - CLEAR INTERNET EXPLORER CACHE(Deletes Temporary Internet Files Only)
: Delete_IE_Cache
	RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 8
	erase "%LOCALAPPDATA%\Microsoft\Windows\Tempor~1\*.*" /f /s /q
	for /D %%i in ("%LOCALAPPDATA%\Microsoft\Windows\Tempor~1\*") do rd /S /Q "%%i"
	pause
	goto Internet_Repair
:: RESET BROWSER 4 - CLEAR GOOGLE CHROME CACHE
: Delete_Google_Cache
	erase "%LOCALAPPDATA%\Google\Chrome\User Data\*.*" /f /s /q
	for /D %%i in ("%LOCALAPPDATA%\Google\Chrome\User Data\*") do rd /S /Q "%%i"
	pause
	goto Internet_Repair	
:: RESET BROWSER 5 - CLEAR MOZILLA FIREFOX CACHE
: Delete_Firefox_Cache
	erase "%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*.*" /f /s /q
	for /D %%i in ("%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*") do rd /S /Q "%%i"
	pause
	goto Internet_Repair		
::===============================================================================================================
:: INTERNET REPAIR 7 - PERFORMS INFINITE PING TEST
: Ping_Test
	mode con: cols=100 lines=48
	start cmd /k ping www.google.com -t
	ipconfig /all
	echo.
	echo.
	pause
	goto Internet_Repair
:: INTERNET REPAIR 8 - FLUSHES IP DNS, RESETS WINSOCK AND REBOOTS
: Flush_and_Reset
	ipconfig /flushdns
	netsh winsock reset
	shutdown /r
	exit
:: INTERNET REPAIR 9 - REGISTERS SOFTPUB.DLL
: Repair_HTTPS
	cls
	regsvr32 softpub.dll
	goto Internet_Repair
::===============================================================================================================
:================================================================================================================
:: CONTROL CENTER 3 - REPAIR OPTION MENU
: Repair_OS
	cls
	set "file=Repair OS"
	call :top_box
	echo 	  บ  1. SFC Scan                                                   บ
	echo 	  บ  2. Check Disk                                                 บ
	echo 	  บ  3. Dism Options                                               บ
	echo 	  บ  4  Repair MWI                                                 บ
	echo 	  บ  5. Reset Windows Update Components                            บ
	echo 	  บ  6. System Restore                                             บ
	echo 	  บ  7. Identify unsigned and digitally signed Drivers             บ
	echo 	  บ  8. Admin Account                 (Activate/Deactivate)        บ
	echo 	  บ  0. Cancel                                                     บ 
	call :bottom_box
	if "%option%"=="1"  goto SFC_Scan
	if "%option%"=="2"  goto Check_Disk   
	if "%option%"=="3"  goto Dism_Options
	if "%option%"=="4"  goto Repair_MWI  
	if "%option%"=="5"  goto Rebuild_Updates
	if "%option%"=="6"  goto System_Restore
	if "%option%"=="7"  goto Signed_Drivers
	if "%option%"=="8"  goto Admin_Account
	if "%option%"=="0"  goto Control_Center
	call:Bad_Choice
	goto Repair_OS
::===============================================================================================================
:================================================================================================================
:: REPAIR OS 1 - RUNS A SYSTEM FILE CHECKER SCAN
: SFC_Scan
	if /i "%W_V:~0,9%"=="Microsoft" goto Unsupported
	set "file=SFC Scan"
	call :top_box2
	echo 	  บ                      What is a sfc scan?                       บ
	echo 	  บ                                                                บ
	echo 	  บ                                                                บ
	echo 	  บ              SFC stands for "System File Checker"              บ
	echo 	  บ    It is a utility in Windows that allows users to scan for    บ
	echo 	  บ              corruptions in Windows system files               บ
	echo 	  บ                  and restore corrupted files                   บ
	call :bottom_box2
	sfc /scannow
	pause
	cls
	if /i "%Job%"=="FFTU" goto Check_Disk
	if /i "%Job%"=="MTU" goto Check_Disk
	if /i "%Job%"=="Repairs" goto Check_Disk
	goto Repair_OS
::===============================================================================================================
:: REPAIR OS 2 - RUNS A CHECK DISK SCAN
: Check_Disk 
	set "file=Check Disk"
	call :top_box2
	echo 	  บ                       What is a chkdsk?                        บ
	echo 	  บ                                                                บ
	echo 	  บ                                                                บ
	echo 	  บ                CHKDSK is short for "check disk"                บ
	echo 	  บ             It verifies the file system integrity              บ
	echo 	  บ             Creates and displays a status report               บ
	echo 	  บ                and corrects errors on the disk                 บ
	call :bottom_box2
	chkdsk
	pause
	goto Ask_CMD
::===============================================================================================================
:================================================================================================================
:: REPAIR OS 3 - DEPLOYMENT IMAGE SERVICING AND MANAGEMENT OPTIONS
: Dism_Options
	cls
	if /i "%W_V:~0,9%"=="Microsoft" goto Unsupported
	if /i "%W_V:~0,9%"=="Windows V" goto Unsupported
	if /i "%W_V:~0,9%"=="Windows 7" goto Unsupported
	set "file=Dism Options"
	call :top_box
	echo 	  บ  1. Report                                                     บ
	echo 	  บ  2. Scan                                                       บ
	echo 	  บ  3. Scan and Repair                                            บ
	echo 	  บ  4. Component Cleanup                                          บ
	echo 	  บ  5. Reset Base                                                 บ
	echo 	  บ  6. Error 800F0906 Repair   (Normal Mode Only)                 บ
	echo 	  บ  0. Cancel                                                     บ 
	call :bottom_box
	if "%option%"=="1"  goto Dism_Report
	if "%option%"=="2"  goto Dism_Scan 
	if "%option%"=="3"  goto Dism_Repair
	if "%option%"=="4"  goto Dism_Start_Component_Cleanup  
	if "%option%"=="5"  goto Dism_Reset_Base
	if "%option%"=="6"  goto Dism_Detect_Safe_Mode
	if "%option%"=="0"  goto Repair_OS
	call :bad_choice
	goto Dism_Options
::===============================================================================================================
:================================================================================================================
:: DISM REPAIR 1 - QUERYS A REPORT 
: Dism_Report
	set "file=Dism Health"
	call :top_box2
	echo 	  บ                What is this Dism Check Health?                 บ
	echo 	  บ                                                                บ
	echo 	  บ                                                                บ
	echo 	  บ     It Reports if any component store corruption was found     บ
	echo 	  บ          during the last scan and if its repairable            บ
	call :bottom_box2
	echo.
	Dism /Online /Cleanup-Image /CheckHealth
	pause
	cls
	if /i "%Jobs%"=="YES" goto Restore_Health
	if /i "%Job%"=="Repairs" goto Restore_Health
	goto Dism_Options
::===============================================================================================================
:: DISM REPAIR 2 - RUNS A SCAN 
: Dism_Scan
	set "file=Dism Scan"
	call :top_box2
	echo 	  บ                 What is this Dism Scan Health?                 บ
	echo 	  บ                                                                บ
	echo 	  บ                                                                บ
	echo 	  บ       It scans the system component store for corruption       บ
	echo 	  บ                       and gives a report                       บ
	call :bottom_box2
	Dism /Online /Cleanup-Image /ScanHealth
	pause
	goto Dism_Options
::===============================================================================================================
:: DISM REPAIR 3 - RUNS A REPAIR 
: Dism_Repair
	set "file=Dism Restore Health"
	call :top_box2
	echo 	  บ             What is this Dism Restore Health Scan?             บ
	echo 	  บ                                                                บ
	echo 	  บ                                                                บ
	echo 	  บ         It Scans and Fixes component store corruption          บ
	echo 	  บ                      with Windows Updates                      บ
	call :bottom_box2
	Dism /Online /Cleanup-Image /RestoreHealth
	echo.
	pause
	cls
	if /i "%Job%"=="FFTU" goto Check_Disk
	if /i "%Job%"=="MTU" goto Check_Disk
	if /i "%Job%"=="Repairs" goto Check_Disk
	goto Dism_Options
::===============================================================================================================
:: DISM REPAIR 4 - REMOVES INSTALLED UPDATE PACKAGES (incomplete)
: Dism_Start_Component_Cleanup 
	set "file=Dism Start Component Cleanup"
	call :top_box2
	echo 	  บ           What is this Dism Start Component Cleanup?           บ
	echo 	  บ                                                                บ
	echo 	  บ                                                                บ
	echo 	  บ      Delets previous versions of Windows Updated packages      บ
	echo 	  บ           Windows does this after 30 days anyways              บ
	echo 	  บ                     Were just doing it now                     บ
	call :bottom_box2
	Dism /online /Cleanup-Image /StartComponentCleanup
	echo.
	pause
	goto Dism_Options
::===============================================================================================================
:: DISM REPAIR 5 - REMOVES INSTALLED UPDATE PACKAGES (complete)
: Dism_Reset_Base
	set "file=Dism Reset Base"
	call :top_box2
	echo 	  บ                What is this Dism Reset Base?                   บ
	echo 	  บ                                                                บ
	echo 	  บ                                                                บ
	echo 	  บ  Removes all superseded versions of installed Windows Updates  บ
	echo 	  บ      Installed Windows Updates will become uninstallable       บ
	call :bottom_box2
	Dism /online /Cleanup-Image /StartComponentCleanup /ResetBase
	echo.
	Pause
	goto Dism_Options
::===============================================================================================================
:: DISM REPAIR 6 - REPAIR FOR ERROR 800F0906 (Normal Mode Only)
: Dism_Detect_Safe_Mode
	if /i "%SAFEBOOT_OPTION%"=="" goto Repair_Dism_Error_Select
	if /i "%SAFE_MODE%"=="yes" msg "%username%" This Option Should Be Ran from Normal Mode & goto Dism_Options
: Repair_Dism_Error_Select
	set /P "ANSWER=What would you like to do with the Software Distribution Folder? (R) Rename or (D) Delete ... "  
	echo You chose: %ANSWER% 
	if /i "%ANSWER%"=="R" goto Repair_Dism_Error_Rename_Folders 
	if /i "%ANSWER%"=="D" goto Repair_Dism_Error_Delete_Folders 
: Repair_Dism_Error_Rename_Folders
	Pause
	net stop wuauserv
	if exist %windir%\SoftwareDistribution\Download.old del /f /s /q %windir%\SoftwareDistribution\Download.old
	ren %systemroot%\SoftwareDistribution\Download Download.old
	net start wuauserv
	net stop bits
	net start bits
	net stop cryptsvc
	if exist %windir%\system32\catroot2Old del /f /s /q %windir%\system32\catroot2Old 
	ren %systemroot%\system32\catroot2 catroot2old
	net start cryptsvc
	msg "%username%" Reboot and Run Dism Repair again 
	Pause
	goto Dism_Options
: Repair_Dism_Error_Delete_Folders
	Pause
	net stop wuauserv
	if exist %windir%\SoftwareDistribution\Download del /f /s /q %windir%\SoftwareDistribution\Download
	net start wuauserv
	net stop bits
	net start bits
	net stop cryptsvc
	if exist %windir%\system32\catroot2 del /f /s /q %windir%\system32\catroot2
	net start cryptsvc
	msg "%username%" Reboot and Run Dism Repair again 
	Pause
	goto Dism_Options
::===============================================================================================================
:: REPAIR OS 4 - Test and attempt repair of Windows Management Instrumentation
: Repair_MWI 
	if /i "%W_V:~0,9%"=="Microsoft" echo This function is not supported on XP OS
	if /i "%W_V:~0,9%"=="Microsoft" echo Repair MWI from the Tools section of Dial-A-Fix
	if /i "%W_V:~0,9%"=="Microsoft" Pause	
	if /i "%W_V:~0,9%"=="Microsoft" goto Repair_OS
	Call :MWI_Repair
	goto Repair_OS	
: MWI_Repair
	set Error_No=0
	set ATTEMPT=0
: MWI_Health_Check
	echo CHECKING WMI... ATTEMPT:%ATTEMPT%...
	wmic computersystem get name
	if %ERRORLEVEL%==0 goto MWI_Good
::  FIRST ATTEMPT RESTART WINMGMTS AND DEPENDENT SERVICES
	if %ATTEMPT%==0 goto REPAIR_Attempt_1
::  SECOND ATTEMPT VERIFY SALVAGE THEN RESET REPOSITORY AND SERVICES
	if %ATTEMPT%==1 goto REPAIR_Attempt_2
::  THIRD ATTEMPT REBUILD WMI REPOSITORY AND RESTART SERVICES
	if %ATTEMPT%==2 goto REPAIR_Attempt_3
	goto No_Repair
: REPAIR_Attempt_1
	set ATTEMPT=1
	set Error_No=1001
	echo 1. RESTARTING WMI... ATTEMPT:%ATTEMPT%...&
	for /f "tokens=2 delims= " %%a in (‘sc enumdepend winmgmt^| findstr -i "SERVICE_NAME"‘) do echo 1. RESTARTING WMI... Stopping "%%a"...& net stop "%%a" /y> nul
	echo 1. RESTARTING WMI... Stopping WinMgmt& net stop winmgmt /y> nul& sc stop winmgmt> nul
	ping 127.0.0.1 -n 5
	echo 1. RESTARTING WMI... Starting WinMgmt& sc start winmgmt> nul
	for /f "tokens=2 delims= " %%a in (‘sc enumdepend winmgmt^| findstr -i "SERVICE_NAME"‘) do echo 1. RESTARTING WMI... Starting "%%a"...& sc start "%%a"> nul
	goto MWI_Health_Check
: REPAIR_Attempt_2
	set ATTEMPT=2
	set Error_No=2001
	echo 2. REPAIRING WMI REPOSITORY... ATTEMPT:%ATTEMPT%...
	echo 2. REPAIRING WMI REPOSITORY... 1. Resetting permissions...
	sc sdset winmgmt D:(A;;CCDCLCSWRPWPDTLOCRRC;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;DA)(A;;CCDCLCSWRPWPDTLOCRRC;;;PU)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;SY)
	echo 2. REPAIRING WMI REPOSITORY... 1. Verifying...& %windir%\system32\wbem\winmgmt /verifyrepository
	if %ERRORLEVEL%==0 goto SKIPRESET
	set Error_No=2002
	echo 2. REPAIRING WMI REPOSITORY... 2. Salvaging...& %windir%\system32\wbem\winmgmt /salvagerepository
	if %ERRORLEVEL%==0 goto SKIPRESET
	set Error_No=2003
	echo 2. REPAIRING WMI REPOSITORY... 3. Resetting...& %windir%\system32\wbem\winmgmt /resetrepository
	if %ERRORLEVEL%==0 goto SKIPRESET
	set Error_No=2004
: SKIPRESET
	for /f "tokens=2 delims= " %%a in (‘sc enumdepend winmgmt^| findstr -i "SERVICE_NAME"‘) do echo 2. REPAIRING WMI REPOSITORY... Stopping "%%a"...& net stop "%%a" /y> nul
	echo 2. REPAIRING WMI REPOSITORY... Stopping WinMgmt& net stop winmgmt /y> nul& sc stop winmgmt> nul
	ping 127.0.0.1 -n 5
	echo 2. REPAIRING WMI REPOSITORY.. Starting WinMgmt& sc start winmgmt> nul
	for /f "tokens=2 delims= " %%a in (‘sc enumdepend winmgmt^| findstr -i "SERVICE_NAME"‘) do echo 2. REPAIRING WMI REPOSITORY... Starting "%%a"...& sc start "%%a"> nul
	goto MWI_Health_Check
: REPAIR_Attempt_3
	set ATTEMPT=3
	set Error_No=3001
	echo 3. REBUILDING WMI REPOSITORY... ATTEMPT:%ATTEMPT%...
	for /f "tokens=2 delims= " %%a in (‘sc enumdepend winmgmt^| findstr -i "SERVICE_NAME"‘) do echo 3. REBUILDING WMI REPOSITORY... Stopping "%%a"...& net stop "%%a" /y> nul
	echo 3. REBUILDING WMI REPOSITORY... Stopping BITS& net stop BITS /y> nul& sc stop BITS> nul
	ping 127.0.0.1 -n 5
	echo 3. REBUILDING WMI REPOSITORY... Stopping WinMgmt& net stop winmgmt /y> nul& sc stop winmgmt> nul
	ping 127.0.0.1 -n 5
	%SystemDrive%
	pushd %systemroot%\system32\wbem
	echo 3. REBUILDING WMI REPOSITORY... Deleting WMI Repository& rd /S /Q repository
	if exist %systemroot%\system32\wbem\repository echo 3. REBUILDING WMI REPOSITORY... ERROR! Unable to delete WMI repository. Reboot Required.
	pause
	echo 3. REBUILDING WMI REPOSITORY... Registering DLLs (scecli.dll)& regsvr32 /s %systemroot%\system32\scecli.dll
	echo 3. REBUILDING WMI REPOSITORY... Registering DLLs (userenv.dll)& regsvr32 /s %systemroot%\system32\userenv.dll
	echo 3. REBUILDING WMI REPOSITORY... Compiling MOFs (cimwin32.mof)& mofcomp cimwin32.mof
	echo 3. REBUILDING WMI REPOSITORY... Compiling MOFs (cimwin32.mfl)& mofcomp cimwin32.mfl
	echo 3. REBUILDING WMI REPOSITORY... Compiling MOFs (rsop.mof)& mofcomp rsop.mof
	echo 3. REBUILDING WMI REPOSITORY... Compiling MOFs (rsop.mfl)& mofcomp rsop.mfl
	echo 3. REBUILDING WMI REPOSITORY... Registering DLLs
	for /f %%s in (‘dir /b /s *.dll’) do echo 3. REBUILDING WMI REPOSITORY... Registering DLLs (%%s)& regsvr32 /s %%s> nul
	echo 3. REBUILDING WMI REPOSITORY... Compiling MOFs
	for /f %%s in (‘dir /b *.mof’) do echo 3. REBUILDING WMI REPOSITORY... Compiling MOFs (%%s)& mofcomp %%s> nul
	for /f %%s in (‘dir /b *.mfl’) do echo 3. REBUILDING WMI REPOSITORY... Compiling MFLs (%%s)& mofcomp %%s> nul
	echo 3. REBUILDING WMI REPOSITORY... Registering .exe's
	for %%i in (*.exe) do call :Fix_RegServer %%i
: Fix_RegServer
	if /I (%1) == (wbemcntl.exe) goto Skip_RegServer
	if /I (%1) == (wbemtest.exe) goto Skip_RegServer
	if /I (%1) == (mofcomp.exe) goto Skip_RegServer
	%1 /RegServer
: Skip_RegServer
	echo 3. REBUILDING WMI REPOSITORY... Starting WinMgmt& sc start winmgmt> nul
	ping 127.0.0.1 -n 5
	echo 3. REBUILDING WMI REPOSITORY... Starting BITS& sc start BITS> nul
	for /f "tokens=2 delims= " %%a in (‘sc enumdepend winmgmt^| findstr -i "SERVICE_NAME"‘) do echo 3. REBUILDING WMI REPOSITORY... Starting "%%a"...& sc start "%%a"> nul
	timeout /t 10
	echo 3. REBUILDING WMI REPOSITORY... 1. Verifying...& %windir%\system32\wbem\winmgmt /verifyrepository
	if %ERRORLEVEL%==0 goto SKIPRESET
	set Error_No=3002
	echo 3. REBUILDING WMI REPOSITORY... 2. Salvaging...& %windir%\system32\wbem\winmgmt /salvagerepository
	if %ERRORLEVEL%==0 goto SKIPRESET
	set Error_No=3003
	echo 3. REBUILDING WMI REPOSITORY... 3. Resetting...& %windir%\system32\wbem\winmgmt /resetrepository
	set Error_No=3004
: SKIPRESET
	for /f "tokens=2 delims= " %%a in (‘sc enumdepend winmgmt^| findstr -i "SERVICE_NAME"‘) do echo 3. REBUILDING WMI REPOSITORY... Stopping "%%a"...& net stop "%%a" /y> nul
	echo 3. REBUILDING WMI REPOSITORY... Stopping WinMgmt& net stop winmgmt /y> nul& sc stop winmgmt> nul
	ping 127.0.0.1 -n 5
	echo 3. REBUILDING WMI REPOSITORY... Starting WinMgmt& sc start winmgmt> nul
	for /f "tokens=2 delims= " %%a in (‘sc enumdepend winmgmt^| findstr -i "SERVICE_NAME"‘) do echo 3. REBUILDING WMI REPOSITORY... Starting "%%a"...& sc start "%%a"> nul
	set /p MOF=  Are you are missing application specific data (MOF files) in the repository[Y/N]?
	if /i %MOF%==n goto MWI_Health_Check	
	call :Repair_mof_mfl_files
	goto MWI_Health_Check
: No_Repair
	set Error_No=4001
	echo ERROR:%Error_No% UNABLE TO REPAIR WMI, ATTEMPTS:%ATTEMPT% (%ATTEMPT%:%Error_No%).
	pause
	goto :eof
: MWI_Good
	if %Error_No%==0 echo WMI FUNCTIONING CORRECTLY. NO REPAIR NEEDED.
	if %Error_No% NEQ 0 echo WMI REPAIRED (%ATTEMPT%:%Error_No%).
	pause
	goto :eof
:: Not Tested    Manually recompiling all of the default WMI .mof files and .mfl files
: Repair_mof_mfl_files
	Echo Rebuilding WMI.....Please wait. > c:\gos\wmirebuild.log
	net stop sharedaccess >> c:\gos\wmirebuild.log
	net stop winmgmt /y >> c:\gos\wmirebuild.log
	cd C:\WINDOWS\system32\wbem >> c:\gos\wmirebuild.log
	del /Q Repository >> c:\gos\wmirebuild.log
	c:
	cd c:\windows\system32\wbem >> c:\gos\wmirebuild.log
	rd /S /Q repository >> c:\gos\wmirebuild.log
	regsvr32 /s %systemroot%\system32\scecli.dll >> c:\gos\wmirebuild.log
	regsvr32 /s %systemroot%\system32\userenv.dll >> c:\gos\wmirebuild.log
	mofcomp cimwin32.mof >> c:\gos\wmirebuild.log
	mofcomp cimwin32.mfl >> c:\gos\wmirebuild.log
	mofcomp rsop.mof >> c:\gos\wmirebuild.log
	mofcomp rsop.mfl >> c:\gos\wmirebuild.log
	for /f %%s in ('dir /b /s *.dll') do regsvr32 /s %%s >> c:\gos\wmirebuild.log
	for /f %%s in ('dir /b *.mof') do mofcomp %%s >> c:\gos\wmirebuild.log
	for /f %%s in ('dir /b *.mfl') do mofcomp %%s >> c:\gos\wmirebuild.log
	mofcomp exwmi.mof >> c:\gos\wmirebuild.log
	mofcomp -n:root\cimv2\applications\exchange wbemcons.mof >> c:\gos\wmirebuild.log
	mofcomp -n:root\cimv2\applications\exchange smtpcons.mof >> c:\gos\wmirebuild.log
	mofcomp exmgmt.mof >> c:\gos\wmirebuild.log
	net stop winmgmt >> c:\gos\wmirebuild.log
	net start winmgmt >> c:\gos\wmirebuild.log
	gpupdate /force >> c:\gos\wmirebuild.log
:: This does not work
::	pushd %systemroot%\Windows\system32\wbem\Logs
::	for /f %%s in (‘dir /b *.mof *.mfl’) do mofcomp %%s
::	popd
	goto :eof
::===============================================================================================================
:: REPAIR OS 5 - FULL WINDOWS UPDATE REBUILD
: Rebuild_Updates
	cls
	if /i "%W_V:~0,9%"=="Microsoft" echo This function is not supported on XP OS
	if /i "%W_V:~0,9%"=="Microsoft" Pause	
	if /i "%W_V:~0,9%"=="Microsoft" goto Repair_OS
	if "%SAFE_MODE%"=="yes" echo Please Run in Normal Mode
	if "%SAFE_MODE%"=="yes" Pause	
	if "%SAFE_MODE%"=="yes" goto Repair_OS
::  Stopping Windows Update, BITS, Application Identity, Cryptographic Services and SMS Host Agent services...	
	cls
	echo Step 1 of 10. Stopping Services...
	net stop bits
	net stop wuauserv
	net stop appidsvc
	net stop cryptsvc
	timeout /t 2 /nobreak > nul 	
	cls
	echo Step 2 of 10. Checking if services were stopped successfully...
	sc query wuauserv | findstr /I /C:"STOPPED"
	if %errorlevel% NEQ 0 goto unstoppable	
	sc query bits | findstr /I /C:"STOPPED"
	if %errorlevel% NEQ 0 goto unstoppable
	sc query appidsvc | findstr /I /C:"STOPPED"
	if %errorlevel% NEQ 0 sc query appidsvc | findstr /I /C:"OpenService FAILED 1060"
	if %errorlevel% NEQ 0 goto unstoppable
	sc query cryptsvc | findstr /I /C:"STOPPED"
	if %errorlevel% NEQ 0 goto unstoppable
	sc query ccmexec | findstr /I /C:"STOPPED"
	if %errorlevel% NEQ 0 sc query ccmexec | findstr /I /C:"OpenService FAILED 1060"
	if %errorlevel% NEQ 0 goto unstoppable
	timeout /t 2 /nobreak > nul 
	cls
	echo Step 3 of 10. Deleting AU cache folder and log file... 
	del /f /q "%ALLUSERSPROFILE%\Application Data\Microsoft\Network\Downloader\qmgr*.dat"
	del /f /s /q %SystemRoot%\SoftwareDistribution\*.*  
	del /f /s /q %SystemRoot%\system32\catroot2\*.* 
	del /f /q %SystemRoot%\WindowsUpdate.log  
	del %SYSTEMROOT%\winsxs\pending.xml 
	del %SYSTEMROOT%\WindowsUpdate.log
	timeout /t 2 /nobreak > nul 	
::  Reset the BITS service and the Windows Update service to the default security descriptor.
	cls
	echo Step 4 of 10. Reset BITS and Windows Update service
	sc.exe sdset bits D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)
	sc.exe sdset wuauserv D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)
	timeout /t 2 /nobreak > nul 	
	cls
	echo Step 5 of 10. Re-registering DLL files...
	cd /d %windir%\system32
	regsvr32.exe /s atl.dll
	regsvr32.exe /s urlmon.dll
	regsvr32.exe /s mshtml.dll
	regsvr32.exe /s shdocvw.dll
	regsvr32.exe /s browseui.dll
	regsvr32.exe /s jscript.dll
	regsvr32.exe /s vbscript.dll
	regsvr32.exe /s scrrun.dll
	regsvr32.exe /s msxml.dll
	regsvr32.exe /s msxml3.dll
	regsvr32.exe /s msxml6.dll
	regsvr32.exe /s actxprxy.dll
	regsvr32.exe /s softpub.dll
	regsvr32.exe /s wintrust.dll
	regsvr32.exe /s dssenh.dll
	regsvr32.exe /s rsaenh.dll
	regsvr32.exe /s gpkcsp.dll
	regsvr32.exe /s sccbase.dll
	regsvr32.exe /s slbcsp.dll
	regsvr32.exe /s cryptdlg.dll
	regsvr32.exe /s oleaut32.dll
	regsvr32.exe /s ole32.dll
	regsvr32.exe /s shell32.dll
	regsvr32.exe /s initpki.dll
	regsvr32.exe /s wuapi.dll
	regsvr32.exe /s wuaueng.dll
	regsvr32.exe /s wuaueng1.dll
	regsvr32.exe /s wucltui.dll
	regsvr32.exe /s wups.dll
	regsvr32.exe /s wups2.dll
	regsvr32.exe /s wuweb.dll
	regsvr32.exe /s qmgr.dll
	regsvr32.exe /s qmgrprxy.dll
	regsvr32.exe /s wucltux.dll
	regsvr32.exe /s muweb.dll
	regsvr32.exe /s wuwebv.dll
	timeout /t 2 /nobreak > nul 	
	cls
	echo Step 6 of 10. Resetting Winsock and WinHTTP Proxy...
	netsh winsock reset 
	if /i "%W_V:~0,9%"=="Microsoft" proxycfg.exe -d
	if /i "%W_V:~0,7%"=="Windows" netsh winhttp reset proxy
	timeout /t 2 /nobreak > nul
::  Starting SMS Host Agent, Cryptographic Services, Application Identity, BITS, Windows Update services...	
	cls
	echo Step 7 of 10. Starting Services...
	net start bits
	net start wuauserv
	echo This next service can take a little time to start.... Please wait
	net start appidsvc
	net start cryptsvc
	timeout /t 2 /nobreak > nul 
	cls
	echo Step 8 of 10. Deleting all BITS jobs...
	if /i "%W_V:~0,7%"=="Windows V" bitsadmin.exe /reset /allusers
	timeout /t 2 /nobreak > nul 	
	cls
	echo Step 9 of 10. Forcing AU discovery...
	wuauclt /resetauthorization /detectnow
	timeout /t 2 /nobreak > nul 	
	cls
	echo Setp 10 of 10. Reboot the PC to complete the process
	pause 
	exit
::===============================================================================================================
:: REPAIR OS 6 - OPENS SYSTEM RESTORE PROPERTIES GUI
: System_Restore
	if /i "%W_V:~0,9%"=="Microsoft" %SystemRoot%\system32\restore\rstrui.exe
	if /i "%W_V:~0,9%"=="Microsoft" goto Repair_OS
	if "%Jobs%"=="YES" %SystemRoot%\system32\restore\rstrui.exe
	if "%Jobs%"=="YES" goto Repair_OS
	if /i "%W_V:~0,7%"=="Windows"   systempropertiesprotection
	goto Repair_OS
::===============================================================================================================
:: REPAIR OS 7 - INSTALLED DRIVER INTEGRITY CHECK
: Signed_Drivers
	cls
	start /wait sigverif.exe
	start /wait DxDiag.exe
	goto Repair_OS
::===============================================================================================================
:: REPAIR OS 8 - ENABLE OR DISABLE HIDDEN ADMINSTRATOR ACCOUNTE
: Admin_Account 
	set /P "ANSWER=What state do you want the admin account? (E) Enabled or (D) Disabled ... "  
	echo You chose: %ANSWER% 
	if /i "%ANSWER%"=="E" goto Set_Admin 
	if /i "%ANSWER%"=="D" goto Set_Admin
	call :bad_choice
	goto Repair_OS
: Set_Admin
	if /i "%ANSWER%"=="E" set "file=yes"
	if /i "%ANSWER%"=="D" set "file=no"
	net user administrator /active:%file%
	pause
	goto Repair_OS
:================================================================================================================
:: CONTROL CENTER 4 - AUTO TOOLS
: Auto_Tools
	set "file=Tune-up and Repairs"
	call :top_box
	echo 	  บ                                                                บ
	echo 	  บ  1.  FFTU                                                      บ
	echo 	  บ  2.  MTU                                                       บ
	echo 	  บ  3.  Repairs    (Dism Repair or SFC Scan and Check Disk)       บ
	echo 	  บ  0.  Back                                                      บ
	echo 	  บ                                                                บ
	call :bottom_box
	if "%option%"=="1"   goto  FFTU
	if "%option%"=="2"   goto  MTU
	if "%option%"=="3"   goto  Repairs
	if "%option%"=="0"   goto  GOS_Tools_No_Job
	call :bad_choice
	goto Control_Center
::===============================================================================================================
: FFTU
	set Job=
	set "Job=FFTU"
	set "Jobs=YES"
	Title  -- FFTU -- Geeks on Site 
	goto GOS_Tools
: MTU
	set Job=
	set "Job=MTU"
	set "Jobs=YES"
	Title  -- MTU -- Geeks on Site 
	goto GOS_Tools
: Repairs
	set Job=
	set "Job=Repairs"
	Title  -- Repairs -- Geeks on Site
	goto Auto_Repair
::===============================================================================================================
:================================================================================================================
:: CONTROL CENTER 5 - GOS TOOLS
: GOS_Tools_No_Job
	set Job=
	set "Jobs=No"
: GOS_Tools
	cls
	set "file=GOS Tools"
	call :top_box
	echo 	  บ  1.  Rkill                                (FFTU - MTU)         บ
	echo 	  บ  2.  HitmanPro                            (FFTU - MTU)         บ
	echo 	  บ  3.  Malwarebytes AntiMalware             (FFTU)               บ
	echo 	  บ  4.  CCleaner                             (FFTU - MTU)         บ
	echo 	  บ  5.  Iobituninstaller                     (FFTU - MTU)         บ
	echo 	  บ  6.  Autoruns                             (FFTU)               บ
	echo 	  บ  7.  PatchMyPC                            (FFTU - MTU)         บ
	echo 	  บ  0.  Back                                                      บ
	call :bottom_box
	if "%option%"=="1"   goto  Rkill
	if "%option%"=="2"   goto  HitmanPro
	if "%option%"=="3"   goto  MBAM
	if "%option%"=="4"   goto  CCleaner
	if "%option%"=="5"   goto  Iobit
	if "%option%"=="6"   goto  Autoruns
	if "%option%"=="7"   goto  PatchMyPC
	if "%option%"=="8"   goto  Control_Center
	if "%option%"=="9"   goto  Control_Center
	if "%option%"=="0"   goto  Control_Center
	call :bad_choice
	goto Control_Center
::===============================================================================================================
:================================================================================================================
: Rkill
	cls
	echo.
	if "%Jobs%"=="YES" mode con: cols=50 lines=3
	echo Next Job is HitmanPro
	START CMD /C "c:\gos\3  Rkill.exe"
	if "%Jobs%"=="No" goto GOS_Tools
	timeout /T 10
: HitmanPro
	cls
	echo.
	if "%Jobs%"=="YES" mode con: cols=50 lines=3
	if "%Job%"=="FFTU" echo Next Tool is Malwarebytes
	if "%Job%"=="MTU"  echo Next Tool is CCleaner
	if exist "c:\gos\HitmanPro.exe" start "" c:\gos\HitmanPro.exe /scan /noinstall
	if "%Jobs%"=="No" goto GOS_Tools
	if "%Job%"=="FFTU" echo Press Enter To Start Malwarebytes
	if "%Job%"=="MTU"  echo Press Enter To Start CCleaner
	if "%Job%"=="MTU" goto CCleaner
	pause >nul
: MBAM
	cls
	echo.
	if "%Jobs%"=="YES" mode con: cols=50 lines=3
	if "%Jobs%"=="YES" echo Next Tool is CCleaner
	if exist "%PROGRAMFILES%\Malwarebytes\Anti-Malware\mbam.exe" start "" "%PROGRAMFILES%\Malwarebytes\Anti-Malware\mbam.exe"
	if exist "%PROGRAMFILES%\Malwarebytes\Anti-Malware\mbam.exe" goto MBAM_Started	
	if exist "%PROGRAMFILES%\Malwarebytes Anti-Malware\mbam.exe" start "" "%PROGRAMFILES%\Malwarebytes Anti-Malware\mbam.exe"
	if exist "%PROGRAMFILES%\Malwarebytes Anti-Malware\mbam.exe" goto MBAM_Started
	if exist "%PROGRAMFILES(X86)%\Malwarebytes\Anti-Malware\mbam.exe" start "" "%PROGRAMFILES(X86)%\Malwarebytes\Anti-Malware\mbam.exe"
	if exist "%PROGRAMFILES(X86)%\Malwarebytes\Anti-Malware\mbam.exe" goto MBAM_Started
	if exist "%PROGRAMFILES(X86)%\Malwarebytes Anti-Malware\mbam.exe" start "" "%PROGRAMFILES(X86)%\Malwarebytes Anti-Malware\mbam.exe"
	if exist "%PROGRAMFILES(X86)%\Malwarebytes Anti-Malware\mbam.exe" goto MBAM_Started
: Install_MBAM
	echo Installing Malwarebytes Please Wait
	if /i "%W_V:~0,9%"=="Microsoft" goto MBAM_Legacy
	if /i "%W_V:~0,9%"=="Windows V" goto MBAM_Legacy
	if not exist "c:\gos\mbam.exe" echo MBAM is not in the GOS Folder
	if not exist "c:\gos\mbam.exe" pause & goto GOS_Tools
	start /wait c:\gos\MBAM.exe /verysilent
	goto Finding_MBAM
: MBAM_Legacy
	if not exist "MBAM_Legacy.exe" echo MBAM is not in the GOS Folder
	if not exist "MBAM_Legacy.exe" pause & goto GOS_Tools
	start /wait c:\gos\MBAM_Legacy.exe /verysilent
	goto Finding_MBAM
: Finding_MBAM
	echo.
	echo Waiting for file to populate
	TIMEOUT /T 5 >nul
	if exist "%PROGRAMFILES%\Malwarebytes\Anti-Malware\mbam.exe" goto MBAM
	if exist "%PROGRAMFILES%\Malwarebytes Anti-Malware\mbam.exe" goto MBAM
	if exist "%PROGRAMFILES(X86)%\Malwarebytes\Anti-Malware\mbam.exe" goto MBAM
	if exist "%PROGRAMFILES(X86)%\Malwarebytes Anti-Malware\mbam.exe" goto MBAM
	TIMEOUT /T 5 >nul
	cls
	goto Finding_MBAM
: MBAM_Started	
 	if "%Jobs%"=="No" goto GOS_Tools
	if "%Jobs%"=="YES" echo Next Tool is CCleaner
	echo Press Enter To Start CCleaner
	pause >nul  		
: CCleaner
	cls
	echo.
	if "%Jobs%"=="YES" mode con: cols=50 lines=3
	if "%Jobs%"=="YES"  echo Next Tool is Iobit Uninstaller
	if exist "c:\gos\CCleaner.exe" start "" "c:\gos\CCleaner.exe"
	if "%Jobs%"=="No" goto GOS_Tools
	echo Press Enter to start Iobit Uninstaller
	pause >nul
: Iobit
	cls
	echo.
	if "%Jobs%"=="YES" mode con: cols=50 lines=3
	if "%Job%"=="FFTU" echo Next Tool is Autoruns
	if "%Job%"=="MTU"  echo Next Tool is PatchMyPC
	if exist "c:\gos\Iobituninstaller.exe" start "" "c:\gos\Iobituninstaller.exe"
	if "%Jobs%"=="No" goto GOS_Tools
	if "%Job%"=="FFTU" echo Press Enter to start Autoruns
	if "%Job%"=="MTU"  echo Press Enter to start PatchMyPC
	pause >nul
	if "%Job%"=="MTU" goto PatchMyPC
: Autoruns
	cls
	echo.
	if "%Jobs%"=="YES" mode con: cols=50 lines=3
	if "%Jobs%"=="YES"  echo Next Tool is PatchMyPC
	if exist "c:\gos\Autoruns.exe" start "" "c:\gos\Autoruns.exe""
	if "%Jobs%"=="No" goto GOS_Tools
	echo Press Enter to start PatchMyPC
	pause >nul
	if "%Jobs%"=="YES" goto PatchMyPC 
: PatchMyPC
	cls
	echo.
	if "%Jobs%"=="YES" mode con: cols=50 lines=3
	if "%SAFE_MODE%"=="yes" echo Please Run in Normal Mode
	if "%Jobs%"=="YES"  goto TU_Exist
	if "%SAFE_MODE%"=="yes" Pause & goto GOS_Tools
: TU_Exist
	if "%SAFE_MODE%"=="yes" echo Press Enter to Start Auto Repair
	if "%SAFE_MODE%"=="yes" pause >nul
	if "%SAFE_MODE%"=="yes" goto Auto_Repair
	if exist "c:\gos\PatchMyPC.exe" start "" "c:\gos\PatchMyPC.exe"
	if "%Jobs%"=="No" goto GOS_Tools
: Auto_Repair
	mode con: cols=86 lines=38
	if "%W_V:~0,9%"=="Microsoft" goto Check_Disk
	if "%W_V:~0,9%"=="Windows V" goto SFC_Scan
	if "%W_V:~0,9%"=="Windows 7" goto SFC_Scan
	goto Dism_Report
: Restore_Health	
	echo.
	set /P "ANSWER=	Restore Health? (Y) YES or (N) No ... " 
	echo.	
	echo You chose: %ANSWER% 
	if /i "%ANSWER%"=="Y" goto Dism_Repair
	if /i "%ANSWER%"=="N" goto Check_Disk
::===============================================================================================================
:================================================================================================================
:: CONTROL CENTER 6 - REPORTS
: Reports
	cls
	set "file=Reports"
	call :Top_Box
	echo 	  บ  1. Event Logs                                                 บ
	echo 	  บ  2. Task list (Process)                                        บ
	echo 	  บ  3. Running Services                                           บ
	echo 	  บ  4. Installed Programs                                         บ 
	echo 	  บ  5. Installed Drivers                                          บ
	echo 	  บ  6. Internet Report                                            บ
	echo 	  บ  7. Installed Updates                                          บ
	echo 	  บ  8. Energy Report                                              บ
	echo 	  บ  9. Wifi SSID and Password                                     บ
	echo 	  บ  0. Back                                                       บ  
	call :Bottom_Box
	if "%option%"=="1"  goto Query_Events
	if "%option%"=="2"  goto Task_List 
	if "%option%"=="3"  goto Running_Services
	if "%option%"=="4"  goto Installed_Programs
	if "%option%"=="5"  goto Installed_Drivers
	if "%option%"=="6"  goto Internet_Results
	if "%option%"=="7"  goto Installed_Updates	
	if "%option%"=="8"  goto Energy_Report
	if "%option%"=="9"  goto WIFI_Password
	if "%option%"=="0"  goto Control_Center
	call:bad_choice
	goto Control_Center
::===============================================================================================================
:================================================================================================================
:: QUERY EVENTS 1 - QUERY SYSTEM LOGS
: System_Log
	call :event_log_number
	set "file=System_Log.txt"
	echo.>>%file%
	echo.       *** System  Log *** >> %file%
	call :format_header
	WEVTUtil query-events System /count:%evnum% /rd:true /format:text >> %file%
	call :format_footer
	%~dp0System_Log.txt %MAC%
	cls
	goto Query_Events
::===============================================================================================================
:: QUERY EVENTS 2 - QUERY APPLICATION LOGS
: Application_Log
	call :event_log_number
	set "file=Application_Log.txt"
	echo.>>%file%
	echo.     *** Application Log *** >> %file%
	call :format_header
	WEVTUtil query-events Application /count:%evnum% /rd:true /format:text >> %file%
	call :format_footer
	%~dp0Application_Log.txt %MAC%
	cls
	goto Query_Events
::===============================================================================================================
REM QUERY EVENTS 3 - QUERY SECURITY LOGS
: Security_Log
	call :event_log_number
	set "file=Security_Log.txt"
	echo. >> %file%
	echo.      *** Security  Log *** >> %file%
	call :format_header
	WEVTUtil query-events Security /count:%evnum% /rd:true /format:text >> %file%
	call :format_footer
	%~dp0Security_Log.txt %MAC%
	cls
	goto Query_Events
::===============================================================================================================
:: QUERY EVENTS 4 - QUERY SETUP LOGS
: Setup_Log
	call :event_log_number
	set "file=Setup_Log.txt"
	echo. >> %file%
	echo.        *** Setup  Log *** >> %file%
	call :format_header
	WEVTUtil query-events Setup /count:%evnum% /rd:true /format:text >> %file%
	call :format_footer
	%~dp0Setup_Log.txt %MAC%
	cls
	goto Query_Events
::===============================================================================================================
:: QUERY EVENTS 5 - QUERY ALL LOGS
: All_Event_Logs
	call :event_log_number
	set "file=Event_Logs.txt"
	echo.       *** Event Logs *** >> %file%
	call :format_header
	echo.       *** System Log *** >> %file%
	echo. >> %file%
	WEVTUtil query-events System /count:%evnum% /rd:true /format:text >> %file%
	echo. >> %file%
	echo.       *** Application Log *** >> %file%
	echo. >> %file%
	WEVTUtil query-events Application /count:%evnum% /rd:true /format:text >> %file%
	echo. >> %file%
	echo.       *** Security Log *** >> %file%
	echo. >> %file%
	WEVTUtil query-events Security /count:%evnum% /rd:true /format:text >> %file%
	echo. >> %file%
	echo.       *** Setup Log *** >> %file%
	echo. >> %file%
	WEVTUtil query-events Setup /count:%evnum% /rd:true /format:text >> %file%
	echo. >> %file%
	call :format_footer
	%~dp0Event_Logs.txt %MAC%
	cls
	goto Query_Events
::===============================================================================================================
:: REPORTS 1 - QUERY EVENTS FROM EVENT LOG
: Query_Events
	cls
	call :top_box
	echo 	  บ  1. System Log                                                 บ
	echo 	  บ  2. Application Log                                            บ
	echo 	  บ  3. Security Log                                               บ
	echo 	  บ  4. Setup Log                                                  บ 
	echo 	  บ  5. All Event Logs                                             บ
	echo 	  บ  0. Back                                                       บ  
	call :bottom_box
	if "%option%"=="1"  goto System_Log
	if "%option%"=="2"  goto Application_Log  
	if "%option%"=="3"  goto Security_Log
	if "%option%"=="4"  goto Setup_Log
	if "%option%"=="5"  goto All_Event_Logs
	if "%option%"=="0"  goto Reports
	call :bad_choice
	goto Control_Center
:: REPORTS 2 - QUERY LIST OF RUNNING TASKS
: Task_List
	set "file=Task_List.txt"
	echo.>>%file%
	echo.         ***Task List*** >> %file%
	call :format_header
	tasklist.exe >> %file%
	call :format_footer
	%~dp0Task_List.txt %MAC%
	cls
	goto Reports
:: REPORTS 3 - QUERY LIST OF RUNNING SERVICES
: Running_Services
	set "file="Running_Services.txt" 
	echo.>>%file%
	echo.    *** Running  Services *** >> %file%
	call :format_header
	net start >> %file%
	call :format_footer
	%~dp0Running_Services.txt %MAC%
	cls
	goto Reports
:: REPORTS 4 - QUERY LIST OF INSTALLED PROGRAMS (this is not 100%)
: Installed_Programs
	set "file=Installed_Programs.txt" 
	echo.>>%file%
	echo.   *** Installed  Programs *** >> %file%
	call :format_header
	reg export HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall temp1.txt
	find "DisplayName" temp1.txt| find /V "ParentDisplayName" > temp2.txt
	for /f "tokens=2,3 delims==" %%a in (temp2.txt) do (echo %%a >> %file%)
	del temp1.txt
	del temp2.txt
	call :format_footer
	%~dp0Installed_Programs.txt %MAC%
	cls
	goto Reports
:: REPORTS 5 - QUERY LIST OF INSTALLED DRIVERS
: Installed_Drivers
	set "file=Installed_Drivers.txt" 
	echo.>>%file%
	echo.    *** Installed Drivers *** >> %file%
	call :format_header
	driverquery /FO list /v >> %file%
	call :format_footer
	%~dp0Installed_Drivers.txt %MAC%
	cls
	goto Reports
:: REPORTS 6 - QUERY REPORTS OF INTERNET CONNECTION
: Internet_Results
	cls
	set "file=InternetResults.txt" 
	echo.>>%file%
	call :format_header
	ipconfig /all >> %file% && route print >> %file% && ping localhost >> %file% && ping google.com >> %file%
	call :format_footer
	%~dp0InternetResults.txt %MAC%
	goto Reports
:: REPORTS 7 - QUERY REPORTS INSTALLED WINDOWS UPDATES
: Installed_Updates
	cls
	echo Searching for Installed Windows Updates on this PC....
	echo This can take a few minute 
	echo.
	wmic qfe list brief /format:htable > "c:\gos\Installed_Updates.html"
	%~dp0Installed_Updates.HTML %MAC%
	goto Reports
:: REPORTS 8 - QUERY ENERGY REPORT	
: Energy_Report
	cls
    powercfg energy -output c:\gos\energy-report.html
	%~dp0energy-report.HTML %MAC%
	goto Reports
: WIFI_Password
	cls
	sc query "wlansvc" | find "RUNNING"
	if "%ERRORLEVEL%"=="0" (
    	for /f "tokens=4 delims=: " %%A in ('netsh wlan show profiles') do (for /f "tokens=2,* delims=: " %%B in ('netsh wlan show profiles "%%A" key^=clear ^| find /i "Key Content" ') do set "WiFi_Pass=%%C")
		set "file=WiFi.txt" 
		Netsh WLAN show interface name="Interface_Name"	>> %file%
		echo      WiFi Password: %WiFi_Pass% >> %file%

	) else (
		echo Wifi info is not available the service is off or the hardware is not supported 
		pause
	)
	if exist WiFi.txt %~dp0WiFi.txt %MAC%
	goto Reports
::===============================================================================================================
:================================================================================================================
:: CONTROL CENTER 7 - Create System Restore Point
: Restore_Point
	if /i "%SAFE_MODE%"=="yes" goto System_Info
	mode con: cols=66 lines=8
	color 9F&prompt $v
	if /i "%W_V:~0,9%"=="Microsoft" goto XP_Vista_7_Restore_Point
	if /i "%W_V:~0,9%"=="Windows V" goto XP_Vista_7_Restore_Point
	if /i "%W_V:~0,9%"=="Windows 7" goto XP_Vista_7_Restore_Point
::  CREATE SYSTEM RESTORE POWERSHELL FOR WINDOWS 8 8.1 AND 10
	powershell "Checkpoint-Computer -Description 'GeeksOnSite' | Out-Null"
	cls
	echo Creating System Restore Point....
	goto Control_Center
: XP_Vista_7_Restore_Point
::  CREATE SYSTEM RESTORE POINT VBS
	echo	If GetOS = "Windows XP" Then >> GOSRestorePoint.txt
	echo		CreateSRP >> GOSRestorePoint.txt
	echo	End If >> GOSRestorePoint.txt
	echo.     >> GOSRestorePoint.txt
	echo	If GetOS = "Windows Vista" Or GetOS = "Windows 7" Then >> GOSRestorePoint.txt
	echo		If WScript.Arguments.length =0 Then >> GOSRestorePoint.txt
	echo			Set objShell = CreateObject("Shell.Application") >> GOSRestorePoint.txt
	echo			objShell.ShellExecute "wscript.exe", """" ^& _ >> GOSRestorePoint.txt
	echo			 WScript.ScriptFullName ^& """" ^& " uac","", "runas", 1 >> GOSRestorePoint.txt
	echo		Else >> GOSRestorePoint.txt
	echo			CreateSRP >> GOSRestorePoint.txt
	echo		End If >> GOSRestorePoint.txt
	echo	End If >> GOSRestorePoint.txt
	echo.     >> GOSRestorePoint.txt
	echo	Sub CreateSRP >> GOSRestorePoint.txt
	echo    Set SRP = getobject("winmgmts:\\.\root\default:Systemrestore") >> GOSRestorePoint.txt
	echo    sDesc = "Manual Restore Point" >> GOSRestorePoint.txt
	echo    sDesc = InputBox ("Enter a description.", "System Restore script : Geeks On Site","Geeks On Site") >> GOSRestorePoint.txt
	echo		If Trim(sDesc) ^<^> "" Then >> GOSRestorePoint.txt
	echo    		sOut = SRP.createrestorepoint (sDesc, 0, 100) >> GOSRestorePoint.txt
	echo    		If sOut ^<^> 0 Then >> GOSRestorePoint.txt
	echo	 		WScript.echo "Error " ^& sOut ^& ": Unable to create Restore Point." >> GOSRestorePoint.txt
	echo                else >> GOSRestorePoint.txt
	echo                MsgBox "The restore point " ^& Chr(34) ^& sDesc ^& Chr(34) ^& " was created successfully.", 0, "Create Manual System Restore Point" >> GOSRestorePoint.txt
	echo    		End If >> GOSRestorePoint.txt
	echo    	End If >> GOSRestorePoint.txt
	echo	End Sub >> GOSRestorePoint.txt
	echo.     >> GOSRestorePoint.txt
	echo	Function GetOS     >> GOSRestorePoint.txt
	echo        Set objWMI = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" ^& _ >> GOSRestorePoint.txt
	echo        	".\root\cimv2") >> GOSRestorePoint.txt
	echo        Set colOS = objWMI.ExecQuery("Select * from Win32_OperatingSystem") >> GOSRestorePoint.txt
	echo        For Each objOS in colOS >> GOSRestorePoint.txt
	echo            If instr(objOS.Caption, "Windows 7") Then >> GOSRestorePoint.txt
	echo            	GetOS = "Windows 7"     >> GOSRestorePoint.txt
	echo            ElseIf instr(objOS.Caption, "Vista") Then >> GOSRestorePoint.txt
	echo            	GetOS = "Windows Vista" >> GOSRestorePoint.txt
	echo            elseIf instr(objOS.Caption, "Windows XP") Then >> GOSRestorePoint.txt
	echo          		GetOS = "Windows XP" >> GOSRestorePoint.txt
	echo            End If >> GOSRestorePoint.txt
	echo    Next >> GOSRestorePoint.txt
	echo	End Function >> GOSRestorePoint.txt
	ren GOSRestorePoint.txt GOSRestorePoint.vbs
	start GOSRestorePoint.vbs
	cls
	echo.
	echo             *** Creating System Restore Point ***
	echo.
	echo Please wait until Confirmation of System Restore Point
	pause
	del /q /f GOSRestorePoint.vbs
	goto Control_Center
::===============================================================================================================
:================================================================================================================
:: CONTROL CENTER 8 - System Info
: System_Info
	cls
	set AV=
	set Computer_Name=
	set Manufacturer=
	set Model=
	set Serialnumber=
	set Operating System=
	set SP=
	set Processor=
	set Physical_Memory=
	set Start`Page=
	set Caption=
	set SMART_STATUS=
	set Default_Printer=
	set DefaultGateway=
	set PCIPv4=
	set PCIPv6=
::  Get Anti Virus
	for /F "tokens=2 delims='='" %%A in ('WMIC /Node:localhost /Namespace:\\root\SecurityCenter2 Path AntiVirusProduct Get displayName  /value') do set AV=%%A	
::  Get Computer Name
	for /F "tokens=2 delims='='" %%A in ('wmic OS Get csname /value') do set Computer_Name=%%A
::  Get Computer Manufacturer
	for /F "tokens=2 delims='='" %%A in ('wmic ComputerSystem Get Manufacturer /value') do set Manufacturer=%%A
::  Get Computer Model
	for /F "tokens=2 delims='='" %%A in ('wmic ComputerSystem Get Model /value') do set Model=%%A
::  Get Computer Serial Number
	for /F "tokens=2 delims='='" %%A in ('wmic Bios Get SerialNumber /value') do set Serial_Number=%%A
::  Get Computer OS
	for /F "tokens=2 delims='='" %%A in ('wmic os get Name /value') do set Operating_System=%%A
	for /F "tokens=1 delims='|'" %%A in ("%Operating_System%") do set Operating_System=%%A	
::  Get Computer OS Service Pack
	for /F "tokens=2 delims='='" %%A in ('wmic os get ServicePackMajorVersion /value') do set SP=%%A
::  Get Processor Info 
	for /F "tokens=2 delims='='" %%A in ('wmic CPU Get Name /value') do set Processor=%%A
::  Get Total Ram
	for /f "tokens=2* delims=:" %%A in ('systeminfo ^| findstr /I /C:"Total Physical Memory"') do set Physical_Memory=%%A
::  Get IE Home Page
	for /f "tokens=3*" %%A in ('REG QUERY "HKCU\Software\Microsoft\Internet Explorer\Main" /v "Start Page"') do set Start`Page=%%~B
::  Get Smart Status
	for /F "tokens=2 delims='='" %%A in ('wmic DiskDrive GET Caption /value') do set Caption=%%A
	for /F "tokens=2 delims='='" %%A in ('wmic DiskDrive GET Status /value') do set SMART_STATUS=%%A
::  Get Default Printer Info
	for /f "tokens=2* delims==" %%A in ('wmic printer where "default=True" get name /value') do set Default_Printer=%%A
::  Get Windows 10 Version
	for /f "tokens=2 delims=[]" %%x in ('ver') do set WINVER=%%x
	set WINVER=%WINVER:Version =%
::  Get Default Gateway
	for /f "tokens=1-2 delims=:" %%a in ('ipconfig^|find "Default"') do  set DefaultGateway=%%b
::  Get IPv4 Address	
	for /f "delims=[] tokens=2" %%a in ('ping -4 %computername% -n 1 ^| findstr "["') do (set PCIPv4=%%a)
::  Get IPv6 Address
	for /f "delims=[] tokens=2" %%a in ('ping -6 %computername% -n 1 ^| findstr "["') do (set PCIPv6=%%a)
::  Generate file
	echo.
	echo     System Info as Requested!
	echo.
	set "file=System_Info.txt"
	echo -------------------------------------------- >> %file%
	echo AntiVirus: %AV% >> %file%
	echo Computer Name: %Computer_Name% >> %file%
	echo Manufacturer: %Manufacturer% >> %file%
	echo Model: %Model% >> %file%
	echo Serial Number: %Serial_Number% >> %file%
	if /i "%W_V:~0,9%"=="Microsoft" echo Operating System: %Operating_System%  Service Pack: %SP% >> %file%
	if /i "%W_V:~0,9%"=="Windows V" echo Operating System: %Operating_System%  Service Pack: %SP% >> %file%
	if /i "%W_V:~0,9%"=="Windows 7" echo Operating System: %Operating_System%  Service Pack: %SP% >> %file%
	if /i "%W_V:~0,9%"=="Windows 8" echo Operating System: %Operating_System%  %WINVER% >> %file%
	if /i "%W_V:~0,9%"=="Windows 1" echo Operating System: %Operating_System%  %WINVER% >> %file%
	echo System type: %OSA% Operating System >> %file%
	echo Processor: %Processor% >> %file%
	echo Processor Architecture: %Processor_Architecture% >> %file%
	echo Installed Physical Memory (RAM): %Physical_Memory% >> %file%
	call :drive_size
	echo. >> %file%
	echo IE Home Page: %Start`Page% >> %file%
	call :google_home
	call :firefox_home
	echo. >> %file%
	echo Default Printer: %Default_Printer% >> %file%
	wmic printer get name /value |more > Installed_Printers_List.txt
	findstr /v /r /c:"^$" /c:"^[\ \	]*$" "Installed_Printers_List.txt" >> %file%
	echo. >> %file%
	echo. >> %file%
	echo -------------------------------------------- >> %file%
	%~dp0System_Info.txt %MAC% 
	del System_Info.txt
	del Installed_Printers_List.txt
	del TechnicianTool.tmp
	cls
	goto Control_Center
::  QUERYS HARD DRIVE SIZE AND FREE SPACE
: drive_size
	setlocal enabledelayedexpansion
	WMIC LOGICALDISK where drivetype=3 get caption,size,FreeSpace>%~n0.tmp
	for /f "tokens=1-3 skip=1" %%a in ('type "%~n0.tmp"') do call :displayinfo %%a %%b %%c
	exit /b
: displayinfo
	set "drive=%1"
	set "free=%2"
	set "total=%3"
	call :convertbytes total
	call :convertbytes free
	echo Hard Drive %drive% Total: %total%. Free: %free%>> %file%
	goto :eof
: convertbytes
	set "str=!%1!"
	set "sign="
	set "bytes=0"
	set "fraction=0"  
: loop
    set "fraction=%bytes:~0,1%"
    set "bytes=%str:~-3%"
    set "str=%str:~0,-3%"
    if "%sign%"=="GB" set "sign=TB"
    if "%sign%"=="MB" set "sign=GB"
    if "%sign%"=="KB" set "sign=MB"
    if "%sign%"=="B"  set "sign=KB"
    if not defined sign set "sign=B"
	if defined str goto loop
	set "%1=%bytes%.%fraction% %sign%"
	setlocal disabledelayedexpansion
	goto :eof
::  QUERYS GOOGLE HOMEPAGE
: google_home
	set js="%temp%\extractChromeHomepage%random%.js"
::  List all Chrome persons
	(
		set /p .=settings=<nul
		type "%LocalAppData%\Google\Chrome\User Data\Local State"
		echo ;for^(var k in settings.profile.info_cache^) WScript.echo^(k^);
	)>%js%
::  Get the homepage for each Chrome person
	for /f "delims=" %%a in ('cscript //nologo %js%') do (
		(
			set /p .=settings=<nul
			type "%LocalAppData%\Google\Chrome\User Data\%%a\Secure Preferences"
			echo ;WScript.echo^("Chrome homepage (%%a): " + settings.homepage^);
		)>%js%
		cscript //nologo %js% >> %file%
	)
	del %js%
	goto :eof
::  QUERYS FIREFOX HOMEPAGE
: firefox_home
	setlocal enabledelayedexpansion
	for /f "delims== tokens=1*" %%a in ('
		findstr /i "Name= Path=" "%AppData%\Mozilla\Firefox\profiles.ini"
	') do (
		if %%a==Name (
			set "name=%%b"
		) else (
			set "profile=%%b"
			set "profile=%AppData%\Mozilla\Firefox\!profile:/=\!\prefs.js"
			if exist "!profile!" (
				for /f "tokens=2 delims=,) " %%b in ('
					findstr "\<browser.startup.homepage\>" "!profile!"
				') do echo Firefox homepage ^(!name!^): %%~b >> %file%
			)
		)
	)
	setlocal disabledelayedexpansion 
	goto :eof	
::===============================================================================================================
:================================================================================================================
:: CONTROL CENTER 0 - CLEANS UP - FROM MTU AND FFTU  
: Clean_Exit
	cls
	pushd c:\gos\
	if exist "%USERPROFILE%\Desktop\Rkill*.txt"     del /q /f "%USERPROFILE%\Desktop\Rkill*.txt"
	if exist "%USERPROFILE%\Desktop\rkill"          rd /s /Q "%USERPROFILE%\Desktop\rkill"
	if exist "%USERPROFILE%\Desktop\RKreport*.txt"  del /q /f "%USERPROFILE%\Desktop\RKreport*.txt" 
	if exist "%USERPROFILE%\Desktop\RK_Quarantine"  rd /Q "%USERPROFILE%\Desktop\RK_Quarantine" 
	if exist "%USERPROFILE%\Desktop\ComboFix.exe"   del /q /f "%USERPROFILE%\Desktop\ComboFix.exe" 
	if exist "C:\TDSSKiller*.txt"                   del /q /f "C:\TDSSKiller*.txt"
	if exist "C:\AdwCleaner"                        rd /S /Q "C:\AdwCleaner"
	if exist "%USERPROFILE%\Desktop\mbar"           move /y "%USERPROFILE%\Desktop\mbar" 
:: Turn on Windows Firewall
	if "%W_V:~0,9%"=="Microsoft" netsh firewall set opmode mode=ENABLE
	if not "%W_V:~0,9%"=="Microsoft" netsh advfirewall set currentprofile state on
	if not "%W_V:~0,9%"=="Microsoft" netsh advfirewall set allprofiles state on
	cls
	echo.
	echo.
	echo.
	echo.
	echo                ฑฑฒฒฒฒฒฒÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛฒฒฒฒฒฑฑ
	echo               ฐฑฑฒฒฒฒÛÛÛ                                         ÛÛÛฒฒฒฒฑฑฐ
	echo              ฐฐฑฑฒฒฒÛÛ                                             ÛÛฒฒฒฑฑฐฐ
	echo             ฐฐฑฑฒฒÛÛ        Operation Successfully Completed        ÛÛฒฒฑฑฐฐ
	echo              ฐฐฑฑฒฒฒÛÛ                                             ÛÛฒฒฒฑฑฐฐ
	echo               ฐฑฑฒฒฒฒÛÛÛ                                         ÛÛÛฒฒฒฒฑฑฐ
	echo                ฑฑฒฒฒฒฒÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛฒฒฒฒฒฑฑ
	echo. 
	echo.
	echo.
	echo.
	if /i "%W_V:~0,9%"=="Microsoft" pause & Exit /b
	timeout /t 2
	ENDLOCAL
	Exit /B 
::===============================================================================================================
:================================================================================================================
REM SYSTEM WIDE
: cancel
	cls
	goto Control_Center
: warn
	msg "%username%" Machine OS cannot be determined.
	pause
	cls
	goto Control_Center
: unstoppable
	echo "%username%" Failed to stop the BITS service or the Windows Update service or the Cryptographic service.
	echo Please reboot and try again.
	pause
	cls
	goto Control_Center
: unsupported
	msg "%username%" This Option isn?t supported on this OS.
	pause
	cls
	goto Control_Center
: event_log_number
	set /P "evnum=Enter the number of events you would like in your report: " 
	set "file=Query Last %evnum% Events From Event Log"
	cls
	goto :eof
: format_header
	echo.        ***************** >> %file%
	echo.         %Date% >> %file%
	echo.           %Time% >> %file%
	echo. >> %file%
	goto :eof
: format_footer
	echo. >> %file%
	echo. ***End Report*** >> %file%
	goto :eof
: top_Box	
	cls
	echo.
	if exist /i "%Job%"="FFTU" echo 			Select where you would like to Start
	if exist /i "%Job%"="MTU" echo 			Select where you would like to Start
	echo.
	echo   	  %file%	                                                   
	echo. 
	echo. 
	echo   	  ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	echo 	  บ                                                                บ
	echo 	  บ                                                                บ
	echo 	  บ  Please Make a Choice By typing the corresponding number...    บ
	echo 	  บ                                                                บ
	echo 	  บ                                                                บ
	goto :eof
: top_box2	
	cls
	echo.
	echo.
	echo   	  %file%	                                                   
	echo. 
	echo. 
	echo   	  ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	echo 	  บ                                                                บ
	echo 	  บ                                                                บ
	echo 	  บ                                                                บ
	goto :eof
: bottom_box	
	echo 	  บ                                                                บ
	echo 	  บ                                                                บ
	echo 	  ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	echo.
	echo.
	echo.
	set /a "counter=0"
	set /p "option= Enter Choice: "
	set /a "counter= %counter%+%option%"
	goto :eof
: bottom_box2	
	echo 	  บ                                                                บ
	echo 	  บ                                                                บ
	echo 	  ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	echo.
	echo.
	echo.
	goto :eof
: bad_choice
	echo.
	echo "%choice%" is not valid...please try again
	pause
	cls
	goto :eof
: Ask_CMD
	echo.
	set /P "ANSWER=	Open CMD? (Y) YES or (N) No ... " 
	echo.	
	echo You chose: %ANSWER% 
	if /i "%ANSWER%"=="Y" goto Open_CMD 
	if /i "%ANSWER%"=="N" goto Clean_Exit
: Open_CMD  
	start CMD
	if "%Jobs%"=="YES" goto Clean_Exit
	goto Repair_OS
::===============================================================================================================
:================================================================================================================
::===============================================================================================================
:: CONTROL CENTER 9 - DISPLAYS ABOUT INFO
: about
	mode con: cols=92 lines=18
	color 1A&prompt $v
	echo.
	echo.
	echo  ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
	echo "บ   _________           ____                                  ________  _ _____	บ";
	echo "บ  __   ____/_ __ _ __ __/ /_  _______   _____________      ___/  ___/ ( ) _/ /_ ___	บ";
	echo "บ ___  / __ _/ _ \/ _ \_/ / / __/ ___/  __/ __ \_  __ \   _____\  \ _ __ /_  __// _ \	บ";
	echo "บ   / /_/ / /  __/  __// , <   (__  )    / /_/ // / / /      __/  /_ / /  / /_ /  __/	บ";
	echo "บ   \____/  \___/\___//_/ \_\ /____/     \____//_/ /_/      /____/  /_/   \__/ \___/	บ";
	echo  บ                                                               			บ
	echo  ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	echo.
	echo         					 Author  :  John Clippinger   
	echo        						 E-Mail  :  jclippinger@geeksonsite.com  
	echo         					 Website :  www.geeksonsite.com 
	echo         					 Created :  07/22/2018
	echo        						 Version :  %SCRIPT_VERSION%
	echo.
	echo License key: %random% %random% %random% %random% %random% 
	echo.
	pause >nul
	goto :eof
::===============================================================================================================
:================================================================================================================

	
	