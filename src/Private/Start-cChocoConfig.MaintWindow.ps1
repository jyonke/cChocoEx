function Start-cChocoConfig.MaintWindow {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $ConfigImportFile
    )

    if (Test-Path $ConfigImportFile ) {
        $ConfigImport = $null
        $ConfigImport = Import-PowerShellDataFile $ConfigImportFile
    }
    else {
        return
    }

    $MaintenanceWindowConfig = $ConfigImport | ForEach-Object { $_.Values  | Where-Object { $_.ConfigName -eq 'MaintenanceWindow' -or $_.Name -eq 'MaintenanceWindow' } }

    #cChocoConfig-MaintenanceWindowConfig
    Write-Log -Severity 'Information' -Message "cChocoConfig-MaintenanceWindowConfig:Validating Chocolatey Maintenance Window is Setup"
    [bool]$MaintenanceWindowEnabled_Now = $Global:MaintenanceWindowEnabled
    [bool]$MaintenanceWindowActive_Now = $Global:MaintenanceWindowActive
    [bool]$Override = $null

    #Restrictions
    if (Test-TSEnv) {
        $Message = "Task Sequence Environment Detected, Overriding Maintenance Window Settings"
        $Override = $True
    }
    if (Test-IsWinPe) {
        $Message = "WinPE Environment Detected, Overriding Maintenance Window Settings"
        $Override = $True
    }
    if (Test-IsWinOs.OOBE) {
        $Message = "WinOS OOBE Environment Detected, Overriding Maintenance Window Settings"
        $Override = $True
    }
    if (Test-IsWinSE) {
        $Message = "WinSE OOBE Environment Detected, Overriding Maintenance Window Settings"
        $Override = $True
    }

    #Process Maintenance Window if defined and Override is False 
    if ($MaintenanceWindowConfig -and (-Not($Override))) {
        $MaintenanceWindowTest = Get-MaintenanceWindow -StartTime $MaintenanceWindowConfig.Start -EndTime $MaintenanceWindowConfig.End -EffectiveDateTime $MaintenanceWindowConfig.EffectiveDateTime -UTC $MaintenanceWindowConfig.UTC
        $Global:MaintenanceWindowEnabled = $MaintenanceWindowTest.MaintenanceWindowEnabled
        $Global:MaintenanceWindowActive = $MaintenanceWindowTest.MaintenanceWindowActive

        #Write Log if Maintenance Window Has Changed
        if (($Global:MaintenanceWindowEnabled -ne $MaintenanceWindowEnabled_Now) -or ($Global:MaintenanceWindowActive -ne $MaintenanceWindowActive_Now)) {
            Write-Host '--cChocoConfig-MaintenanceWindowConfig--' -ForegroundColor DarkCyan
            Write-Log -Severity 'Information' -Message "cChocoConfig-MaintenanceWindowConfig"
            Write-Log -Severity 'Information' -Message "ConfigName: $($MaintenanceWindowConfig.ConfigName)"
            Write-Log -Severity 'Information' -Message "EffectiveDateTime: $($MaintenanceWindowConfig.EffectiveDateTime)"
            Write-Log -Severity 'Information' -Message "Start: $($MaintenanceWindowConfig.Start)"
            Write-Log -Severity 'Information' -Message "End: $($MaintenanceWindowConfig.End)"
            Write-Log -Severity 'Information' -Message "UTC: $($MaintenanceWindowConfig.UTC)"
            Write-Log -Severity 'Information' -Message "MaintenanceWindowEnabled: $($MaintenanceWindowEnabled)"
            Write-Log -Severity 'Information' -Message "MaintenanceWindowActive: $($MaintenanceWindowActive)"
            Write-Host '--cChocoConfig-MaintenanceWindowConfig--' -ForegroundColor DarkCyan
    
            #Write to Event Log
            if ($Global:MaintenanceWindowEnabled) {
                Write-EventLog -LogName 'Application' -Source 'cChocoEx' -EventId 4010 -EntryType Information -Message 'MaintenanceWindowEnabled: True'
            }
            else {
                Write-EventLog -LogName 'Application' -Source 'cChocoEx' -EventId 4011 -EntryType Information -Message 'MaintenanceWindowEnabled: False'
            }
        
            if ($Global:MaintenanceWindowActive) {
                Write-EventLog -LogName 'Application' -Source 'cChocoEx' -EventId 4012 -EntryType Information -Message 'MaintenanceWindowActive: True'
            }
            else {
                Write-EventLog -LogName 'Application' -Source 'cChocoEx' -EventId 4013 -EntryType Information -Message 'MaintenanceWindowActive: False'
            }      
        }
        
    }
    else {
        if ($Override) {
            Write-Log -Severity 'Information' -Message $Message
            Write-Log -Severity 'Information' -Message "MaintenanceWindowEnabled: $($MaintenanceWindowEnabled)"
            Write-Log -Severity 'Information' -Message "MaintenanceWindowActive: $($MaintenanceWindowActive)"
            return
        }
        Write-Log -Severity 'Warning' -Message "No Defined Maintenance Window"
    }
}
