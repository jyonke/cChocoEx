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
            id      = 42, 1074, 6005, 6006, 6008  # Removed 1 from here as we'll handle it separately
        }
        if ($Days) {
            $DaysInv = $Days * -1
            $StartTime = (Get-Date).AddDays($DaysInv)
            $FilterHashTable.StartTime = $StartTime
        }
        try {
            # Get the main events
            $WinEvents = Get-WinEvent -FilterHashtable $FilterHashTable -ErrorAction 'SilentlyContinue'
            
            # Get wake events separately with provider filter
            $WakeFilterHashTable = @{
                logname      = 'System'
                id           = 1
                ProviderName = 'Microsoft-Windows-Power-Troubleshooter'
            }
            if ($Days) {
                $WakeFilterHashTable.StartTime = $StartTime
            }
            
            $WakeEvents = Get-WinEvent -FilterHashtable $WakeFilterHashTable -ErrorAction 'SilentlyContinue'
            
            # Combine the events
            $WinEvents = @($WinEvents) + @($WakeEvents) | Where-Object { [datetime]$_.timecreated -lt (Get-Date) }
            $TextInfo = (Get-Culture).TextInfo    
        }
        catch {
            Write-Warning $_.Exception.Message        
        }
    }
    
    process {
        # Create a hashtable to track unique datetime stamps
        $uniqueEvents = @{}
        
        foreach ($Event in $WinEvents) {
            switch ($Event.Id) {
                1 {
                    # Only process Event ID 1 if it's from the Power Troubleshooter
                    if ($Event.ProviderName -eq 'Microsoft-Windows-Power-Troubleshooter') {
                        $Event.Message = 'Wake from Sleep'
                        # Only add the event if we haven't seen this timestamp before
                        $timeKey = $Event.TimeCreated.ToString()
                        if (-not $uniqueEvents.ContainsKey($timeKey)) {
                            $uniqueEvents[$timeKey] = $Event
                        }
                    }
                    continue  # Skip to next event if not from correct provider
                }
                42 {
                    $Event.Message = 'Sleep'
                }
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
            
            # Only add non-wake events if we haven't seen this timestamp before
            $timeKey = $Event.TimeCreated.ToString()
            if (-not $uniqueEvents.ContainsKey($timeKey)) {
                $uniqueEvents[$timeKey] = $Event
            }
        }
        
        # Replace $WinEvents with the deduplicated events
        $WinEvents = $uniqueEvents.Values
    }
    
    end {
        return $WinEvents
    }
}
