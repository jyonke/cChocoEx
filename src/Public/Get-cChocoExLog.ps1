<#
.SYNOPSIS
Returns Chocolatey DSC Logs in cChocoEx
.DESCRIPTION
Returns Chocolatey DSC Logs in cChocoEx as a PowerShell Custom Object. Optional parameters for limiting return by count and dates.
#>
function Get-cChocoExLog {
    [CmdletBinding()]
    param (
        #Limit Number of items to return
        [Parameter()]
        [int]
        $Last,
        # Limit Return Values to a specif day
        [Parameter()]
        [datetime]
        $Date
    )
    
    try {
        $cChocoExDataFolder = (Join-Path -Path $env:ProgramData -ChildPath 'cChocoEx')
        $LogPath = (Join-Path -Path $cChocoExDataFolder -ChildPath "logs")
        $cChocoExLogFiles = Get-ChildItem -Path $LogPath -Filter 'cChoco*.log' -ErrorAction SilentlyContinue

        if (-not($cChocoExLogFiles)) {
            Write-Error "No Log Files Found at $LogPath" -ErrorAction Stop
        }

        if ($Date) {
            $DateFilter = (Get-Date $Date).Date
            $cChocoExLogs = $cChocoExLogFiles | Import-Csv | Where-Object { ( Get-Date $_.'Time').Date -eq $DateFilter }
        }
        else {
            $cChocoExLogs = $cChocoExLogFiles | Import-Csv
        }
        if ($Last) {
            $cChocoExLogs = $cChocoExLogs | Select-Object -Last $Last
        }    
        Return $cChocoExLogs
    }
    catch {
        $_.Exception.Message
    }
}