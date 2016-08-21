:: File    :  TechnicianTool
:: This is only a tool used to aid a Trained Technician with his/her quest to repair a computer that has OS corruption and/or infection.           
:: Most of this is common knowledge among the I.T. community or can be found with very simple Ninja Google Searching Skills.
:: DO NOT copy or edit anything you do not understand unless you are testing it on a Virtual Machine. In that case have fun and keep learning... 
:================================================================================================================

:: =============*********************************************************************************============= ::
:: ************* Don't edit anything below this line. Serious operating system damage can occur. ************* ::
:: =============*********************************************************************************============= ::

:: 3.0.3.2  Added Rebuild for Windows updates
:: 3.0.3.2  Added reg key to enable windows installer in safe mode
:: 3.0.3.1  Added Speccy and BlueScreenView to the GOS Cleanup/Rename

:================================================================================================================
::===============================================================================================================
:: DEFINE SYSTEM ENVIRONMENT
	set SCRIPT_VERSION=3.0.3.2
	Title  ------- GEEKS ON SITE ------ Version %SCRIPT_VERSION%
	@echo off
	setlocal
	mode con: cols=46 lines=2
	color 9F&prompt $v
	cd /d %~dp0
	set "MAC=00:00:00:00:00:00"
	set "TechnicianToolpath=%~dp0"
	set "TechnicianToolpath=%TechnicianToolpath:~0,-1%"
	set "TechnicianToolname=%~n0.bat"
:================================================================================================================
::===============================================================================================================
:: GET ADMINISTRATIVE RIGHTS
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
:================================================================================================================
::===============================================================================================================
:: FIND OPERATING SYSTEM ARCHITECTURE 
	reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > nul && set "OSA=32-bit" || set "OSA=64-bit"
:: FIND OPERATING SYSTEM
	set W_V=
	for /f "tokens=3*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName ^| Find "ProductName"') do set W_V=%%i %%j
:: FIND OPERATING MODE
	set SAFE_MODE=
	if /i "%SAFEBOOT_OPTION%"=="MINIMAL" set "SAFE_MODE=yes"
	if /i "%SAFEBOOT_OPTION%"=="NETWORK" set "SAFE_MODE=yes"
	if /i "%SAFEBOOT_OPTION%"=="" set "SAFE_MODE=no"
:================================================================================================================
::	Adds GOS folder into the PATH list for users
	if /i "%W_V:~0,7%"=="Windows" goto skipped_path
	echo ;%PATH%; | find /C /I ";c:\gos;" >nul
	if %ERRORLEVEL% NEQ 0 setx path "%path%;c:\gos"
:================================================================================================================
::===============================================================================================================
:: ENABLES WINDOWS INSTALLER IN SAFE MODE
	if /i "%SAFE_MODE%"=="no" goto skipped_path
	echo Windows Registry Editor Version 5.00 > Safe_MSI.txt
	echo. >> Safe_MSI.txt
	echo "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\Network\MSIServer" /VE /T REG_SZ /F /D "Service"
	echo net start msiserver 
	ren Safe_MSI.txt Safe_MSI.reg
	regedit.exe /s Safe_MSI.reg
	del /q /f Safe_MSI.reg
: skipped_path
:================================================================================================================
::===============================================================================================================
:: ENABLES WINDOWS INSTALLER IN SAFE MODE
	if /i "%W_V:~0,9%"=="Microsoft" goto Connection_Cleanup
	if /i "%SAFE_MODE%"=="no" goto Connection_Cleanup
	echo Windows Registry Editor Version 5.00 > Safe_MSI.txt
	echo. >> Safe_MSI.txt
	echo "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\Network\MSIServer" /VE /T REG_SZ /F /D "Service"
	echo net start msiserver 
	ren Safe_MSI.txt Safe_MSI.reg
	regedit.exe /s Safe_MSI.reg
	del /q /f Safe_MSI.reg
::===============================================================================================================	
:: REMOVES INCOMPATIBLE PROGRAMS FROM THE GOS FOLDER AND REMOVES ARCHITECTURE INDICATOR
	pushd c:\gos\
	if exist "1 - TeamViewer_GOS.exe" goto Connection_Cleanup
	if exist "1 - TeamViewer-GOS.exe" ren "1 - TeamViewer-GOS.exe" "1 - TeamViewer_GOS.exe" 
	if "%OSA%"=="32-bit" goto Clean_GOS_64
	if "%OSA%"=="64-bit" goto Clean_GOS_32
: Clean_GOS_64
	if exist Autoruns-64.exe       del /q /f  Autoruns-64.exe
	if exist CCleaner-64.exe       del /q /f  CCleaner-64.exe
	if exist HitmanPro-64.exe      del /q /f  HitmanPro-64.exe
	if exist RogueKiller-64.exe    del /q /f  RogueKiller-64.exe
	if exist Speccy-64.exe         del /q /f  Speccy-64.exe
	if exist BlueScreenView-64.exe del /q /f  BlueScreenView-64.exe
	if exist Autoruns-32.exe       ren Autoruns-32.exe       Autoruns.exe
	if exist CCleaner-32.exe       ren CCleaner-32.exe       CCleaner.exe
	if exist HitmanPro-32.exe      ren HitmanPro-32.exe      HitmanPro.exe
	if exist RogueKiller-32.exe    ren RogueKiller-32.exe    RogueKiller.exe
	if exist Speccy-32.exe         ren Speccy-32.exe         Speccy.exe
	if exist BlueScreenView-32.exe ren BlueScreenView-32.exe BlueScreenView.exe
	popd
	cls
	goto Add_Reg_Fav 
: Clean_GOS_32
	if exist Autoruns-32.exe       del /q /f  Autoruns-32.exe
	if exist CCleaner-32.exe       del /q /f  CCleaner-32.exe
	if exist HitmanPro-32.exe      del /q /f  HitmanPro-32.exe
	if exist RogueKiller-32.exe    del /q /f  RogueKiller-32.exe
	if exist Speccy-32.exe         del /q /f  Speccy-32.exe
	if exist BlueScreenView-32.exe del /q /f  BlueScreenView-32.exe
	if exist Autoruns-64.exe       ren Autoruns-64.exe       Autoruns.exe
	if exist CCleaner-64.exe       ren CCleaner-64.exe       CCleaner.exe
	if exist HitmanPro-64.exe      ren HitmanPro-64.exe      HitmanPro.exe
	if exist RogueKiller-64.exe    ren RogueKiller-64.exe    RogueKiller.exe
	if exist Speccy-64.exe         ren Speccy-64.exe         Speccy.exe
	if exist BlueScreenView-64.exe ren BlueScreenView-64.exe BlueScreenView.exe
	popd
	cls
	goto Add_Reg_Fav 
:================================================================================================================
::===============================================================================================================
: Add_Reg_Fav
	cls
:: Check Windows Version
	if /i "%W_V:~0,9%"=="Microsoft" goto XP_FAV
	if /i "%W_V:~0,7%"=="Windows"   goto Newer_FAV
	goto warn
: Newer_FAV
	echo Windows Registry Editor Version 5.00 > Registry_Favorites.txt
	echo. >> Registry_Favorites.txt
    echo [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit\Favorites] >> Registry_Favorites.txt
    echo "Printers - Environments"="Computer\\HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Print\\Environments" >> Registry_Favorites.txt
    echo "Favorites"="Computer\\HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Applets\\Regedit\\Favorites" >> Registry_Favorites.txt
    echo "msconfig run 2"="Computer\\HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Run" >> Registry_Favorites.txt
    echo "msconfig run 3"="Computer\\HKEY_CURRENT_USER\\Software\\Microsoft\\Windows NT\\CurrentVersion\\Windows Values named Run & Load" >> Registry_Favorites.txt
    echo "msconfig disabled run 1"="Computer\\HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Shared Tools\\MSConfig\\startupreg" >> Registry_Favorites.txt
    echo "msconfig disabled run 2"="Computer\\HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Shared Tools\\MSConfig\\startupfolder" >> Registry_Favorites.txt
    echo "Remove invalid installed entries"="Computer\\HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall" >> Registry_Favorites.txt
    echo "Uninstall"="Computer\\HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall" >> Registry_Favorites.txt
    echo "msconfig run 1 "="Computer\\HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run" >> Registry_Favorites.txt
    echo "Upper and Lower"="Computer\\HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Class" >> Registry_Favorites.txt
    echo "Winlogon"="Computer\\HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon" >> Registry_Favorites.txt
    echo "Home"="Computer\\" >> Registry_Favorites.txt
    echo "AV Disabler"="HKEY_LOCAL_MACHINE\\Software\\Policies\\Microsoft\\Windows\\Safer\\CodeIdentifiers\\0\\Paths" >> Registry_Favorites.txt
	ren Registry_Favorites.txt Registry_Favorites.reg
	regedit.exe /s Registry_Favorites.reg
	del /q /f Registry_Favorites.reg
	goto Suppres_IE_Popup
: XP_FAV
	echo Windows Registry Editor Version 5.00 > Registry_Favorites.txt
	echo. >> Registry_Favorites.txt
    echo [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit\Favorites] >> Registry_Favorites.txt
    echo "Printers - Environments"="Computer\\HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Print\\Environments" >> Registry_Favorites.txt
    echo "Favorites"="Computer\\HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Applets\\Regedit\\Favorites" >> Registry_Favorites.txt
    echo "XP Restore my Active Desktop"="Computer\\HKEY_CURRENT_USER\\Software\\Microsoft\\Internet Explorer\\Desktop\\SafeMode\\Components" >> Registry_Favorites.txt
    echo "XP AV software restriction policy"="Computer\\HKEY_LOCAL_MACHINE\\Software\\Policies\\Microsoft\\Windows\\Safer\\CodeIdentifier s\\0\\Paths" >> Registry_Favorites.txt
    echo "msconfig run 2"="Computer\\HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Run" >> Registry_Favorites.txt
    echo "msconfig run 3"="Computer\\HKEY_CURRENT_USER\\Software\\Microsoft\\Windows NT\\CurrentVersion\\Windows Values named Run & Load" >> Registry_Favorites.txt
    echo "msconfig disabled run 1"="Computer\\HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Shared Tools\\MSConfig\\startupreg" >> Registry_Favorites.txt
    echo "msconfig disabled run 2"="Computer\\HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Shared Tools\\MSConfig\\startupfolder" >> Registry_Favorites.txt
    echo "Remove invalid installed entries"="Computer\\HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall" >> Registry_Favorites.txt
    echo "Uninstall"="Computer\\HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall" >> Registry_Favorites.txt
    echo "msconfig run 1 "="Computer\\HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run" >> Registry_Favorites.txt
    echo "Upper and Lower"="Computer\\HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Class" >> Registry_Favorites.txt
    echo "Winlogon"="Computer\\HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon" >> Registry_Favorites.txt
    echo "Home"="Computer\\" >> Registry_Favorites.txt
    echo "AV Disabler"="HKEY_LOCAL_MACHINE\\Software\\Policies\\Microsoft\\Windows\\Safer\\CodeIdentifiers\\0\\Paths" >> Registry_Favorites.txt
	ren Registry_Favorites.txt Registry_Favorites.reg
	regedit.exe /s Registry_Favorites.reg
	del /q /f Registry_Favorites.reg
	goto Suppres_IE_Popup 
:================================================================================================================
::===============================================================================================================
:: CLEANS UP DOWNLOAD FOLDER AFTER REMOTE CONNECTON PROCESS
: Connection_Cleanup
	if exist "%USERPROFILE%\Downloads\Support-LogMeInRescue*.exe" del /q /f "%USERPROFILE%\Downloads\Support-LogMeInRescue*.exe"
	if exist "%USERPROFILE%\Downloads\TeamViewer*.exe"          del /q /f "%USERPROFILE%\Downloads\TeamViewer*.exe" 
::===============================================================================================================		
: Suppres_IE_Popup
:: THIS CHECKS TO SEE IF WE ARE ON XP OR WINDOWS 10 BECAUSE WE DONT NEED TO MAKE CHANGES TO IT SO IT ENDS WITHOUT MAKING CHANGES
	if /i "%W_V:~0,9%"=="Microsoft" goto Enable_legacy_Mode 
	if /i "%W_V:~0,9%"=="Windows 1" goto Enable_legacy_Mode 
:================================================================================================================
::===============================================================================================================
:: THIS CHECKS THE ARCHITECTURE SO WE ADD THE CORRECT KEYS FOR THE OS
	if "%OSA%"=="32-bit" goto Reg_Add_32
	if "%OSA%"=="64-bit" goto Reg_Add_64
:================================================================================================================
::===============================================================================================================
:: THIS ADDS THE KEYS FOR WINDOWS X86 OS
: Reg_Add_32	
	echo Windows Registry Editor Version 5.00 > IE_Stop_EOL_Message.txt
	echo. >> IE_Stop_EOL_Message.txt
	echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_DISABLE_IE11_SECURITY_EOL_NOTIFICATION] >> IE_Stop_EOL_Message.txt
	echo "iexplore.exe"=dword:00000001 >> IE_Stop_EOL_Message.txt
	ren IE_Stop_EOL_Message.txt IE_Stop_EOL_Message.reg
	regedit.exe /s IE_Stop_EOL_Message.reg
	del /q /f IE_Stop_EOL_Message.reg
	goto Enable_legacy_Mode 
:================================================================================================================
::===============================================================================================================
:: THIS ADDS THE KEYS FOR WINDOWS X64 OS
: Reg_Add_64
	echo Windows Registry Editor Version 5.00 > IE_Stop_EOL_Message.txt
	echo. >> IE_Stop_EOL_Message.txt
	echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_DISABLE_IE11_SECURITY_EOL_NOTIFICATION] >> IE_Stop_EOL_Message.txt 
	echo "iexplore.exe"=dword:00000001 >> IE_Stop_EOL_Message.txt
	echo [HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_DISABLE_IE11_SECURITY_EOL_NOTIFICATION] >> IE_Stop_EOL_Message.txt
	echo "iexplore.exe"=dword:00000001 >> IE_Stop_EOL_Message.txt
	ren IE_Stop_EOL_Message.txt IE_Stop_EOL_Message.reg
	regedit.exe /s IE_Stop_EOL_Message.reg
	del /q /f IE_Stop_EOL_Message.reg
	goto Enable_legacy_Mode 
:================================================================================================================
::===============================================================================================================
:: ENABLES LEGACY MODE (Only for 8, 8.1 and 10.)
: Enable_legacy_Mode 
	if /i "%W_V:~0,9%"=="Microsoft" goto Password
	if /i "%W_V:~0,9%"=="Windows V" goto Password
	if /i "%W_V:~0,9%"=="Windows 7" goto Password
	bcdedit /set {default} bootmenupolicy legacy
	cls
	goto Password
::===============================================================================================================
:: PROMPTS FOR PASSWORD (This is to push the End User to the disclaimer if they want to use this tool. Password is GOS.)
: Password
	mode con: cols=66 lines=8
	color 9F&prompt $v
	echo.
	echo                         *** LOCKED ***
	echo.
	echo  Please enter the password.
	echo.
	set/p "GOS= Password: "
	if NOT %GOS%==GOS goto Disclaimer
	goto Control_Center
::===============================================================================================================
:: DISPLAYS THE DISCLAIMER (Self distructs if the End User dont Agree)
: Disclaimer
	cls
	SETLOCAL ENABLEDELAYEDEXPANSION
	mode con: cols=86 lines=18
	color CF
	echo.
	echo 	  Thats the Wrong Password so you get to see this Disclaimer
	echo.
	echo    ********************* TechnicianTool Disclaimer *************************
	echo    *                                                                       *
	echo    *      NOTE^^! By running this you accept COMPLETE responsibility^^!        *
	echo    *                                                                       *
	echo    *                    This has NO WARRANTY ^^!^^!^^!                           *
	echo    *                                                                       *
	echo    *                      USE AT YOUR OWN RISK !!!                            *
	echo    *                                                                       *
	echo    *************************************************************************
	echo.
	echo.
	echo    Type I AGREE ^(all caps^) to accept this and go to the main menu.
	echo.
	set /p "CHOICE= Response: "
	if not "!CHOICE!"=="I AGREE" (goto) 2>nul & del "%~f0"
	ENDLOCAL DISABLEDELAYEDEXPANSION
	goto Control_Center
:================================================================================================================
::===============================================================================================================
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
	echo 	  บ  4.  System Information                                        บ
	echo 	  บ  5.  Create System Restore Point                               บ
	echo 	  บ  6.  Auto Repair                                               บ
	echo 	  บ  7.  Tools                                                     บ
	echo 	  บ  8.  Reports                                                   บ
	echo 	  บ  9.  About                                                     บ
	echo 	  บ  0.  Clean Up and Exit                                         บ
	call :bottom_box
	if "%option%"=="1"   goto Printer_Repair 
	if "%option%"=="2"   goto Internet_Repair  
	if "%option%"=="3"   goto Repair_OS 
	if "%option%"=="4"   goto System_Info
	if "%option%"=="5"   goto System_Restore_Point
	if "%option%"=="6"   goto Auto_Tools
	if "%option%"=="7"   goto GOS_Tools_No_Job
	if "%option%"=="8"   goto Reports
	if "%option%"=="9"   call :about&& goto Control_Center
	if "%option%"=="0"   goto Clean_Exit
	call :bad_choice
	goto Control_Center
:================================================================================================================
::===============================================================================================================
:: CONTROL CENTER 8 - REPORTS
: Reports
	set "file=Reports"
	call :Top_Box
	echo 	  บ  1. Event Logs                                                 บ
	echo 	  บ  2. Task list (Process)                                        บ
	echo 	  บ  3. Running Services                                           บ
	echo 	  บ  4. Installed Programs                                         บ 
	echo 	  บ  5. Installed Drivers                                          บ
	echo 	  บ  6. Internet Report                                            บ
	echo 	  บ  0. Back                                                       บ  
	call :Bottom_Box
	if "%option%"=="1"  goto Query_Events
	if "%option%"=="2"  goto Task_List 
	if "%option%"=="3"  goto Running_Services
	if "%option%"=="4"  goto Installed_Programs
	if "%option%"=="5"  goto Installed_Drivers
	if "%option%"=="6"  goto Internet_Results	
	if "%option%"=="0"  goto Control_Center
	call:bad_choice
	goto Control_Center
::===============================================================================================================
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
::===============================================================================================================
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
::===============================================================================================================
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
::===============================================================================================================
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
::===============================================================================================================
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
:================================================================================================================
::===============================================================================================================
:: REPORTS 1 - QUERY EVENTS FROM EVENT LOG
: Query_Events
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
:================================================================================================================
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
:================================================================================================================
::===============================================================================================================
:: CONTROL CENTER 7 - GOS TOOLS
: GOS_Tools_No_Job
	set Job=
	set "Jobs=No"
: GOS_Tools
	cls
	set "file=GOS Tools"
	call :top_box
	echo 	  บ  1.  Rkill                                (FFTU - MTU)         บ
	echo 	  บ  2.  Tdsskiller                           (FFTU)               บ
	echo 	  บ  3.  HitmanPro                            (FFTU)               บ
	echo 	  บ  4.  Malwarebytes AntiMalware             (FFTU - MTU)         บ
	echo 	  บ  5.  CCleaner                             (FFTU - MTU)         บ
	echo 	  บ  6.  Iobituninstaller                     (FFTU - MTU)         บ
	echo 	  บ  7.  Autoruns                             (FFTU)               บ
	echo 	  บ  8.  RogueKiller                                               บ
	echo 	  บ  9.  PatchMyPC                            (FFTU - MTU)         บ
	echo 	  บ  0.  Back                                                      บ
	call :bottom_box
	if "%option%"=="1"   goto  Rkill
	if "%option%"=="2"   goto  Tdsskiller
	if "%option%"=="3"   goto  HitmanPro
	if "%option%"=="4"   goto  MBAM
	if "%option%"=="5"   goto  CCleaner
	if "%option%"=="6"   goto  Iobit
	if "%option%"=="7"   goto  Autoruns
	if "%option%"=="8"   goto  RogueKiller
	if "%option%"=="9"   goto  PatchMyPC
	if "%option%"=="0"   goto  Control_Center
	call :bad_choice
	goto Control_Center
:================================================================================================================
::===============================================================================================================
: Rkill
	cls
	echo.
	if "%Jobs%"=="YES" mode con: cols=50 lines=3
	if "%Job%"=="FFTU" echo Next Job is TDSSKiller
	if "%Job%"=="MTU"  echo Next Job is Malwarebytes
	start c:\gos\rkill.exe
	if "%Jobs%"=="No" goto GOS_Tools
	timeout /T 10
	if "%Job%"=="MTU"  goto MBAM
: Tdsskiller
	cls
	echo.
	if "%Jobs%"=="YES" mode con: cols=50 lines=3
	if "%Job%"=="FFTU" echo Next Tool is HitmanPro
	if "%Job%"=="MTU"  echo Next Tool is Malwarebytes
	start /wait c:\gos\TDSSKiller -accepteula -accepteulaksn
	if "%Jobs%"=="No" goto GOS_Tools
	if "%Job%"=="MTU"  goto MBAM
: HitmanPro
	cls
	echo.
	if "%Jobs%"=="YES" mode con: cols=50 lines=3
	if "%Jobs%"=="YES" echo Next Tool is Malwarebytes
	start "" c:\gos\HitmanPro.exe /scan /noinstall
	if "%Jobs%"=="No" goto GOS_Tools
	echo Press Enter To Start Malwarebytes
	pause >nul
: MBAM
	cls
	echo.
	if "%Jobs%"=="YES" mode con: cols=50 lines=3
	if "%Jobs%"=="YES" echo Next Tool is CCleaner
	if "%OSA%"=="32-bit" set MBAM="%PROGRAMFILES%\Malwarebytes Anti-Malware\mbam.exe"
	if "%OSA%"=="64-bit" set MBAM="%PROGRAMFILES(X86)%\Malwarebytes Anti-Malware\mbam.exe"
	if exist %MBAM% goto Found_MBAM
	start /wait c:\gos\MBAM.exe /verysilent
: Check_For_MBAM
	echo.
	echo Waiting for file to populate
	if exist %MBAM% TIMEOUT /T 5 >nul
	if exist %MBAM% goto Found_MBAM
	TIMEOUT /T 5 >nul
	cls
	goto Check_For_MBAM
: Found_MBAM
	cls
	echo.
	if "%Jobs%"=="YES" echo Next Tool is CCleaner
	start "" %MBAM%
	if "%Jobs%"=="No" goto GOS_Tools
	echo Press Enter To Start CCleaner
	pause >nul  
: CCleaner
	cls
	echo.
	if "%Jobs%"=="YES" mode con: cols=50 lines=3
	if "%Jobs%"=="YES"  echo Next Tool is Iobit Uninstaller
	start c:\gos\CCleaner.exe
	if "%Jobs%"=="No" goto GOS_Tools
	echo Press Enter to start Iobit Uninstaller
	pause >nul
: Iobit
	cls
	echo.
	if "%Jobs%"=="YES" mode con: cols=50 lines=3
	if "%Job%"=="FFTU" echo Next Tool is Autoruns
	if "%Job%"=="MTU"  echo Next Tool is PatchMyPC
	start c:\gos\Iobituninstaller.exe
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
	start c:\gos\Autoruns.exe
	if "%Jobs%"=="No" goto GOS_Tools
	echo Press Enter to start PatchMyPC
	pause >nul
	if "%Jobs%"=="YES" goto PatchMyPC 
: RogueKiller
	cls
	echo.
	if "%Jobs%"=="YES" mode con: cols=50 lines=3
	if "%Jobs%"=="YES"  echo Next Tool is PatchMyPC
	start c:\gos\RogueKiller.exe
	if "%Jobs%"=="No" goto GOS_Tools
	echo Press Enter to start PatchMyPC
	pause >nul
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
	start c:\gos\PatchMyPC.exe
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
:: CONTROL CENTER 6 - AUTO TOOLS
: Auto_Tools
	Title  ------- AUTO MODE ------ 
	set "file=Auto Tools"
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
	goto GOS_Tools
: MTU
	set Job=
	set "Job=MTU"
	set "Jobs=YES"
	goto GOS_Tools
: Repairs
	set Job=
	set "Job=Repairs"
	goto Auto_Repair
:================================================================================================================
:: CONTROL CENTER 5 - CREATES SYSTEM RESTORE POINT
: System_Restore_Point
	if /i "%SAFE_MODE%"=="yes" echo Can not create restore point in safe mode & pause & goto Auto_Tools
	if /i "%W_V:~0,9%"=="Microsoft" goto XP_Vista_7_Restore_Point
	if /i "%W_V:~0,9%"=="Windows V" goto XP_Vista_7_Restore_Point
	if /i "%W_V:~0,9%"=="Windows 7" goto XP_Vista_7_Restore_Point
:: CREATE SYSTEM RESTORE POWERSHELL
	powershell "Checkpoint-Computer -Description 'GeeksOnSite' | Out-Null"
	goto Control_Center
: XP_Vista_7_Restore_Point
:: CREATE SYSTEM RESTORE POINT VBS
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
	echo Please wait until Confirmation of System Restore Point
	pause
	del /q /f GOSRestorePoint.vbs
	goto Control_Center
::===============================================================================================================
:: REPORTS 7 - QUERYS SYSTEM INFORMATION
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
	set Default_Printer=
:: Get Anti Virus
	for /F "tokens=2 delims='='" %%A in ('WMIC /Node:localhost /Namespace:\\root\SecurityCenter2 Path AntiVirusProduct Get displayName  /value') do set AV=%%A	
:: Get Computer Name
	for /F "tokens=2 delims='='" %%A in ('wmic OS Get csname /value') do set Computer_Name=%%A
:: Get Computer Manufacturer
	for /F "tokens=2 delims='='" %%A in ('wmic ComputerSystem Get Manufacturer /value') do set Manufacturer=%%A
:: Get Computer Model
	for /F "tokens=2 delims='='" %%A in ('wmic ComputerSystem Get Model /value') do set Model=%%A
:: Get Computer Serial Number
	for /F "tokens=2 delims='='" %%A in ('wmic Bios Get SerialNumber /value') do set Serial_Number=%%A
:: Get Computer OS
	for /F "tokens=2 delims='='" %%A in ('wmic os get Name /value') do set Operating_System=%%A
	for /F "tokens=1 delims='|'" %%A in ("%Operating_System%") do set Operating_System=%%A	
:: Get Computer OS Service Pack
	for /F "tokens=2 delims='='" %%A in ('wmic os get ServicePackMajorVersion /value') do set SP=%%A
:: Get Processor Info 
	for /F "tokens=2 delims='='" %%A in ('wmic CPU Get Name /value') do set Processor=%%A
:: Get Total Ram
	for /f "tokens=2* delims=:" %%A in ('systeminfo ^| findstr /I /C:"Total Physical Memory"') do set Physical_Memory=%%A
:: Get IE Home Page
	for /f "tokens=3*" %%A in ('REG QUERY "HKCU\Software\Microsoft\Internet Explorer\Main" /v "Start Page"') do set Start`Page=%%~B
:: Get Default Printer Info
	for /f "tokens=2* delims==" %%A in ('wmic printer where "default=True" get name /value') do set Default_Printer=%%A
:: Get Windows 10 Version
	for /f "tokens=2 delims=[]" %%x in ('ver') do set WINVER=%%x
	set WINVER=%WINVER:Version =%
:: Generate file
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
	echo -------------------------------------------- >> %file%
	%~dp0System_Info.txt %MAC%
	del System_Info.txt
	del Installed_Printers_List.txt
	del TechnicianTool.tmp
	cls
	goto Control_Center
:================================================================================================================
::===============================================================================================================
:: CONTROL CENTER 3 - REPAIR OPTION MENU
: Repair_OS
	set "file=Repair OS"
	call :top_box
	echo 	  บ  1. SFC Scan                                                   บ
	echo 	  บ  2. Check Disk                                                 บ
	echo 	  บ  3. Dism Options                                               บ
	echo 	  บ  4. System Update Readiness Tool - Website Link                บ
	echo 	  บ  5. Software Distribution                                      บ
	echo 	  บ  6. System Restore                                             บ
	echo 	  บ  7. Reset Windows Update Components                            บ
	echo 	  บ  8. Identify unsigned and digitally signed Drivers             บ
	echo 	  บ  9. Admin Account                 (Activate/Deactivate)        บ
	echo 	  บ  0. Cancel                                                     บ 
	call :bottom_box
	if "%option%"=="1"  goto SFC_Scan
	if "%option%"=="2"  goto Check_Disk   
	if "%option%"=="3"  goto Dism_Options
	if "%option%"=="4"  goto System_Update  
	if "%option%"=="5"  goto Software_Distribution
	if "%option%"=="6"  goto System_Restore
	if "%option%"=="7"  goto Rebuild_Updates
	if "%option%"=="8"  goto Signed_Drivers
	if "%option%"=="9"  goto Admin_Account
	if "%option%"=="0"  goto Control_Center
	call:Bad_Choice
	goto Repair_OS
:================================================================================================================
::===============================================================================================================
:: REPAIR OS 9 - ENABLE OR DISABLE HIDDEN ADMINSTRATOR ACCOUNTE
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
::===============================================================================================================
:: REPAIR OS 7 - FULL WINDOWS UPDATE REBUILD
: Rebuild_Updates
	net stop bits
	net stop wuauserv
	net stop appidsvc
	net stop cryptsvc
	timeout /t 2
	del /f /q "%ALLUSERSPROFILE%\Application Data\Microsoft\Network\Downloader\qmgr*.dat"
	del /f /s /q %SystemRoot%\SoftwareDistribution\*.*  
	del /f /s /q %SystemRoot%\system32\catroot2\*.* 
	del /f /q %SystemRoot%\WindowsUpdate.log  
	del %SYSTEMROOT%\winsxs\pending.xml 
	del %SYSTEMROOT%\WindowsUpdate.log
	sc.exe sdset bits D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)
	sc.exe sdset wuauserv D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)
	timeout /t 2
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
	netsh winsock reset 
	if /i "%W_V:~0,9%"=="Microsoft" proxycfg.exe -d
	if /i "%W_V:~0,7%"=="Windows" netsh winhttp reset proxy
	timeout /t 2
	net start bits
	net start wuauserv
	net start appidsvc
	net start cryptsvc
	timeout /t 2
	if /i "%W_V:~0,7%"=="Windows V" bitsadmin.exe /reset /allusers
	echo Process completed please reboot the PC now
	pause
	exit
:================================================================================================================
::===============================================================================================================
:: REPAIR OS 6 - OPENS SYSTEM RESTORE PROPERTIES GUI
: System_Restore
	if /i "%W_V:~0,9%"=="Microsoft" %SystemRoot%\system32\restore\rstrui.exe
	if /i "%W_V:~0,7%"=="Windows"   systempropertiesprotection
	goto Repair_OS
::===============================================================================================================
:: REPAIR OS 8 - INSTALLED DRIVER INTEGRITY CHECK
: Signed_Drivers
	cls
	start /wait sigverif.exe
	start /wait DxDiag.exe
	cls	
	goto Repair_OS
::===============================================================================================================
:: REPAIR OS 5 - DELET OR RENAME SOFTWARE DISTRIBUTION FOLDER
: Software_Distribution
	if /i "%W_V:~0,9%"=="Microsoft" goto VR5
	if /i "%W_V:~0,7%"=="Windows"   goto VR6
	goto warn
: VR5
	set /P "ANSWER=What would you like to do with the Software Distribution Folder? (R) Rename or (D) Delete ... "  
	echo You chose: %ANSWER% 
	if /i "%ANSWER%"=="R" goto XP_Rename_Software_Distribution 
	if /i "%ANSWER%"=="D" goto XP_Delete_Software_Distribution 
	call :bad_choice
	goto Repair_OS
: XP_Rename_Software_Distribution
	net stop “Automatic Updates”
	if exist %windir%\SoftwareDistribution\SD.old del /f /s /q %windir%\SoftwareDistribution\SD.old
	if exist %windir%\SoftwareDistribution ren %windir%\SoftwareDistribution SD.old
	net start “Automatic Updates”
	wuauclt.exe /detectnow
	goto Repair_OS
: XP_Delete_Software_Distribution
	net stop “Automatic Updates”
	if exist %windir%\SoftwareDistribution del /f /s /q %windir%\SoftwareDistribution\*.*
	net start “Automatic Updates”
	wuauclt.exe /detectnow
	goto Repair_OS
: VR6
	set /P "ANSWER=What would you like to do with the Software Distribution Folder? (R) Rename or (D) Delete ... "  
	echo You chose: %ANSWER% 
	if /i "%ANSWER%"=="R" goto Rename_Software_Distribution 
	if /i "%ANSWER%"=="D" goto Delete_Software_Distribution 
	call :bad_choice
	goto Repair_OS
: Rename_Software_Distribution
	net stop wuauserv
	if exist %windir%\SoftwareDistribution\SD.old del /f /s /q %windir%\SoftwareDistribution\SD.old
	if exist %windir%\SoftwareDistribution ren %windir%\SoftwareDistribution SD.old
	net start wuauserv
	wuauclt.exe /detectnow
	goto Repair_OS
: Delete_Software_Distribution
	net stop wuauserv
	if exist %windir%\SoftwareDistribution del /f /s /q %windir%\SoftwareDistribution\*.*
	net start wuauserv
	wuauclt.exe /detectnow
	goto Repair_OS
::===============================================================================================================
:: REPAIR OS 4 - LINK - SYSTEM UPDATE READINESS TOOL(Vista and 7 Only)
: System_Update
	Start http://support.microsoft.com/kb/947821/en-us
	cls
	goto Repair_OS
:================================================================================================================
::===============================================================================================================
:: REPAIR OS 3 - DEPLOYMENT IMAGE SERVICING AND MANAGEMENT OPTIONS
: Dism_Options
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
:================================================================================================================
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
	cls
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
	cls
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
	cls
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
	cls
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
	echo 	  บ                      with Windows UPdates                      บ
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
	cls
	goto Dism_Options
::===============================================================================================================
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
:: ASK OPEN CMD ADMIN (Asks if a Administrative Command Prompt should be opened after the Check Disk Scan.)
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
:================================================================================================================
::===============================================================================================================
:: CONTROL CENTER 2 - INTERNET REPAIR MENU
: Internet_Repair
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
:================================================================================================================
::===============================================================================================================
:: INTERNET REPAIR 9 - REGISTERS SOFTPUB.DLL
: Repair_HTTPS
	cls
	regsvr32 softpub.dll
	cls
	goto Internet_Repair
::===============================================================================================================
:: INTERNET REPAIR 8 - FLUSHES IP DNS, RESETS WINSOCK AND REBOOTS
: Flush_and_Reset
	ipconfig /flushdns
	netsh winsock reset
	shutdown /r
	exit
::===============================================================================================================
:: INTERNET REPAIR 7 - PERFORMS INFINITE PING TEST
: Ping_Test
	mode con: cols=100 lines=48
	start cmd /k ping www.google.com -t
	ipconfig /all
	echo.
	echo.
	pause
	cls
	goto Internet_Repair
:================================================================================================================
::===============================================================================================================
:: INTERNET REPAIR 6 - OPENS RESET BROWSER MENU
: Reset_Browser
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
:================================================================================================================
::===============================================================================================================
:: RESET BROWSER 5 - CLEAR MOZILLA FIREFOX CACHE
: Delete_Firefox_Cache
	erase "%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*.*" /f /s /q
	for /D %%i in ("%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*") do rd /S /Q "%%i"
	pause
	cls
	goto Internet_Repair
::===============================================================================================================
:: RESET BROWSER 4 - CLEAR GOOGLE CHROME CACHE
: Delete_Google_Cache
	erase "%LOCALAPPDATA%\Google\Chrome\User Data\*.*" /f /s /q
	for /D %%i in ("%LOCALAPPDATA%\Google\Chrome\User Data\*") do rd /S /Q "%%i"
	pause
	cls
	goto Internet_Repair
::===============================================================================================================
:: RESET BROWSER 3 - CLEAR INTERNET EXPLORER CACHE(Deletes Temporary Internet Files Only)
: Delete_IE_Cache
	RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 8
	erase "%LOCALAPPDATA%\Microsoft\Windows\Tempor~1\*.*" /f /s /q
	for /D %%i in ("%LOCALAPPDATA%\Microsoft\Windows\Tempor~1\*") do rd /S /Q "%%i"
	pause
	cls
	goto Internet_Repair
::===============================================================================================================
:: RESET BROWSER 2 - OPENS FIREFOX RESET OPTION
: Reset_Firefox
	Firefox -safe-mode 
	cls 
	goto Reset_Browser
::===============================================================================================================
:: RESET BROWSER 1 - DELETES GOOGLE CHROME USER DATA FOLDER
: Reset_Chrome
	rd /S /Q "%UserProfile%\AppData\Local\Google\Chrome\User Data"
	cls
	goto Reset_Browser
:================================================================================================================
::===============================================================================================================
:: INTERNET REPARIR 5 - OPENS UNINSTAL BROWSER MENU
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
:================================================================================================================
::===============================================================================================================
:: UNINSTALL BROWSER 5 - UNINSTALL INTERNET EXPLORER 7 (no reboot)
: IE_7
	%windir%\ie7\spuninst\spuninst.exe
	pause
	goto Uninstall_Browser
::===============================================================================================================
:: UNINSTALL BROWSER 4 - UNINSTALL INTERNET EXPLORER 8 (no reboot)
: IE_8
	%windir%\ie8\spuninst\spuninst.exe
	pause
	goto Uninstall_Browser
::===============================================================================================================
:: UNINSTALL BROWSER 3 - UNINSTALL INTERNET EXPLORER 9 (no reboot)
: IE_9
	if /i "%W_V:~0,9%"=="Microsoft" goto Unsupported
	FORFILES /P %WINDIR%\servicing\Packages /M Microsoft-Windows-InternetExplorer-*9.*.mum /c "cmd /c echo Uninstalling package @fname && start /w pkgmgr /up:@fname /norestart"
	pause
	goto Uninstall_Browser
::===============================================================================================================
:: UNINSTALL BROWSER 2 - UNINSTALL INTERNET EXPLORER 10 (no reboot)
: IE_10
	if /i "%W_V:~0,9%"=="Microsoft" goto Unsupported
	if /i "%W_V:~0,9%"=="Windows V" goto Unsupported
	FORFILES /P %WINDIR%\servicing\Packages /M Microsoft-Windows-InternetExplorer-*10.*.mum /c "cmd /c echo Uninstalling package @fname && start /w pkgmgr /up:@fname /quiet /norestart"
	pause
	goto Uninstall_Browser
::===============================================================================================================
:: UNINSTALL BROWSER 1 - UNINSTALL INTERNET EXPLORER 11 (no reboot)
: IE_11
	if /i "%W_V:~0,9%"=="Microsoft" goto Unsupported
	if /i "%W_V:~0,9%"=="Windows V" goto Unsupported
	FORFILES /P %WINDIR%\servicing\Packages /M Microsoft-Windows-InternetExplorer-*11.*.mum /c "cmd /c echo Uninstalling package @fname && start /w pkgmgr /up:@fname /quiet /norestart"
	pause
	goto Uninstall_Browser 
:================================================================================================================
::===============================================================================================================
:: INTERNET REPAIR 4 - UNCHECK PROXY CHECK BOX IN LOCAL AREA NETOWORK SETTINGS 
: Remove_Proxy
	REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f
	cls
	goto Internet_Repair
::===============================================================================================================
:================================================================================================================
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
:================================================================================================================
:: INTERNET REPAIR 2 - REPAIR FTP WHEN IT OPENS TO A WEB BROWSER 
: Repair_FTP
	echo Importing Registry Settings, Please Wait ....
	cls
:: Check Windows Version
	if /i "%W_V:~0,9%"=="Microsoft" goto XP_Fix_FTP
	if /i "%W_V:~0,7%"=="Windows"   goto Newer_Fix_FTP
	goto warn
: Newer_Fix_FTP
	echo Windows Registry Editor Version 5.00 > FTP_Fix.txt
	echo [HKEY_CLASSES_ROOT\ftp] >> FTP_Fix.txt
	echo @="URL:File Transfer Protocol" >> FTP_Fix.txt
	echo "AppUserModelID"="Microsoft.InternetExplorer.Default" >> FTP_Fix.txt
	echo "EditFlags"=dword:00000002 >> FTP_Fix.txt
	echo "FriendlyTypeName"="@C:\\Windows\\system32\\ieframe.dll,-905" >> FTP_Fix.txt
	echo "ShellFolder"="{63da6ec0-2e98-11cf-8d82-444553540000}" >> FTP_Fix.txt
	echo "Source Filter"="{E436EBB6-524F-11CE-9F53-0020AF0BA770}" >> FTP_Fix.txt
	echo "URL Protocol"="" >> FTP_Fix.txt
	echo [HKEY_CLASSES_ROOT\ftp\DefaultIcon] >> FTP_Fix.txt
	echo @=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\ >> FTP_Fix.txt
	echo   00,5c,00,73,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,75,00,72,00,\ >> FTP_Fix.txt
	echo   6c,00,2e,00,64,00,6c,00,6c,00,2c,00,30,00,00,00 >> FTP_Fix.txt
	echo [HKEY_CLASSES_ROOT\ftp\shell] >> FTP_Fix.txt
	echo @="open" >> FTP_Fix.txt
	echo [HKEY_CLASSES_ROOT\ftp\shell\open] >> FTP_Fix.txt
	goto FTP_Import
::===============================================================================================================
: XP_Fix_FTP
	echo Windows Registry Editor Version 5.00 FTP_Fix.txt
	echo [HKEY_CLASSES_ROOT\ftp] >> FTP_Fix.txt
	echo @="URL:File Transfer Protocol" >> FTP_Fix.txt
	echo "EditFlags"=dword:00000002 >> FTP_Fix.txt
	echo "ShellFolder"="{63da6ec0-2e98-11cf-8d82-444553540000}" >> FTP_Fix.txt
	echo "Source Filter"="{E436EBB6-524F-11CE-9F53-0020AF0BA770}" >> FTP_Fix.txt
	echo "FriendlyTypeName"="@C:\\WINDOWS\\system32\\ieframe.dll.mui,-905" >> FTP_Fix.txt
	echo "URL Protocol"="" >> FTP_Fix.txt
	echo [HKEY_CLASSES_ROOT\ftp\DefaultIcon] >> FTP_Fix.txt
	echo @=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\ >> FTP_Fix.txt
	echo 00,5c,00,73,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,75,00,72,00,\ >> FTP_Fix.txt
	echo 6c,00,2e,00,64,00,6c,00,6c,00,2c,00,30,00,00,00 >> FTP_Fix.txt
	echo [HKEY_CLASSES_ROOT\ftp\Extensions] >> FTP_Fix.txt
	echo ".IVF"="{C69E8F40-D5C8-11D0-A520-145405C10000}" >> FTP_Fix.txt
	echo [HKEY_CLASSES_ROOT\ftp\shell] >> FTP_Fix.txt
	echo @="open" >> FTP_Fix.txt
	echo [HKEY_CLASSES_ROOT\ftp\shell\open] >> FTP_Fix.txt
	echo [HKEY_CLASSES_ROOT\ftp\shell\open\command] >> FTP_Fix.txt
	echo @="\"C:\\Program Files\\Internet Explorer\\IEXPLORE.EXE\" %1" >> FTP_Fix.txt
	echo [HKEY_CLASSES_ROOT\ftp\shell\open\ddeexec] >> FTP_Fix.txt
	echo @="\"%1\",,-1,0,,,," >> FTP_Fix.txt
	echo "NoActivateHandler"="" >> FTP_Fix.txt
	echo [HKEY_CLASSES_ROOT\ftp\shell\open\ddeexec\Application] >> FTP_Fix.txt
	echo @="IExplore" >> FTP_Fix.txt
	echo [HKEY_CLASSES_ROOT\ftp\shell\open\ddeexec\ifExec] >> FTP_Fix.txt
	echo @="*" >> FTP_Fix.txt
	echo [HKEY_CLASSES_ROOT\ftp\shell\open\ddeexec\Topic] >> FTP_Fix.txt
	echo @="WWW_OpenURL" >> FTP_Fix.txt
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
:================================================================================================================
::===============================================================================================================
:: INTERNET REPAIR 1 - HOST FILE MENU
: Host
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
:: HOST REPAIR 3 - REPLACE HOST FILE
: Host_Replace
	pushd\windows\system32\drivers\etc
	attrib -h -s -r hosts
	echo 127.0.0.1 localhost>HOSTS
	attrib +r +h +s hosts
	popd
	ipconfig /release
	ipconfig /renew
	ipconfig /flushdns
	netsh winsock reset all
	netsh int ip reset all
	shutdown -r -t 1
::===============================================================================================================
:: HOST REPAIR 2 - RESET HOST FILE PERMISSIONS 
: Host_Permisions
	echo,Y|cacls "%WinDir%\system32\drivers\etc\hosts" /G everyone:f
	attrib -s -h -r "%WinDir%\system32\drivers\etc\hosts"
	echo The Permissions on the HOSTS file have been reset.
	pause
	cls
	goto Host
::===============================================================================================================
:: HOST REPAIR - 1 OPENS HOST FILE IN GUI
: Inspect_Host
	notepad C:\Windows\System32\drivers\etc\hosts
	cls
	goto Host
:================================================================================================================
::===============================================================================================================
:: CONTROL CENTER 1 - OPENS PRINTER REPAIR MENU
: Printer_Repair
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
:================================================================================================================
::===============================================================================================================
:: PRINTER REPAIR OPTION 3 - REPAIR PRINT SPOOLER ERROR 1068
: Repair_Spooler
	net stop spooler
	sc config spooler depend= RPCSS
	net start spooler
	pause
	cls
	goto Printer_Repair
::===============================================================================================================
:: PRINTER REPAIR OPTION  2 - REFRESH PRINT SPOOLER
: Clear_Printer
	net stop spooler
	del %systemroot%\System32\spool\printers\* /Q /F /S
	net start spooler
	pause
	cls
	goto Printer_Repair
::===============================================================================================================
:: PRINTER REPAIR OPTION  1 - OPENS PRINTER SPOOLER FOLDER IN GUI 
: Print_Spooler_Location
	start %windir%\System32\spool\PRINTERS
	cls
	goto Printer_Repair
::===============================================================================================================
:================================================================================================================
:: CALLS
: cancel
	cls
	goto Control_Center
::===============================================================================================================
: warn
	msg "%username%" Machine OS cannot be determined.
	pause
	cls
	goto Control_Center
::===============================================================================================================
: unsupported
	msg "%username%" This Option isn?t supported on this OS.
	pause
	cls
	goto Control_Center
::===============================================================================================================
: format_header
	echo.        ***************** >> %file%
	echo.         %Date% >> %file%
	echo.           %Time% >> %file%
	echo. >> %file%
	goto :eof
::===============================================================================================================
: format_footer
	echo. >> %file%
	echo. ***End Report*** >> %file%
	goto :eof
::===============================================================================================================
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
::===============================================================================================================
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
::===============================================================================================================
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
::===============================================================================================================
: bottom_box2	
	echo 	  บ                                                                บ
	echo 	  บ                                                                บ
	echo 	  ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
	echo.
	echo.
	echo.
	goto :eof
::===============================================================================================================
: bad_choice
	echo.
	echo "%choice%" is not valid...please try again
	pause
	cls
	goto :eof
::===============================================================================================================
: event_log_number
	set /P "evnum=Enter the number of events you would like in your report: " 
	set "file=Query Last %evnum% Events From Event Log"
	cls
	goto :eof
::===============================================================================================================
:: QUERYS HARD DRIVE SIZE AND FREE SPACE
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
::===============================================================================================================
:: QUERYS GOOGLE HOMEPAGE
: google_home
	set js="%temp%\extractChromeHomepage%random%.js"
:: List all Chrome persons
	(
		set /p .=settings=<nul
		type "%LocalAppData%\Google\Chrome\User Data\Local State"
		echo ;for^(var k in settings.profile.info_cache^) WScript.echo^(k^);
	)>%js%
:: Get the homepage for each Chrome person
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
::===============================================================================================================
:: QUERYS FIREFOX HOMEPAGE
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
:: DISPLAYS ABOUT INFO
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
	echo         					 Created :  11/02/2015
	echo        						 Version :  %SCRIPT_VERSION%
	echo.
	echo License key: %random% %random% %random% %random% %random% 
	echo.
	pause >nul
	goto :eof
:================================================================================================================
::===============================================================================================================
:: CONTROL CENTER 6 - CLEANS UP - FROM MTU AND FFTU  
: Clean_Exit
	cls
	if exist "%USERPROFILE%\Desktop\Rkill*.txt"     del /q /f "%USERPROFILE%\Desktop\Rkill*.txt"
	if exist "%USERPROFILE%\Desktop\rkill"          rd /s /Q "%USERPROFILE%\Desktop\rkill"
	if exist "%USERPROFILE%\Desktop\RKreport*.txt"  del /q /f "%USERPROFILE%\Desktop\RKreport*.txt" 
	if exist "%USERPROFILE%\Desktop\RK_Quarantine"  rd /Q "%USERPROFILE%\Desktop\RK_Quarantine" 
	if exist "%USERPROFILE%\Desktop\ComboFix.exe"   del /q /f "%USERPROFILE%\Desktop\ComboFix.exe" 
	if exist "C:\TDSSKiller*.txt"                   del /q /f "C:\TDSSKiller*.txt"
	if exist "C:\AdwCleaner"                        rd /S /Q "C:\AdwCleaner"
	if exist "%USERPROFILE%\Desktop\mbar"           move /y "%USERPROFILE%\Desktop\mbar" c:\gos >> %file%
	cls
	echo.
	echo.
	echo.
	echo.
	echo                ฑฑฒฒฒฒฒฒÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛฒฒฒฒฒฑฑ
	echo               ฐฑฑฒฒฒฒÛÛÛ                                         ÛÛÛฒฒฒฒฑฑฐ
	echo              ฐฐฑฑฒฒฒÛÛ                                             ÛÛฒฒฒฑฑฐฐ
	echo             ฐฐฑฑฒฒÛÛ             All Cleanup Performed              ÛÛฒฒฑฑฐฐ
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


