function Get-cChocoExHistory {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]
        $Days
    )

    $FilterHashTable = @{
        LogName      = 'Application' 
        ProviderName = 'cChocoEx'
    }

    if ($Days) {
        $DaysInv = $Days * -1
        $StartTime = (Get-Date).AddDays($DaysInv)
        $FilterHashTable.StartTime = $StartTime
        $PowerHistory = Get-PowerHistory -Days $Days
    }
    else {
        $PowerHistory = Get-PowerHistory
    }

    # Attempt to get cChocoEx event logs, suppressing errors
    try {
        $cChocoEventlogs = Get-WinEvent -FilterHashtable $FilterHashTable -ErrorAction SilentlyContinue
    }
    catch {
        $cChocoEventlogs = @()
        Write-Warning "No cChocoEx event logs found. Continuing with PowerHistory only."
    }

    # Combine and sort events, handling the case where $cChocoEventlogs might be empty
    $EventLogRecord = @($cChocoEventlogs) + @($PowerHistory) | 
    Where-Object { $_ -ne $null } |
    Sort-Object TimeCreated | 
    Select-Object TimeCreated, Id, LevelDisplayName, Message

    return $EventLogRecord
}
