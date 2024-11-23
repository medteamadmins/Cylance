@echo
cd "C:\ProgramData\TMT"
psexec64 -accepteula -h -s sc config cylancesvc start= disabled
psexec64 -accepteula -h -s sc config cyoptics start= disabled
psexec64 powershell.exe -ExecutionPolicy Bypass -File "C:\ProgramData\TMT\InstallS1andUninstallCylance.ps1" /accepteula
