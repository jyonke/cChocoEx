# Get-ChocoLogs

## SYNOPSIS
Retrieves Chocolatey log entries from the specified log folder.

## DESCRIPTION
The `Get-ChocoLogs` function retrieves log entries from Chocolatey log files, allowing filtering by log type, log level, and date range. It can return a summary or full log entries based on the specified parameters.

## SYNTAX

```powershell
Get-ChocoLogs 
    [-LogType <String>] 
    [-Path <String>] 
    [-Last <Int32>] 
    [-LogLevel <Array>] 
    [-SearchString <Regex>] 
    [-MinimumDate <DateTime>] 
    [-MaximumDate <DateTime>] 
    [-All <Switch>]
```

## PARAMETERS

### -LogType
Specifies the type of logs to retrieve (Summary or Full).

```powershell
Type: String
Parameter Sets: (All)
Valid values: "Summary", "Full"
Required: False
Default value: 'Summary'
```

### -Path
Specifies the path to the Chocolatey log folder.

```powershell
Type: String
Parameter Sets: (All)
Required: False
Default value: (Join-Path $env:ChocolateyInstall 'logs')
```

### -Last
Limits the number of log entries returned to the specified number.

```powershell
Type: Int32
Parameter Sets: Filter
Required: False
```

### -LogLevel
Filters log entries by the specified log level (Information, Error, Warning, Debug).

```powershell
Type: Array
Parameter Sets: (All)
Valid values: "Information", "Error", "Warning", "Debug"
Required: False
```

### -SearchString
Filters log entries to include only those that match the specified search string.

```powershell
Type: Regex
Parameter Sets: (All)
Required: False
```

### -MinimumDate
Filters log entries to include only those from the specified minimum date.

```powershell
Type: DateTime
Parameter Sets: Filter
Required: False
Default value: (Get-Date).AddDays(-30)
```

### -MaximumDate
Filters log entries to include only those up to the specified maximum date.

```powershell
Type: DateTime
Parameter Sets: Filter
Required: False
Default value: (Get-Date)
```

### -All
Returns all log entries without filtering by date or count.

```powershell
Type: Switch
Parameter Sets: All
Required: False
```

## EXAMPLES

### Example 1: Get the last 3000 log entries
```powershell
Get-ChocoLogs -Last 3000
```

Returns the last 3000 log entries from the default log path.

### Example 2: Get full logs with a specific log level
```powershell
Get-ChocoLogs -LogType Full -LogLevel 'Error'
```

Returns all full log entries with the log level set to Error.

### Example 3: Search for a specific message in logs
```powershell
Get-ChocoLogs -SearchString 'installation failed'
```

Returns log entries that contain the phrase 'installation failed'.

## OUTPUTS

### PSCustomObject[]
Returns an array of log entries as PowerShell Custom Objects with the following properties:
- Date: The date and time of the log entry
- LogLevel: The severity level of the log entry
- Message: The log message

## NOTES
- The function handles log entries from both summary and full log files.
- If no logs are found, a warning is displayed.
- The function supports filtering by date range and log level.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx) 