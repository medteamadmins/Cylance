@echo
cd "C:\ProgramData\TMT"
psexec -accepteula -h -s sc config cylancesvc start= disabled
psexec -accepteula -h -s sc config cyoptics start= disabled
psexec -s powershell.exe -ExecutionPolicy Bypass -File "C:\ProgramData\TMT\InstallS1andUninstallCylance.ps1" /accepteula
