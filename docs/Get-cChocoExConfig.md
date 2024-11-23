# Get-cChocoExConfig

## SYNOPSIS
Returns Chocolatey Configuration DSC Configuration settings from cChocoEx.

## DESCRIPTION
The `Get-cChocoExConfig` function retrieves and returns Chocolatey configuration settings from the cChocoEx configuration file. It returns the configurations as PowerShell Custom Objects, allowing for easy filtering and manipulation of configuration data.

## SYNTAX

```powershell
Get-cChocoExConfig 
    [-cChocoExConfigFile <String[]>] 
    [-ConfigName <String>] 
    [-Ensure <String>] 
    [-Value <String>]
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

### -ConfigName
Filters results to show only configurations matching the specified name.

```powershell
Type: String
Parameter Sets: Present, Absent
Required: False
```

### -Ensure
Filters results to show only configurations with the specified state (Present or Absent).

```powershell
Type: String
Parameter Sets: Present, Absent
Valid values: "Present", "Absent"
Required: False
```

### -Value
Filters results to show only configurations with the specified value.

```powershell
Type: String
Parameter Sets: Present
Required: False
```

## EXAMPLES

### Example 1: Get all configurations
```powershell
Get-cChocoExConfig
```

Returns all Chocolatey configurations from the default configuration file.

### Example 2: Get a specific configuration
```powershell
Get-cChocoExConfig -ConfigName 'cacheLocation'
```

Returns the configuration settings for the 'cacheLocation' configuration.

### Example 3: Get configurations from a specific file
```powershell
Get-cChocoExConfig -cChocoExConfigFile 'C:\ProgramData\cChocoEx\config\custom-config.psd1'
```

Returns all configurations from a specified configuration file.

### Example 4: Get present configurations
```powershell
Get-cChocoExConfig -Ensure 'Present'
```

Returns all configurations that are set to 'Present'.

## OUTPUTS

### PSCustomObject
Returns objects with the following properties:
- ConfigName: The name of the configuration
- Value: The configuration value
- Ensure: The state of the configuration (Present/Absent)
- Path: The full path to the configuration file

## NOTES
- The function ignores MaintenanceWindow configurations
- Invalid configuration keys will generate an error
- If the configuration file doesn't exist, a warning is displayed

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx)
- [Update-cChocoExConfigFile](./Update-cChocoExConfigFile.md) 