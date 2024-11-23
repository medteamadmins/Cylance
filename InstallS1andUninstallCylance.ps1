# Stopping Cylance OPTICs Services
Net stop CyOptics
# Stop Cylance PROTECT Services
Net stop CylanceSVC

taskkill /im CylanceUI.exe /f

# Define S1 path
$SentialOneMSI = "C:\ProgramData\TMT\SentinelOne\S1.msi"
$S1url = "https://github.com/medteamadmins/Cylance/raw/refs/heads/main/S1.msi"
$SentinelOne = "HKLM:\SOFTWARE\SentinelOne"

#Create new folders
New-Item -ItemType Directory -Path "C:\ProgramData\TMT\CylanceCleanUpTool" -Force
New-Item -ItemType Directory -Path "C:\ProgramData\TMT\SentinelOne" -Force


# Cylance Cleanup bat file
$CleanupToolpath = "C:\Programdata\TMT\CylanceCleanUpTool\customized-CylanceCleanupTool.bat"
$CleanupToolurl = "https://raw.githubusercontent.com/medteamadmins/Cylance/refs/heads/main/customized-CylanceCleanupTool.bat"

# Cylance Clean up config file
$Cleanupconfig ="C:\ProgramData\TMT\CylanceCleanUpTool\CyCleanupSvc.exe.config"
$cleanupconfigurl ="https://raw.githubusercontent.com/medteamadmins/Cylance/refs/heads/main/CyCleanupSvc.exe.config"

# Cylance clean up service exe file
$cleanupexe ="C:\ProgramData\TMT\CylanceCleanUpTool\CyCleanupSvc.exe"
$cleanupexeurl ="https://github.com/medteamadmins/Cylance/raw/refs/heads/main/CyCleanupSvc.exe"

# CyOptics Reg
$CyOpticsReg = "C:\ProgramData\TMT\CylanceCleanUpTool\CyOptics.reg"
$CyOpticsUrl = "https://raw.githubusercontent.com/medteamadmins/Cylance/refs/heads/main/CyOptics.reg"

# CyOpticsDrv Reg
$CyOpticsDrvReg = "C:\ProgramData\TMT\CylanceCleanUpTool\CyOpticsDrv.reg"
$CyOpticsDrvUrl = "https://raw.githubusercontent.com/medteamadmins/Cylance/refs/heads/main/CyOpticsDrv.reg"

# CylanceDrv Reg
$CylanceDrvReg = "C:\ProgramData\TMT\CylanceCleanUpTool\CylanceDrv.reg"
$CylanceDrvUrl = "https://raw.githubusercontent.com/medteamadmins/Cylance/refs/heads/main/CylanceDrv.reg"

# CylanceSvc Reg
$CylanceSvcReg = "C:\ProgramData\TMT\CylanceCleanUpTool\CylanceSvc.reg"
$CylanceSvcUrl = "https://raw.githubusercontent.com/medteamadmins/Cylance/refs/heads/main/CylanceSvc.reg"


#Download Cleanup Tool
Invoke-WebRequest -Uri $CleanupToolurl -OutFile $CleanupToolpath
Invoke-WebRequest -Uri $cleanupconfigurl -OutFile $Cleanupconfig
Invoke-WebRequest -Uri $cleanupexeurl -OutFile $cleanupexe
#Download Reg
Invoke-WebRequest -Uri $CylanceSvcUrl -OutFile $CylanceSvcReg
Invoke-WebRequest -Uri $CylanceDrvUrl -OutFile $CylanceDrvReg
Invoke-WebRequest -Uri $CyOpticsDrvUrl -OutFile $CyOpticsDrvReg
Invoke-WebRequest -Uri $CyOpticsUrl -OutFile $CyOpticsReg

#Download S1
Invoke-WebRequest -Uri $S1url -OutFile $SentialOneMSI

# Define Cylance reg path
#$CylanceDesktop = "HKLM:\SOFTWARE\Cylance\Desktop"
$CylanceDrv = "HKLM:\SYSTEM\CurrentControlSet\Services\CylanceDrv"
#$CylanceDrvInstances1 = "HKLM:\SYSTEM\CurrentControlSet\Services\CylanceDrv\Instances"
#$CylanceDrvInstances2 = "HKLM:\SYSTEM\CurrentControlSet\Services\CylanceDrv\Instances\CylanceDrv Instance"
$CylanceSvc = "HKLM:\SYSTEM\CurrentControlSet\Services\CylanceSvc"
#$CylanceSvcSecurity = "HKLM:\SYSTEM\CurrentControlSet\Services\CylanceSvc\Security"
$CyOptics = "HKLM:\SYSTEM\CurrentControlSet\Services\CyOptics"
$CyOpticsDrv = "HKLM:\SYSTEM\CurrentControlSet\Services\CyOpticsDrv"


#Check if S1 is installed
If (-not $SentinelOne){

#Install SentinelOne
start-process msiexec.exe -Wait -ArgumentList '/i $SentialOneMSI /q SITE_TOKEN="eyJ1cmwiOiAiaHR0cHM6Ly91c2VhMS0wMDEtbXNzcC5zZW50aW5lbG9uZS5uZXQiLCAic2l0ZV9rZXkiOiAiZTcxZTZmYTJjMjNjOGUwOCJ9"'
}else{

Write-Host "SentinelOne Agent is already installed"
}

# Stopping Cylance OPTICs Services
Net stop CyOptics

# Stop Cylance PROTECT Services
Net stop CylanceSVC
taskkill /im CylanceUI.exe /f

#Update Reg
Start-Process regedit.exe -ArgumentList "/s $CyOpticsReg" -Wait -NoNewWindow
Start-Process regedit.exe -ArgumentList "/s $CyOpticsDrvReg" -Wait -NoNewWindow
Start-Process regedit.exe -ArgumentList "/s $CylanceDrvReg" -Wait -NoNewWindow
Start-Process regedit.exe -ArgumentList "/s $CylanceSvcReg" -Wait -NoNewWindow

#Uninstall Cylance OPTICS
$CylanceOptics = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -match "Cylance OPTICS"} | Select-Object -ExpandProperty IdentifyingNumber
Start-Process "C:\Windows\System32\msiexec.exe" -ArgumentList "/x $CylanceOptics /quiet /l*v C:\Programdata\TMT\CylanceCleanUpTool\uninstall_log.txt" -Wait

Start-Process -FilePath $CleanupToolpath -ArgumentList "/quiet"

#Uninstall Cylance Cylance
Start-Process "C:\Windows\System32\msiexec.exe" -ArgumentList "/x {2E64FC5C-9286-4A31-916B-0D8AE4B22954} /quiet /l*v C:\Programdata\TMT\CylanceCleanUpTool\uninstall_log.txt" -Wait

if (Test-Path $CylanceDrv) {
    Remove-Item -Path $CylanceDrv -Recurse -Force
} else {
    Write-Output "$CylanceDrv does not exist."
}

if (Test-Path $CylanceSvc) {
    
    Remove-Item -Path $CylanceSvc -Recurse -Force
} else {
    Write-Output "$CylanceSvc does not exist."
}

if (Test-Path $CyOptics) {
    
    Remove-Item -Path $CyOptics -Recurse -Force
} else {
    Write-Output "$CyOptics does not exist."
}

if (Test-Path $CyOpticsDrv) {
    
    Remove-Item -Path $CyOpticsDrv -Recurse -Force
} else {
    Write-Output "$CyOpticsDrv does not exist."
}

$CylanceDriver = "C:\Windows\System32\drivers\CylanceDrv64.sys"
$OpticsDriver = "C:\Windows\System32\drivers\CyOpticsDrv64.sys"

if (Test-Path $CylanceDriver) {
    
    Remove-Item -Path $CylanceDriver -Recurse -Force
} else {
    Write-Output "$CylanceDriver does not exist."
}

if (Test-Path $OpticsDriver) {
    
    Remove-Item -Path $OpticsDriver -Recurse -Force
} else {
    Write-Output "$OpticsDriver does not exist."
}


$Cylance = "C:\Program Files\Cylance\"  # Ensure no hidden characters
if (Test-Path -LiteralPath $Cylance) {
        taskkill /im CylanceUI.exe /f
        Remove-Item -LiteralPath $Cylance -Recurse -Force
        Write-Output "Folder deleted."
    } 
 else {
    Write-Output "Folder does not exist."
}
