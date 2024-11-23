# Get-cChocoExMaintenanceWindow

## SYNOPSIS
Returns Maintenance Window DSC Configuration settings from cChocoEx.

## DESCRIPTION
The `Get-cChocoExMaintenanceWindow` function retrieves and returns the Maintenance Window configuration from the cChocoEx configuration file as PowerShell Custom Objects. This function allows filtering based on various parameters, making it useful for managing maintenance windows in a Chocolatey environment.

## SYNTAX

```powershell
Get-cChocoExMaintenanceWindow 
    [-cChocoExConfigFile <String[]>] 
    [-EffectiveDateTime <String>] 
    [-Start <String>] 
    [-End <String>] 
    [-UTC <Nullable[Boolean>]]
```

## PARAMETERS

### -cChocoExConfigFile
Specifies the path to the cChocoEx configuration file. If not specified, defaults to 'config.psd1' in the cChocoEx configuration folder.

```powershell
Type: String[]
Parameter Sets: (All)
Aliases: FullName, Path
Required: False
Default value: $Global:cChocoExConfigurationFolder\config.psd1
```

### -EffectiveDateTime
Filters results to return only configurations with the specified effective date and time.

```powershell
Type: String
Parameter Sets: (All)
Required: False
```

### -Start
Filters results to return only configurations with the specified start time.

```powershell
Type: String
Parameter Sets: (All)
Required: False
```

### -End
Filters results to return only configurations with the specified end time.

```powershell
Type: String
Parameter Sets: (All)
Required: False
```

### -UTC
Filters results to return only configurations with the specified UTC setting (true or false).

```powershell
Type: Nullable[Boolean]
Parameter Sets: (All)
Required: False
```

## EXAMPLES

### Example 1: Get all maintenance windows
```powershell
Get-cChocoExMaintenanceWindow
```

Returns all maintenance window configurations from the default configuration file.

### Example 2: Get maintenance windows with a specific start time
```powershell
Get-cChocoExMaintenanceWindow -Start '22:00'
```

Returns all maintenance windows that start at 22:00.

### Example 3: Get maintenance windows for a specific effective date
```powershell
Get-cChocoExMaintenanceWindow -EffectiveDateTime '11-24-2023 14:30'
```

Returns all maintenance windows that are effective on the specified date and time.

### Example 4: Get maintenance windows in UTC
```powershell
Get-cChocoExMaintenanceWindow -UTC $true
```

Returns all maintenance windows that are set to UTC.

### Example 5: Get maintenance windows with a specific end time
```powershell
Get-cChocoExMaintenanceWindow -End '06:00'
```

Returns all maintenance windows that end at 06:00.

## OUTPUTS

### PSCustomObject[]
Returns an array of maintenance window configurations as PowerShell Custom Objects with the following properties:
- PSTypeName: Set to 'cChocoExMaintenanceWindow'
- ConfigName: The name of the maintenance window configuration
- UTC: Indicates if the time is in UTC
- EffectiveDateTime: The effective date and time of the configuration
- Start: The start time of the maintenance window
- End: The end time of the maintenance window
- CurrentDate: The current date and time
- CurrentDateUTC: The current date and time in UTC
- CurrentTZ: The current time zone
- Path: The full path to the configuration file

## NOTES
- The function validates the existence of the configuration file and raises a warning if not found.
- If no filters are applied, all maintenance window configurations are returned.
- The function uses the `Get-Date` cmdlet to handle date and time formatting.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx)
- [Get-cChocoExConfig](./Get-cChocoExConfig.md) 