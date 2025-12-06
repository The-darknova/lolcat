# Check if the script is running with Administrator privileges
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator to make changes to Services."
    Exit
}

# List of services known to cause the blank pop-up issue
$targetServices = @("HP Hotkey UWP Service", "HP Audio Analytics Service")

foreach ($displayName in $targetServices) {
    # Attempt to find the service by its Display Name
    $service = Get-Service | Where-Object { $_.DisplayName -eq $displayName }

    if ($service) {
        Write-Host "Found service: $displayName" -ForegroundColor Cyan
        
        # Stop the service if it is running
        if ($service.Status -eq 'Running') {
            Write-Host "Stopping $displayName..."
            Stop-Service -InputObject $service -Force
        }

        # Disable the service startup type
        Write-Host "Disabling startup for $displayName..."
        Set-Service -InputObject $service -StartupType Disabled
        
        Write-Host "Success: $displayName has been disabled." -ForegroundColor Green
        Write-Host "------------------------------------------------"
    } else {
        Write-Host "Service '$displayName' not found on this system. Skipping." -ForegroundColor Gray
    }
}

Write-Host "Done! The HP Hotkey Support blank pop-up should be resolved." -ForegroundColor Yellow