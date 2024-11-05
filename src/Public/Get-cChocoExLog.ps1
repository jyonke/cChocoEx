<#
.SYNOPSIS
    Retrieves cChocoEx log entries.

.DESCRIPTION
    Returns Chocolatey DSC Logs from cChocoEx as PowerShell Custom Objects.
    Supports filtering by date and limiting the number of entries returned.

.PARAMETER Path
    The path to the cChocoEx log files. If not specified, uses the default log path.

.PARAMETER Last
    Limits the number of log entries returned.

.PARAMETER Date
    Filters log entries to a specific date.

.EXAMPLE
    Get-cChocoExLog -Last 10
    Returns the last 10 log entries.

.EXAMPLE
    Get-cChocoExLog -Date (Get-Date).AddDays(-1)
    Returns all log entries from yesterday.

.OUTPUTS
    [PSCustomObject[]] Array of log entries

.NOTES
    Author: Jon Yonke
    Version: 1.0
    Created: 2024-11-02
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