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
            id      = 1074, 6005, 6006, 6008, 42
        }
        if ($Days) {
            $DaysInv = $Days * -1
            $StartTime = (Get-Date).AddDays($DaysInv)
            $FilterHashTable.StartTime = $StartTime
    
        }
        try {
            $WinEvents = Get-WinEvent -FilterHashtable $FilterHashTable -ErrorAction 'SilentlyContinue' | Where-Object { [datetime]$_.timecreated -lt (Get-Date) }
            $TextInfo = (Get-Culture).TextInfo    
        }
        catch {
            Write-Warning $_.Exception.Message        
        }
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
                42 {
                    $Event.Message = 'Sleep'
                }
                Default {}
            }
        }
    }
    
    end {
        return $WinEvents
    }
}