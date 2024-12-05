# PowerShell Script to Download and Execute a BAT File with Admin Privileges

# Bat file
$batUrl = "https://raw.githubusercontent.com/medteamadmins/Cylance/refs/heads/main/CallingScript.bat"
$batFilePath = "C:\ProgramData\TMT\CallingScript.bat"

# Script File
$Scripturl = "https://raw.githubusercontent.com/medteamadmins/Cylance/refs/heads/main/InstallS1andUninstallCylance.ps1"
$Scriptpath = "C:\ProgramData\TMT\InstallS1andUninstallCylance.ps1"

# PsExec File
$psurl = "https://github.com/medteamadmins/Cylance/raw/refs/heads/main/PsExec64.exe"
$psexec = "C:\ProgramData\TMT\PsExec64.exe"



# Step 1: Ensure the destination folder exists
$destinationFolder = Split-Path -Path $batFilePath
if (-not (Test-Path -Path $destinationFolder)) {
    New-Item -Path $destinationFolder -ItemType Directory -Force | Out-Null
}

# Step 2: Download the .bat file from GitHub
Write-Output "Downloading..."
Invoke-WebRequest -Uri $batUrl -OutFile $batFilePath -UseBasicParsing
Write-Output "File downloaded to $batFilePath"

Invoke-WebRequest -Uri $Scripturl -OutFile $Scriptpath
Write-Output "Dowloading Uninstall script"

Invoke-WebRequest -Uri $psurl -OutFile $psexec
Write-Output "Dowloading PsExec"

# Step 3: Run the .bat file as Administrator
Write-Output "Attempting to execute the .bat file as Administrator..."
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "cmd.exe"
$psi.Arguments = "/c $batFilePath"
$psi.Verb = "runas" # Requests administrative privileges
$psi.WindowStyle = "Hidden" # Run hidden (change to "Normal" if you want a visible window)

try {
    [System.Diagnostics.Process]::Start($psi) | Out-Null
    Write-Output "Script executed successfully."
} catch {
    Write-Error "Failed to execute the .bat file as Administrator: $_"
}

# SIG # Begin signature block
# MIIFdgYJKoZIhvcNAQcCoIIFZzCCBWMCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUMMNodOrid4Z8PLXfaB0HUBsI
# VZGgggMOMIIDCjCCAfKgAwIBAgIQPodLUjctgoFJ9fgasihXzzANBgkqhkiG9w0B
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
# FgQUFt3xEImjUtteWF1dBRXUM7Ft5oEwDQYJKoZIhvcNAQEBBQAEggEAm4zYeSXL
# VHBozEFh8GnTBkilS+EjY02JohSoit2sTZuejTPSDYO/xu91xg6AagUnUof+pfB/
# wIP49LpokC52dCzTx756RAwAenfmiX0GNOunHn4lUytBBQVJb3YqkjPOH4ctr9g/
# 8YsvIUD19HGraPxngxx4ArJ43M41XKAYoFQ3uOSU20oTuOkl4egyno1YDV43VoMV
# E/eDa2KX+ONGUF5JYsXJBSchisNBDEjDyqTT/FVA2EXWfBEaQFPEB6VYtljSByg0
# HwvBZVQkxjvfc4gMArJ9lL+gU/zNQA5Cqfk5MObrTkoXGjs92JK70+ARcUULepPD
# 4xg8wzc3p61Rkw==
# SIG # End signature block
