$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

if($null -eq (Get-Item -Path "c:\buildArtifacts" -ErrorAction SilentlyContinue)){
    New-Item -Path "c:\buildArtifacts" -ItemType Directory -Force
}

Set-Location "c:\buildArtifacts"


#region FSLogix

Write-Host "Installing FSLogix"
$WVDFSLogixUrl = "https://aka.ms/fslogix_download"
$logFileLocation = "c:\buildArtifacts\FSLogixInstallation.log"
$FSLogixInstallerZip = "c:\buildArtifacts\FSLogix_Apps.zip"

("Check if FSLogix is already running...") | Out-File $logFileLocation -Append
if ($null -ne (Get-Process "frxsvc" -ErrorAction SilentlyContinue)) {
    ("FSLogix is already running! No need for installation") | Out-File $logFileLocation -Append
    return
}
("FSLogix is not running. Installing...") | Out-File $logFileLocation -Append
("FSLogix full download URL = '{0}'" -f $WVDFSLogixUrl) | Out-File $logFileLocation -Append
("FSLogix download location = '{0}'" -f $FSLogixInstallerZip) | Out-File $logFileLocation -Append

("Starting download...") | Out-File $logFileLocation -Append
Invoke-WebRequest -Uri $WVDFSLogixUrl -OutFile $FSLogixInstallerZip -UseBasicParsing
("Download finished.") | Out-File $logFileLocation -Append

("Starting extraction...") | Out-File $logFileLocation -Append
Expand-Archive -Path $FSLogixInstallerZip -DestinationPath "c:\buildArtifacts\"
("Extraction finished.") | Out-File $logFileLocation -Append

$FSLogixInstaller = "c:\buildArtifacts\x64\Release\FSLogixAppsSetup.exe"

("Starting installer...") | Out-File $logFileLocation -Append
$fsLogix_install_status = Start-Process -FilePath $FSLogixInstaller -ArgumentList @('/install', '/quiet', '/norestart') -Wait -Passthru
("Installer finished with returncode '{0}'" -f $fsLogix_install_status.ExitCode) | Out-File $logFileLocation -Append

Write-Host "FSLogix done!"
#endregion

#region WVD Optimizer
Write-Host "Running Optimizer"
$WVDOptimizerURL = "<<WvdOptimizerUrlFromBuild>>"
$logFileLocation = "c:\buildArtifacts\WVDOptimizer.log"
$WvdOptimizerZip = "c:\buildArtifacts\WVDOptimizer.zip"

("Starting download...") | Out-File $logFileLocation -Append
Invoke-WebRequest -Uri $WVDOptimizerURL -OutFile $WvdOptimizerZip -UseBasicParsing
("Download finished.") | Out-File $logFileLocation -Append

("Starting extraction...") | Out-File $logFileLocation -Append
Expand-Archive -Path $WvdOptimizerZip -DestinationPath "c:\buildArtifacts\"
("Extraction finished.") | Out-File $logFileLocation -Append

Set-Location "c:\buildArtifacts\WVDOptimizer"
("Starting WVDOptimizer...") | Out-File $logFileLocation -Append
.\OptimizeMe.ps1
("WVDOptimizer finished.") | Out-File $logFileLocation -Append
#endregion

Set-Location "c:\buildArtifacts"

Write-Host "All done!"

#Write-Host "Rebooting..."
#Restart-Computer -Force