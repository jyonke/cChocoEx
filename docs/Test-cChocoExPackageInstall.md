# Test-cChocoExPackageInstall

## SYNOPSIS
Returns Chocolatey Package Install DSC Configuration Status in cChocoEx.

## DESCRIPTION
The `Test-cChocoExPackageInstall` function checks the status of the package installation configuration in cChocoEx and returns the results as a PowerShell Custom Object.

## SYNTAX

```powershell
Test-cChocoExPackageInstall -Path <String> [-Quiet <Switch>]
```

## PARAMETERS

### -Path
Specifies the path to the cChocoEx package configuration files. If not provided, defaults to the package files in the global configuration folder.

```powershell
Type: String
Parameter Sets: (All)
Required: False
```

### -Quiet
If specified, returns a boolean value indicating the overall status of the package installation tests.

```powershell
Type: Switch
Parameter Sets: (All)
Required: False
```

## EXAMPLES

### Example 1: Test Package Install with Default Path
```powershell
Test-cChocoExPackageInstall
```
Returns the status of the package installation using the default package configuration files.

### Example 2: Test Package Install with Custom Path
```powershell
Test-cChocoExPackageInstall -Path 'C:\Path\To\Your\packages.psd1'
```
Returns the status of the package installation using the specified package configuration files.

### Example 3: Quiet Mode
```powershell
Test-cChocoExPackageInstall -Quiet
```
Returns `True` or `False` based on the status of all tests without detailed output.

## OUTPUTS
Returns an array of PowerShell Custom Objects with the package installation status.

## NOTES
- The function checks for the specified package configuration files and retrieves the installation settings.
- If no package files are found, a warning is issued.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx) 