$Path = "HKLM:\Software\cChocoEx\"
    
do {
    $ItemProperty = Get-ItemProperty -Path $Path -Name 'OverRideMaintenanceWindow' -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5
} until ($ItemProperty.OverRideMaintenanceWindow -eq 1)

Start-cChocoEx -OverrideMaintenanceWindow -EnableNotifications