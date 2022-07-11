function Get-PowerHistory {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]
        $Days
    )
    
    begin {
        #Gather Event Log Data
        $FilterHashTable = @{
            logname = 'System'
            id      = 1074, 6005, 6006, 6008
        }
        if ($Days) {
            $DaysInv = $Days * -1
            $StartTime = (Get-Date).AddDays($DaysInv)
            $FilterHashTable.StartTime = $StartTime
    
        }
        $WinEvents = Get-WinEvent -FilterHashtable $FilterHashTable
        $TextInfo = (Get-Culture).TextInfo

    }
    
    process {
        foreach ($Event in $WinEvents) {
            switch ($Event.Id) {
                1074 {
                    $Event.Message = $TextInfo.ToTitleCase($Event.Properties.value[4])
                }
                6005 {
                    $Event.Message = 'Power On'
                }
                6006 {
                    $Event.Message = 'Power Off'
                }
                6008 {
                    $Event.Message = 'Unexpected Shutdown'
                }
                Default {}
            }
        }
    }
    
    end {
        return $WinEvents
    }
}