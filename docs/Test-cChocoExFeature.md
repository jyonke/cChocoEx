# Test-cChocoExFeature

## SYNOPSIS
Returns Chocolatey Feature DSC Configuration Status in cChocoEx.

## DESCRIPTION
The `Test-cChocoExFeature` function checks the status of the Chocolatey features in cChocoEx and returns the results as a PowerShell Custom Object.

## SYNTAX

```powershell
Test-cChocoExFeature -Path <String> [-Quiet <Switch>]
```

## PARAMETERS

### -Path
Specifies the path to the cChocoEx features configuration file. If not provided, defaults to the features file in the global configuration folder.

```powershell
Type: String
Parameter Sets: (All)
Required: False
```

### -Quiet
If specified, returns a boolean value indicating the overall status of the feature tests.

```powershell
Type: Switch
Parameter Sets: (All)
Required: False
```

## EXAMPLES

### Example 1: Test Features with Default Path
```powershell
Test-cChocoExFeature
```
Returns the status of the Chocolatey features using the default features file.

### Example 2: Test Features with Custom Path
```powershell
Test-cChocoExFeature -Path 'C:\Path\To\Your\features.psd1'
```
Returns the status of the Chocolatey features using the specified features file.

### Example 3: Quiet Mode
```powershell
Test-cChocoExFeature -Quiet
```
Returns `True` or `False` based on the status of all tests without detailed output.

## OUTPUTS
Returns an array of PowerShell Custom Objects with the feature status.

## NOTES
- The function imports the feature module and checks for the specified features file.
- If no features file is found, a warning is issued.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx) 