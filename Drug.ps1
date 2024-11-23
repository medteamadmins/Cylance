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
Write-Output "Downloading DRUG .bat file..."
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
