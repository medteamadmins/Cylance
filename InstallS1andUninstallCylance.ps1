
# Define S1 path
$SentialOneMSI = "C:\ProgramData\TMT\SentinelOne\S1.msi"
$S1url = "https://github.com/medteamadmins/Cylance/blob/main/S1.msi"
$SentinelOne = "HKLM:\SOFTWARE\SentinelOne"

# Cylance Cleanup Tool
$CleanupToolpath = "C:\Programdata\TMT\CylanceCleanUpTool\customized-CylanceCleanupTool.bat"
$CleanupToolurl = "https://raw.githubusercontent.com/medteamadmins/Cylance/refs/heads/main/customized-CylanceCleanupTool.bat"

#Download Cleanup Tool
New-Item -ItemType Directory -Path "C:\ProgramData\TMT\CylanceCleanUpTool" -Force
Invoke-WebRequest -Uri $CleanupToolurl -OutFile $CleanupToolpath

#Download S1
New-Item -ItemType Directory -Path "C:\ProgramData\TMT\SentinelOne" -Force
Invoke-WebRequest -Uri $S1url -OutFile $SentialOneMSI

# Define Cylance reg path
$CylanceDesktop = "HKLM:\SOFTWARE\Cylance\Desktop"
$CylanceDrv = "HKLM:\SYSTEM\CurrentControlSet\Services\CylanceDrv"
$CylanceDrvInstances1 = "HKLM:\SYSTEM\CurrentControlSet\Services\CylanceDrv\Instances"
$CylanceDrvInstances2 = "HKLM:\SYSTEM\CurrentControlSet\Services\CylanceDrv\Instances\Instances\CylanceDrv Instance"
$CylanceSvc = "HKLM:\SYSTEM\CurrentControlSet\Services\CylanceSvc\"
$CylanceSvcSecurity = "HKLM:\SYSTEM\CurrentControlSet\Services\CylanceSvc\Security"
$CyOptics = "HKLM:\SYSTEM\CurrentControlSet\Services\CyOptics\Security"
$CyOpticsDrv = "HKLM:\SYSTEM\CurrentControlSet\Services\CyOpticsDrv\*"


#Check if S1 is installed
If (-not $SentinelOne){

#Install SentinelOne
start-process msiexec.exe -Wait -ArgumentList '/i $SentialOneMSI /q SITE_TOKEN="eyJ1cmwiOiAiaHR0cHM6Ly91c2VhMS0wMDEtbXNzcC5zZW50aW5lbG9uZS5uZXQiLCAic2l0ZV9rZXkiOiAiZTcxZTZmYTJjMjNjOGUwOCJ9"'
}else{

Write-Host "SentinelOne Agent is already installed"
}

# Stopping Cylance OPTICs Services
Net stop CyOptics

#Uninstall Cylance OPTICS
$CylanceOptics = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -match "Cylance OPTICS"} | Select-Object -ExpandProperty IdentifyingNumber
Start-Process "C:\Windows\System32\msiexec.exe" -ArgumentList "/x $CylanceOptics /quiet /l*v C:\Programdata\TMT\CylanceCleanUpTool\uninstall_log.txt" -Wait

# Stop Cylance PROTECT Services
Net stop CylanceSVC
taskkill /im CylanceUI.exe /f

Start-Process -FilePath $CleanupToolpath -ArgumentList "/quiet"

Start-Process "C:\Windows\System32\msiexec.exe" -ArgumentList "/x {2E64FC5C-9286-4A31-916B-0D8AE4B22954} /quiet /l*v C:\Programdata\TMT\CylanceCleanUpTool\uninstall_log.txt" -Wait


# Array of registry paths
$registryPaths = @($CylanceDesktop, $CylanceDrv, $CylanceDrvInstances1, $CylanceDrvInstances2, $CylanceSvcSecurity, $CylanceSvc, $CyOptics, $CyOpticsDrv)

# Function to change owner, set permissions, and delete registry keys
function Set-RegistryPermissionsAndDelete {
    param (
        [string]$path
    )

    # Change owner to Administrators
    $acl = Get-Acl -Path $path
    $acl.SetOwner([System.Security.Principal.NTAccount]"Administrators")
    Set-Acl -Path $path -AclObject $acl

    # Grant Administrators full control
    $rule = New-Object System.Security.AccessControl.RegistryAccessRule ("Administrators","FullControl","Allow")
    $acl.SetAccessRule($rule)
    Set-Acl -Path $path -AclObject $acl

}


# Iterate over each registry path and apply the changes
foreach ($path in $registryPaths) {
    try {
        Set-RegistryPermissionsAndDelete -path $path
        # Remove the registry key
        Remove-Item -Path $path -Recurse -Force
        Write-Output "Permissions updated and key deleted"
    } catch {
        Write-Error "Failed to update permissions or delete key"
    }
}

# Remove the Cylance Drv64
$CylanceDrv64 = "C:\Windows\Systems32\drivers\CylanceDrv64.sys"

# Change owner to Administrators
$acl2 = Get-Acl -Path $CylanceDrv64
$acl2.SetOwner([System.Security.Principal.NTAccount]"Administrators")
Set-Acl -Path $CylanceDrv64 -AclObject $acl2

# Grant Administrators full control
$rule2 = New-Object System.Security.AccessControl.RegistryAccessRule ("Administrators","FullControl","Allow")
$acl2.SetAccessRule($rule2)
Set-Acl -Path $CylanceDrv64 -AclObject $acl2
# Remove
Remove-Item -Path $CylanceDrv64 -Recurse -Force

#Delete cache Cylance PROTECT
$CylanceWOW6432 = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

foreach ($path in $CylanceWOW6432) {
    $key = Get-ItemProperty -Path $path\* | Where-Object { $_.DisplayName -eq "Cylance PROTECT" }
    if ($key) {
        $registryPath = $key.PSPath
        Write-Output "Found Cylance PROTECT at: $registryPath"
        
        # Remove the registry key
        Remove-Item -Path $registryPath -Recurse -Force
        Write-Output "Cylance PROTECT has been removed from the registry."
    } else {
        Write-Output "Cylance PROTECT not found in $path"
    }
}