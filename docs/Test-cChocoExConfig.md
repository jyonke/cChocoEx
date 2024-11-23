# Test-cChocoExConfig

## SYNOPSIS
Returns Chocolatey Configuration DSC Configuration Status in cChocoEx.

## DESCRIPTION
The `Test-cChocoExConfig` function checks the status of the Chocolatey configuration in cChocoEx and returns the results as a PowerShell Custom Object.

## SYNTAX

```powershell
Test-cChocoExConfig -Path <String> [-Quiet <Switch>]
```

## PARAMETERS

### -Path
Specifies the path to the cChocoEx configuration file. If not provided, defaults to the configuration file in the global configuration folder.

```powershell
Type: String
Parameter Sets: (All)
Required: False
```

### -Quiet
If specified, returns a boolean value indicating the overall status of the configuration tests.

```powershell
Type: Switch
Parameter Sets: (All)
Required: False
```

## EXAMPLES

### Example 1: Test Configuration with Default Path
```powershell
Test-cChocoExConfig
```
Returns the status of the Chocolatey configuration using the default configuration file.

### Example 2: Test Configuration with Custom Path
```powershell
Test-cChocoExConfig -Path 'C:\Path\To\Your\config.psd1'
```
Returns the status of the Chocolatey configuration using the specified configuration file.

### Example 3: Quiet Mode
```powershell
Test-cChocoExConfig -Quiet
```
Returns `True` or `False` based on the status of all tests without detailed output.

## OUTPUTS
Returns an array of PowerShell Custom Objects with the configuration status.

## NOTES
- The function imports the configuration module and checks for the specified configuration file.
- If no configuration file is found, a warning is issued.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx) 