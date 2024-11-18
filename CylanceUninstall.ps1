Net stop CyOptics
Start-Sleep -Seconds 1
Start-Process "C:\Windows\System32\msiexec.exe" -ArgumentList "/x {6FECE3E5-CA63-4A30-A29D-3600F2057F41} /quiet /l*v C:\Uninstall_Optics.txt" -Wait
Start-Sleep -Seconds 2
Net stop CylanceSVC
Start-Sleep -Seconds 1
taskkill /im CylanceUI.exe /f
Start-Sleep -Seconds 1
Start-Process "C:\Windows\System32\msiexec.exe" -ArgumentList "/x {2E64FC5C-9286-4A31-916B-0D8AE4B22954} /quiet /l*v C:\uninstall_Protect.txt" -Wait
