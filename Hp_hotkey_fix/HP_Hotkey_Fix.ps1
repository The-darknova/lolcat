# --- Admin Check ---
# Checks if the script is running as Administrator. If not, it warns the user and exits.
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "ADMIN PRIVILEGES REQUIRED: Please right-click this script and select 'Run with PowerShell' -> Administrator."
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Exit
}

# --- Menu Display ---
Clear-Host
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "    HP Hotkey Support Blank Pop-up Fix Manager     " -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1: DISABLE Service (Workaround)" -ForegroundColor Yellow
Write-Host "   - Stops the blank pop-up immediately."
Write-Host "   - Might disable the on-screen volume bar visuals."
Write-Host ""
Write-Host "2: INSTALL Driver Fix (Solution)" -ForegroundColor Green
Write-Host "   - Downloads and installs the correct driver (sp91903)."
Write-Host "   - Attempts to fix the issue while keeping functionality."
Write-Host ""
Write-Host "0: Quit"
Write-Host ""

$choice = Read-Host "Please select an option (1, 2, or 0)"

# --- Logic Flow ---
Switch ($choice) {
    "1" {
        # === OPTION 1: DISABLE SERVICE ===
        Write-Host "`n[Option 1 Selected] Disabling Services..." -ForegroundColor Yellow
        $targetServices = @("HP Hotkey UWP Service", "HP Audio Analytics Service")

        foreach ($displayName in $targetServices) {
            $service = Get-Service | Where-Object { $_.DisplayName -eq $displayName }
            if ($service) {
                if ($service.Status -eq 'Running') {
                    Write-Host "Stopping $displayName..."
                    Stop-Service -InputObject $service -Force
                }
                Write-Host "Disabling startup for $displayName..."
                Set-Service -InputObject $service -StartupType Disabled
                Write-Host "Success: $displayName disabled." -ForegroundColor Green
            } else {
                Write-Host "Service '$displayName' not found. Skipping." -ForegroundColor DarkGray
            }
        }
        Write-Host "`nDone! The services have been disabled." -ForegroundColor Cyan
    }

    "2" {
        # === OPTION 2: DOWNLOAD & INSTALL ===
        Write-Host "`n[Option 2 Selected] Initializing Download..." -ForegroundColor Green
        
        $driverUrl = "https://ftp.hp.com/pub/softpaq/sp91501-92000/sp91903.exe"
        $downloadDir = "$env:USERPROFILE\AppData\Local\Temp"
        $fileName = "sp91903.exe"
        $outputPath = Join-Path -Path $downloadDir -ChildPath $fileName

        Write-Host "Downloading from HP Servers ($driverUrl)..." -ForegroundColor Cyan
        try {
            Invoke-WebRequest -Uri $driverUrl -OutFile $outputPath -UseBasicParsing
            Write-Host "Download complete: $outputPath" -ForegroundColor Green
            
            Write-Host "Launching Installer... Please follow the on-screen prompts." -ForegroundColor Yellow
            Start-Process -FilePath $outputPath -Wait
            Write-Host "Installation process finished." -ForegroundColor Cyan
        }
        catch {
            Write-Error "An error occurred during download or installation. Check your internet connection."
        }
    }

    "0" {
        Write-Host "Exiting..."
        Exit
    }

    Default {
        Write-Host "Invalid selection. Please run the script again." -ForegroundColor Red
    }
}

# --- Footer ---
Write-Host "`n------------------------------------------------"
Write-Host "Operation Complete. Press any key to close this window."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
