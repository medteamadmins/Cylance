# Stopping Cylance OPTICs Services
Net stop CyOptics
# Stop Cylance PROTECT Services
Net stop CylanceSVC

taskkill /im CylanceUI.exe /f

# Define S1 path
$SentialOneMSI = "C:\ProgramData\TMT\SentinelOne\S1.msi"
$S1url = "https://github.com/medteamadmins/Cylance/raw/refs/heads/main/S1.msi"


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
#Invoke-WebRequest -Uri $CylanceSvcUrl -OutFile $CylanceSvcReg
#Invoke-WebRequest -Uri $CylanceDrvUrl -OutFile $CylanceDrvReg
#Invoke-WebRequest -Uri $CyOpticsDrvUrl -OutFile $CyOpticsDrvReg
#Invoke-WebRequest -Uri $CyOpticsUrl -OutFile $CyOpticsReg

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
#Install Sentinel One Agent
if (!(test-path "HKLM:\SOFTWARE\Sentinel Labs\Agent"))
{
start-process msiexec.exe -Wait -ArgumentList '/i C:\ProgramData\TMT\SentinelOne\S1.msi /q SITE_TOKEN="eyJ1cmwiOiAiaHR0cHM6Ly91c2VhMS0wMDEtbXNzcC5zZW50aW5lbG9uZS5uZXQiLCAic2l0ZV9rZXkiOiAiZTcxZTZmYTJjMjNjOGUwOCJ9"'
}else{

Write-Host "SentinelOne Agent is already installed"
}

# Stopping Cylance OPTICs Services
Net stop CyOptics

# Stop Cylance PROTECT Services
Net stop CylanceSVC
taskkill /im CylanceUI.exe /f

#Update Reg
#Start-Process regedit.exe -ArgumentList "/s $CyOpticsReg" -Wait -NoNewWindow
#Start-Process regedit.exe -ArgumentList "/s $CyOpticsDrvReg" -Wait -NoNewWindow
#Start-Process regedit.exe -ArgumentList "/s $CylanceDrvReg" -Wait -NoNewWindow
#Start-Process regedit.exe -ArgumentList "/s $CylanceSvcReg" -Wait -NoNewWindow

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

$CylanceFile = "C:\Program Files\Cylance\Desktop\*"  # Ensure no hidden characters
if (Test-Path -LiteralPath $CylanceFile) {
        taskkill /im CylanceUI.exe /f
        Remove-Item -LiteralPath $CylanceFile -Recurse -Force
        Write-Output "."
    } 
 else {
    Write-Output "Folder does not exist."
}

$Cylance = "C:\Program Files\Cylance\"  # Ensure no hidden characters
if (Test-Path -LiteralPath $Cylance) {
        #taskkill /im CylanceUI.exe /f
        Remove-Item -LiteralPath $Cylance -Recurse -Force
        Write-Output "Folder deleted."
    } 
 else {
    Write-Output "Folder does not exist."
}

# SIG # Begin signature block
# MIIFdgYJKoZIhvcNAQcCoIIFZzCCBWMCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUjk7oi7usk/sf1Rfx1dN3Qf41
# uE+gggMOMIIDCjCCAfKgAwIBAgIQPodLUjctgoFJ9fgasihXzzANBgkqhkiG9w0B
# AQsFADAdMRswGQYDVQQDDBJUTVQgU2lnbmVkIHNjcmlwdHMwHhcNMjQwMzI1MDEy
# MTU4WhcNMzQwMzI1MDEzMTU4WjAdMRswGQYDVQQDDBJUTVQgU2lnbmVkIHNjcmlw
# dHMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCzUvkeQPjkJeTyc1ze
# xkeZE8l4l5Th6vfr3ra9iJkPYvogkeEX3f7mvF3nC31F2cLKxPqWUSS4GoLOBuJQ
# bX0cU26tykHfdrRSevAaIjfaILRu0VKpy/auN/xjCfVZAOGql41s2xumnnkFE7Ie
# HKUpdQytqC8RuoO6w7U1twmLb358Q0WTD0CXwn9iwNVUgGFrHihRLFWkJS6ffVc6
# XOT9cOl8GRJwk2iNxyoDm5umMb1PDok0B6hUvflAj59rM4Hg+eKahhtfSnM5Bsmq
# /HYFLjcmvZd4bPGg1KeFu9rQEbLD3tYI91kaWhtXoOOvt6YYMYtauxAYOQI8U2gZ
# VR3tAgMBAAGjRjBEMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcD
# AzAdBgNVHQ4EFgQUFcE/84qQWEvIwTn8ximRBJh3oAMwDQYJKoZIhvcNAQELBQAD
# ggEBAHlCTTMqu2KEVMq8B7sw0vVZnoT7EUkImUCpMebClZ0f+pSXgT/hlkncPwKF
# cMgFOPQb5eBh/YfKGPxllhRa3u8f6kNewRwiaEYh8XFLlIRXbna/LSuseEHMhVwR
# SlZOZVQ3LbX+P+BG5GlARQEDLiem4xjMWeWdOmLQ29LXLY/5HABc9yGVWxm6cMBx
# sjIo4T1rlHCST4NpgFGHmsjY6t6VIJTDcZm6hdVjN5/ym/jCSOFVXIELbUQAn1an
# tKD62pmo0aGkFfBEbZeH0tKYaKKoADa4mWfdeFvUyWBLZfv3i7EpKSi2AJ1AnQaz
# 3Cl4SEcMUkfSOmMDQoKQBNVavZQxggHSMIIBzgIBATAxMB0xGzAZBgNVBAMMElRN
# VCBTaWduZWQgc2NyaXB0cwIQPodLUjctgoFJ9fgasihXzzAJBgUrDgMCGgUAoHgw
# GAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGC
# NwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQx
# FgQUUfRM4kg5zkTPrCuqpByaQiiUBtwwDQYJKoZIhvcNAQEBBQAEggEAOkstDRxF
# E7dNstodtSkK/8oXYCM/8Gkn2iTNHvmdIT/rbkm/2Fx4MG57arPWNTU43zS1v0nh
# QiTSVWFD3Q5HMK6H5CLAoEkEUwnQTBvyo21Dj5xhZou4y58OVvAF4iGwz6TD5Y+y
# 75O82sTZIoGRys1OalPG82BPeV7fOLp3w3GHQG5MOfkLlba5SeebuRiJdkk+ohRc
# 2MEtx058LJ12djoyeEP0chgk97Ao5VwQqNGa45MPLpbRuPEW41hx8+9c66ux3dgQ
# IhKTb7M2uGsmxuCzLiu9e7PZKM4pPenHz62Et04uXH2Ey3Q4Tg13tjqw77da9+O0
# jlHcYVSTLCMNSg==
# SIG # End signature block
