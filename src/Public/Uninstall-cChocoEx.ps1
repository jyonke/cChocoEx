<#
.SYNOPSIS
Uninstalls the cChocoEx PowerShell Module

.DESCRIPTION
Uninstalls the cChocoEx PowerShell Module
#>

function Uninstall-cChocoEx {
    [CmdletBinding()]
    Param (
        # Wipes cChocoEx Data Folder
        [Parameter()]
        [switch]
        $Wipe
    )

    #Ensure Running as Administrator
    if ((Test-IsAdmin) -eq $false) {
        Write-Warning "This function requires elevated access, please reopen PowerShell as an Administrator"
        Break
    }
      
    #Uninstall All Modules
    try {
        Write-Warning "Uninstall-Module -Name cChocoEx -AllVersions -Force"
        Uninstall-Module -Name cChocoEx -AllVersions -Force
    }
    catch {
        Write-Warning $_.Exception.Message
    }

    #Unregister Scheduled Tasks/Jobs
    try {
        $ScheduledTask = Get-ScheduledTask -TaskName 'cChocoExBootstrapTask' -ErrorAction SilentlyContinue
        if ($ScheduledTask) {
            Write-Warning "Unregister-ScheduledTask -TaskName 'cChocoExBootstrapTask' -TaskPath '\cChocoEx\' -Confirm:`$false"
            Unregister-ScheduledTask -TaskName 'cChocoExBootstrapTask' -TaskPath '\cChocoEx\' -Confirm:$false
        }
    }
    catch {
        Write-Warning $_.Exception.Message
    }

    try {
        $ScheduledTask = Get-ScheduledTask -TaskName 'cChocoExTask01' -ErrorAction SilentlyContinue
        if ($ScheduledTask) {
            Write-Warning "Unregister-ScheduledTask -TaskName 'cChocoExTask01' -TaskPath '\cChocoEx\' -Confirm:`$false"
            Unregister-ScheduledTask -TaskName 'cChocoExTask01' -TaskPath '\cChocoEx\' -Confirm:$false
        }
    }
    catch {
        Write-Warning $_.Exception.Message
    }
    
    #Wipe Data
    if ($Wipe) {
        try {
            Remove-Item -Path $Global:cChocoExDataFolder -Recurse -Force
        }
        catch {}
    }
}