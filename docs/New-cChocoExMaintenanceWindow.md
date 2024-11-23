# New-cChocoExMaintenanceWindow

## SYNOPSIS
Creates a new cChocoEx Maintenance Window configuration.

## DESCRIPTION
The `New-cChocoExMaintenanceWindow` function creates a new Maintenance Window configuration for cChocoEx. It can either use specified times or automatically generate a window based on the OS Active Hours. It can also update an existing configuration with confirmation or force.

## SYNTAX

```powershell
New-cChocoExMaintenanceWindow 
    [-Path <String>] 
    [-Start <String>] 
    [-End <String>] 
    [-UTC <Boolean>] 
    [-UseActiveHours <Switch>] 
    [-Force <Switch>]
```

## PARAMETERS

### -Path
Specifies the path to the cChocoEx configuration file.

```powershell
Type: String
Parameter Sets: (All)
Required: True
```

### -Start
Specifies the start time of the maintenance window. If not specified, it will be calculated based on OS Active Hours.

```powershell
Type: String
Parameter Sets: (All)
Required: False
```

### -End
Specifies the end time of the maintenance window. If not specified, it will be calculated based on OS Active Hours.

```powershell
Type: String
Parameter Sets: (All)
Required: False
```

### -UTC
Specifies whether the times are in UTC. Default is `$false`.

```powershell
Type: Boolean
Parameter Sets: (All)
Required: False
```

### -UseActiveHours
Switch to use OS Active Hours to determine the maintenance window.

```powershell
Type: Switch
Parameter Sets: (All)
Required: False
```

### -Force
Switch to force update an existing configuration without prompting.

```powershell
Type: Switch
Parameter Sets: (All)
Required: False
```

## EXAMPLES

### Example 1: Create a maintenance window using active hours
```powershell
New-cChocoExMaintenanceWindow -Path 'C:\ProgramData\cChocoEx\config\config.psd1' -UseActiveHours
```

Creates a maintenance window configuration using the OS Active Hours.

### Example 2: Create a maintenance window with specified times
```powershell
New-cChocoExMaintenanceWindow -Path 'C:\ProgramData\cChocoEx\config\config.psd1' -Start '22:00' -End '06:00' -Force
```

Creates a maintenance window configuration with specified start and end times.

## OUTPUTS

### PowerShell Data File
Creates or updates a PowerShell Data File containing the maintenance window configuration.

## NOTES
- This function requires the `Get-OSActiveHours` function to be available when using the `-UseActiveHours` parameter.
- If the specified file already exists and `-Force` is not set, the user will be prompted for confirmation before updating.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx) 