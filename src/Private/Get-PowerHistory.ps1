function Get-PowerHistory {
    [CmdletBinding()]
    param (
        # Max Event
        [Parameter()]
        [int]
        $MaxEvents = 25
    )
    
    begin {
        #Gather Event Log Data
        $WinEvents = Get-WinEvent -FilterHashtable @{logname = 'System'; id = 1074, 6005, 6006, 6008, 6013 } -MaxEvents $MaxEvents
        $TextInfo = (Get-Culture).TextInfo

    }
    
    process {
        foreach ($Event in $WinEvents) {
            switch ($Event.Id) {
                1074 {
                    [PSCustomObject]@{
                        TimeStamp    = $Event.TimeCreated
                        UserName     = $Event.Properties.value[6]
                        ShutdownType = $TextInfo.ToTitleCase($Event.Properties.value[4])
                    }
                }
                6005 {
                    [PSCustomObject]@{
                        TimeStamp    = $Event.TimeCreated
                        UserName     = $null
                        ShutdownType = 'Power On'
                    }
                }
                6006 {
                    [PSCustomObject]@{
                        TimeStamp    = $Event.TimeCreated
                        UserName     = $null
                        ShutdownType = 'Power Off'
                    }
                }
                6008 {
                    [PSCustomObject]@{
                        TimeStamp    = $Event.TimeCreated
                        UserName     = $null
                        ShutdownType = 'Unexpected Shutdown'
                    }
                }
                6013 {}
                Default {}
            }
        }
    }
    
    end {
        
    }
}