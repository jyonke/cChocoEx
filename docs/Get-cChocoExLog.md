# Get-cChocoExLog

## SYNOPSIS
Retrieves cChocoEx log entries from log files.

## DESCRIPTION
The `Get-cChocoExLog` function retrieves Chocolatey DSC log entries from cChocoEx log files and returns them as PowerShell Custom Objects. It supports filtering by date and limiting the number of entries returned, making it useful for auditing and troubleshooting.

## SYNTAX

```powershell
Get-cChocoExLog [-Path <String>] [-Last <Int32>] [-Date <DateTime>]
```

## PARAMETERS

### -Path
Specifies the path to the cChocoEx log files. If not specified, the function uses the default log path defined in the global variable.

```powershell
Type: String
Parameter Sets: (All)
Required: False
```

### -Last
Limits the number of log entries returned to the specified number.

```powershell
Type: Int32
Parameter Sets: (All)
Required: False
```

### -Date
Filters log entries to return only those from the specified date.

```powershell
Type: DateTime
Parameter Sets: (All)
Required: False
```

## EXAMPLES

### Example 1: Get the last 10 log entries
```powershell
Get-cChocoExLog -Last 10
```

Returns the last 10 log entries from the default log path.

### Example 2: Get log entries from yesterday
```powershell
Get-cChocoExLog -Date (Get-Date).AddDays(-1)
```

Returns all log entries from yesterday.

### Example 3: Get log entries from a specific path
```powershell
Get-cChocoExLog -Path 'C:\ProgramData\cChocoEx\logs'
```

Returns all log entries from the specified log path.

### Example 4: Get the last 5 log entries from a specific date
```powershell
Get-cChocoExLog -Date (Get-Date).AddDays(-7) -Last 5
```

Returns the last 5 log entries from 7 days ago.

## OUTPUTS

### PSCustomObject[]
Returns an array of log entries as PowerShell Custom Objects.

## NOTES
- The function imports log entries from CSV-formatted log files.
- If no log files are found at the specified path, an error is raised.
- If both `-Date` and `-Last` parameters are specified, the function first filters by date and then limits the number of entries returned.
- The default log path is defined in the global variable `$Global:LogPath`.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx)
- [Get-cChocoExHistory](./Get-cChocoExHistory.md)
- [Get-cChocoExConfig](./Get-cChocoExConfig.md) 