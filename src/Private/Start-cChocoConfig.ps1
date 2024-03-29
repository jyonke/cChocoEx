function Start-cChocoConfig {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]
        $ConfigImport
    )

    Write-Log -Severity 'Information' -Message "cChocoConfig:Validating Chocolatey Configurations are Setup"
    $ModulePath = (Join-Path $ModuleBase "cChocoConfig")
    Import-Module $ModulePath
    $Configurations = $ConfigImport | ForEach-Object { $_.Values | Where-Object { $_.ConfigName -ne 'MaintenanceWindow' -and $_.Name -ne 'MaintenanceWindow' } } 
    $MaintenanceWindowConfig = $ConfigImport | ForEach-Object { $_.Values  | Where-Object { $_.ConfigName -eq 'MaintenanceWindow' -or $_.Name -eq 'MaintenanceWindow' } }
    $Status = @()
    
    $Configurations | ForEach-Object {
        $DSC = $null
        $Configuration = $_
        $Object = [PSCustomObject]@{
            ConfigName = $Configuration.ConfigName
            DSC        = $null
            Ensure     = $Configuration.Ensure
            Value      = $Configuration.Value
        }
        
        $DSC = Test-TargetResource @Configuration
        if (-not($DSC)) {
            $null = Set-TargetResource @Configuration
            $DSC = Test-TargetResource @Configuration
        }
        
        $Object.DSC = $DSC
        $Status += $Object
    }
    #Remove Module for Write-Host limitations
    Remove-Module "cChocoConfig"

    Write-Log -Severity 'Information' -Message 'Starting cChocoConfig'
    $Status | ForEach-Object {
        Write-Host '--------------cChocoConfig--------------' -ForegroundColor DarkCyan
        Write-Log -Severity 'Information' -Message "ConfigName: $($_.ConfigName)"
        Write-Log -Severity 'Information' -Message "DSC: $($_.DSC)"
        Write-Log -Severity 'Information' -Message "Ensure: $($_.Ensure)"
        Write-Log -Severity 'Information' -Message "Value: $($_.Value)"               
    }
    Write-Host '--------------cChocoConfig--------------' -ForegroundColor DarkCyan

    #cChocoConfig-MaintenanceWindowConfig
    Write-Log -Severity 'Information' -Message "cChocoConfig-MaintenanceWindowConfig:Validating Chocolatey Maintenance Window is Setup"

    $Global:MaintenanceWindowEnabled = $True
    $Global:MaintenanceWindowActive = $True

    #Restrictions
    if (Test-TSEnv) {
        Write-Log -Severity 'Information' -Message "Task Sequence Environment Detected, Overriding Maintenance Window Settings"
        Write-Log -Severity 'Information' -Message "MaintenanceWindowEnabled: $($MaintenanceWindowEnabled)"
        Write-Log -Severity 'Information' -Message "MaintenanceWindowActive: $($MaintenanceWindowActive)"
        return
    }
    #if (Test-AutopilotESP) {
    #    Write-Log -Severity 'Information' -Message "Autopilot Enrollment Status Page Environment Detected, Overriding Maintenance Window Settings"
    #    Write-Log -Severity 'Information' -Message "MaintenanceWindowEnabled: $($MaintenanceWindowEnabled)"
    #    Write-Log -Severity 'Information' -Message "MaintenanceWindowActive: $($MaintenanceWindowActive)"
    #    return
    #}
    if (Test-IsWinPe) {
        Write-Log -Severity 'Information' -Message "WinPE Environment Detected, Overriding Maintenance Window Settings"
        Write-Log -Severity 'Information' -Message "MaintenanceWindowEnabled: $($MaintenanceWindowEnabled)"
        Write-Log -Severity 'Information' -Message "MaintenanceWindowActive: $($MaintenanceWindowActive)"
        return
    }
    if (Test-IsWinOs.OOBE) {
        Write-Log -Severity 'Information' -Message "WinOS OOBE Environment Detected, Overriding Maintenance Window Settings"
        Write-Log -Severity 'Information' -Message "MaintenanceWindowEnabled: $($MaintenanceWindowEnabled)"
        Write-Log -Severity 'Information' -Message "MaintenanceWindowActive: $($MaintenanceWindowActive)"
        return
    }
    if (Test-IsWinSE) {
        Write-Log -Severity 'Information' -Message "WinSE OOBE Environment Detected, Overriding Maintenance Window Settings"
        Write-Log -Severity 'Information' -Message "MaintenanceWindowEnabled: $($MaintenanceWindowEnabled)"
        Write-Log -Severity 'Information' -Message "MaintenanceWindowActive: $($MaintenanceWindowActive)"
        return
    }

    if ($MaintenanceWindowConfig) {
        $MaintenanceWindowTest = Get-MaintenanceWindow -StartTime $MaintenanceWindowConfig.Start -EndTime $MaintenanceWindowConfig.End -EffectiveDateTime $MaintenanceWindowConfig.EffectiveDateTime -UTC $MaintenanceWindowConfig.UTC
        $Global:MaintenanceWindowEnabled = $MaintenanceWindowTest.MaintenanceWindowEnabled
        $Global:MaintenanceWindowActive = $MaintenanceWindowTest.MaintenanceWindowActive
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
    else {
        Write-Log -Severity 'Warning' -Message "No Defined Maintenance Window"
    }
}