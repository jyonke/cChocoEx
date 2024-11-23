# Test-cChocoExSource

## SYNOPSIS
Returns Chocolatey Source DSC Configuration Status in cChocoEx.

## DESCRIPTION
The `Test-cChocoExSource` function checks the status of the package sources configuration in cChocoEx and returns the results as a PowerShell Custom Object.

## SYNTAX

```powershell
Test-cChocoExSource -Path <String> [-Quiet <Switch>]
```

## PARAMETERS

### -Path
Specifies the path to the cChocoEx sources configuration file. If not provided, defaults to the sources file in the global configuration folder.

```powershell
Type: String
Parameter Sets: (All)
Required: False
```

### -Quiet
If specified, returns a boolean value indicating the overall status of the source tests.

```powershell
Type: Switch
Parameter Sets: (All)
Required: False
```

## EXAMPLES

### Example 1: Test Source with Default Path
```powershell
Test-cChocoExSource
```
Returns the status of the package sources using the default sources configuration file.

### Example 2: Test Source with Custom Path
```powershell
Test-cChocoExSource -Path 'C:\Path\To\Your\sources.psd1'
```
Returns the status of the package sources using the specified sources configuration file.

### Example 3: Quiet Mode
```powershell
Test-cChocoExSource -Quiet
```
Returns `True` or `False` based on the status of all tests without detailed output.

## OUTPUTS
Returns an array of PowerShell Custom Objects with the source status.

## NOTES
- The function checks for the specified sources configuration file and retrieves the source settings.
- If no sources file is found, a warning is issued.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx) 