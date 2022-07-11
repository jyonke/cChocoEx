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
    $cChocoEventlogs = Get-WinEvent -FilterHashtable $FilterHashTable
    $EventLogRecord = $cChocoEventlogs + $PowerHistory | Sort-Object TimeCreated | Select-Object TimeCreated, Id, LevelDisplayName, Message

    return $EventLogRecord
}
