<#
.SYNOPSIS
Returns Chocolatey DSC Logs in cChocoEx
.DESCRIPTION
Returns Chocolatey DSC Logs in cChocoEx as a PowerShell Custom Object. Optional parameters for limiting return by count and dates.
#>
function Get-cChocoExLog {
    [CmdletBinding()]
    param (
        # Path to cChocoEx Log File
        [Parameter()]
        [string]
        $Path,
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
        if (-Not($Path)) {
            $Path = $Global:LogPath
        }
        $cChocoExLogFiles = Get-ChildItem -Path $Path -Filter 'cChoco*.log' -ErrorAction SilentlyContinue

        if (-not($cChocoExLogFiles)) {
            Write-Error "No Log Files Found at $Path" -ErrorAction Stop
        }

        if ($Date) {
            $DateFilter = (Get-Date $Date).Date
            $cChocoExLogs = $cChocoExLogFiles | ForEach-Object { Import-Csv -Path $_.FullName | Where-Object { ( Get-Date $_.'Time').Date -eq $DateFilter } }
        }
        else {
            $cChocoExLogs = $cChocoExLogFiles | ForEach-Object { Import-Csv -Path $_.FullName }
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