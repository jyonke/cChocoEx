# Update-cChocoExMaintenanceWindowFile

## SYNOPSIS
Updates or removes a maintenance window in a cChocoEx maintenance window configuration file.

## DESCRIPTION
The `Update-cChocoExMaintenanceWindowFile` function allows you to add, update, or remove maintenance windows in a cChocoEx maintenance window configuration file. It ensures that the resulting file is properly formatted.

## SYNTAX

```powershell
Update-cChocoExMaintenanceWindowFile -Path <String> -EffectiveDateTime <String> -Start <String> -End <String> -UTC <Boolean> [-Remove <Switch>]
```

## PARAMETERS

### -Path
Specifies the path to the cChocoEx maintenance window configuration file.

```powershell
Type: String
Parameter Sets: (All)
Required: True
```

### -EffectiveDateTime
Specifies the effective date and time for the maintenance window.

```powershell
Type: String
Parameter Sets: (All)
Required: True
```

### -Start
Specifies the start time for the maintenance window.

```powershell
Type: String
Parameter Sets: (All)
Required: True
```

### -End
Specifies the end time for the maintenance window.

```powershell
Type: String
Parameter Sets: (All)
Required: True
```

### -UTC
Indicates whether the times are in UTC.

```powershell
Type: Boolean
Parameter Sets: (All)
Required: True
```

### -Remove
Switch to remove the specified maintenance window from the configuration file.

```powershell
Type: Switch
Parameter Sets: (All)
Required: False
```

## EXAMPLES

### Example 1: Update Maintenance Window File
```powershell
Update-cChocoExMaintenanceWindowFile -Path 'C:\ProgramData\cChocoEx\config\maintenance.psd1' -EffectiveDateTime '2023-01-01T00:00:00Z' -Start '22:00' -End '06:00' -UTC $true
```
Updates or adds the specified maintenance window in the configuration file.

### Example 2: Remove Maintenance Window
```powershell
Update-cChocoExMaintenanceWindowFile -Path 'C:\ProgramData\cChocoEx\config\maintenance.psd1' -Remove
```
Removes the specified maintenance window from the configuration file.

## OUTPUTS
None. This function modifies the maintenance window configuration file directly.

## NOTES
- The function creates a temporary file to hold the updated maintenance windows before replacing the original file.
- It requires the PSScriptAnalyzer module for formatting the output file.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx) 