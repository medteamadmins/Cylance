@ECHO OFF
title UNIFIED DRIVER CYLANCE CLEANUP TOOL
Echo UNIFIED DRIVER CYLANCE CLEANUP TOOL
:SwitchToWorkingDirectory
cd /d "%~dp0" 1>nul 2>&1
:AdminCheck
openfiles>nul 2>&1
IF %ERRORLEVEL% == 0 (
	:AdminCheckPass
	GOTO InstallCleanup
) ELSE (
	:AdminCheckFail
	Echo * Please re-run the Unified Driver Cylance Cleanup Tool as Administrator.
	Echo * Exiting...
	GOTO CyExit
)
:InstallCleanup
Echo * Installing the Unified Driver Cylance Cleanup Tool service...
CyCleanupSvc.exe "-install"
IF %ERRORLEVEL% == 0 (
	GOTO WaitCleanup
) ELSE (
	Echo * Failed to install the Unified Driver Cylance Cleanup Tool service.
	Echo * Please check the Logs directory.
	Echo * Exiting...
	GOTO CyExit
)
:WaitCleanup
Echo * Waiting for the Unified Driver Cylance Cleanup Tool service to cleanup...
ping -n 30 127.0.0.1 1>nul 2>&1
Echo * Unified Driver Cylance Cleanup Tool is finished.
Echo * Removing the Unified Driver Cylance Cleanup Tool service...
CyCleanupSvc.exe "-uninstall"
IF %ERRORLEVEL% == 0 (
	GOTO FinishCleanup
) ELSE (
	Echo * Failed to remove the Unified Driver Cylance Cleanup Tool service.
	Echo * Please check the Logs directory.
	Echo * Exiting...
	GOTO CyExit
)
:FinishCleanup
Echo * Unified Driver Cylance Cleanup Tool service has been removed.
Echo * Exiting...
:CyExit
exit