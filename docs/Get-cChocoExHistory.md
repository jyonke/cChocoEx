# Get-cChocoExHistory

## SYNOPSIS
Retrieves the combined history of cChocoEx events and system power events.

## DESCRIPTION
The `Get-cChocoExHistory` function retrieves and combines event logs from both cChocoEx operations and system power events. It allows filtering by date range and returns a sorted list of events. This function is useful for troubleshooting, auditing, and monitoring cChocoEx operations alongside system power state changes.

## SYNTAX

```powershell
Get-cChocoExHistory [-Days <Int32>]
```

## PARAMETERS

### -Days
Specifies the number of days of history to retrieve. If not specified, returns all available history.

```powershell
Type: Int32
Parameter Sets: (All)
Required: False
Default value: None
```

## EXAMPLES

### Example 1: Get all history
```powershell
Get-cChocoExHistory
```

Returns all available cChocoEx and power events.

### Example 2: Get recent history
```powershell
Get-cChocoExHistory -Days 7
```

Returns events from the last 7 days.

### Example 3: Get today's events
```powershell
Get-cChocoExHistory -Days 1 | Format-Table TimeCreated, Id, LevelDisplayName, Message -AutoSize
```

Returns today's events formatted as a table.

### Example 4: Export history to CSV
```powershell
Get-cChocoExHistory -Days 30 | Export-Csv -Path "cChocoEx_History.csv" -NoTypeInformation
```

Exports the last 30 days of events to a CSV file.

## OUTPUTS

### Selected.System.Diagnostics.Eventing.Reader.EventLogRecord
Returns objects with the following properties:
- TimeCreated: Timestamp of the event
- Id: Event ID
- LevelDisplayName: Severity level of the event
- Message: Detailed event message

## NOTES
- Requires appropriate permissions to read the Application event log
- cChocoEx events are sourced from the Application log with provider name 'cChocoEx'
- Power events are retrieved using the internal Get-PowerHistory function
- If no cChocoEx events are found, the function continues with power history only
- Events are sorted chronologically regardless of their source

## EXAMPLES WITH OUTPUT

### Example Output: Recent Events
```powershell
Get-cChocoExHistory -Days 1

TimeCreated         Id  LevelDisplayName  Message
-----------         --  ----------------  -------
2024-01-24 08:00:15 1   Information      cChocoEx: Starting package installation
2024-01-24 08:15:22 105 Information      System resumed from sleep
2024-01-24 09:30:45 2   Information      cChocoEx: Package installation completed
2024-01-24 10:45:30 107 Information      System entering sleep state
```

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx)
- [Start-cChocoEx](./Start-cChocoEx.md)
- [Get-PowerHistory](./Get-PowerHistory.md) 