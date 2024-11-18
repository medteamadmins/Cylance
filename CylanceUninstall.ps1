Net stop CyOptics
$CylanceOptics = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -match "Cylance OPTICS"} | Select-Object -ExpandProperty IdentifyingNumber
Start-Process "C:\Windows\System32\msiexec.exe" -ArgumentList "/x {6FECE3E5-CA63-4A30-A29D-3600F2057F41} /quiet /l*v C:\uninstall_log.txt" -Wait
Net stop CylanceSVC
taskkill /im CylanceUI.exe /f
Start-Process "C:\Windows\System32\msiexec.exe" -ArgumentList "/x {2E64FC5C-9286-4A31-916B-0D8AE4B22954} /quiet /l*v C:\uninstall_log.txt" -Wait