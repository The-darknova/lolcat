# Check for Administrator privileges
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator to ensure the driver installs correctly."
    Exit
}

# --- Configuration ---
# This is the specific version (sp91903) known to fix the blank pop-up issue on most HP laptops
$driverUrl = "https://ftp.hp.com/pub/softpaq/sp91501-92000/sp91903.exe"
$downloadDir = "$env:USERPROFILE\AppData\Local\Temp"
$fileName = "sp91903.exe"
$outputPath = Join-Path -Path $downloadDir -ChildPath $fileName

# --- Step 1: Download the Driver ---
Write-Host "Downloading HP Hotkey Support Fix (sp91903)..." -ForegroundColor Cyan
try {
    # Download the file using Invoke-WebRequest
    Invoke-WebRequest -Uri $driverUrl -OutFile $outputPath -UseBasicParsing
    Write-Host "Download complete: $outputPath" -ForegroundColor Green
}
catch {
    Write-Error "Failed to download the file. Please check your internet connection."
    Exit
}

# --- Step 2: Install the Driver ---
Write-Host "Launching Installer..." -ForegroundColor Yellow
Write-Host "Please follow the on-screen instructions to complete the installation." -ForegroundColor Gray

try {
    # Start the installer process and wait for it to exit
    $installer = Start-Process -FilePath $outputPath -PassThru -Wait
    
    if ($installer.ExitCode -eq 0) {
        Write-Host "Installation process finished successfully." -ForegroundColor Green
    } else {
        Write-Host "Installer finished with exit code: $($installer.ExitCode)" -ForegroundColor Yellow
    }
}
catch {
    Write-Error "Failed to launch the installer."
}

Write-Host "------------------------------------------------"
Write-Host "Note: You may need to restart your computer after the installation completes." -ForegroundColor Cyan