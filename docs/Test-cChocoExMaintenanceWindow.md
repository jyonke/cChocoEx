# Test-cChocoExMaintenanceWindow

## SYNOPSIS
Returns Maintenance Window DSC Configuration in cChocoEx.

## DESCRIPTION
The `Test-cChocoExMaintenanceWindow` function checks the status of the maintenance window configuration in cChocoEx and returns the results as a PowerShell Custom Object.

## SYNTAX

```powershell
Test-cChocoExMaintenanceWindow -Path <String>
```

## PARAMETERS

### -Path
Specifies the path to the cChocoEx configuration file. If not provided, defaults to the configuration file in the global configuration folder.

```powershell
Type: String
Parameter Sets: (All)
Required: False
```

## EXAMPLES

### Example 1: Test Maintenance Window with Default Path
```powershell
Test-cChocoExMaintenanceWindow
```
Returns the status of the maintenance window using the default configuration file.

### Example 2: Test Maintenance Window with Custom Path
```powershell
Test-cChocoExMaintenanceWindow -Path 'C:\Path\To\Your\config.psd1'
```
Returns the status of the maintenance window using the specified configuration file.

## OUTPUTS
Returns a PowerShell Custom Object with the maintenance window status.

## NOTES
- The function checks for the specified configuration file and retrieves the maintenance window settings.
- If no configuration file is found, a warning is issued.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx) 