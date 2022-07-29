function Filter-PackageMaintenanceWindow {
    [CmdletBinding()]
    param (        
        [Parameter()]
        [array]
        $Configurations
    )
    
    [array]$Array = @()
    foreach ($Item in $Configurations) {
        if (($Item.OverrideMaintenanceWindow -ne $true) -and ($Global:OverrideMaintenanceWindow -ne $true)) {
            if (-not($Global:MaintenanceWindowEnabled -and $Global:MaintenanceWindowActive)) {
                Write-Verbose "Configuration restricted to Maintenance Window"
                Continue
            }
        }
        $Array += $Item
    }
    return  $Array
}