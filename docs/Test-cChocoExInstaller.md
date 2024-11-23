# Test-cChocoExInstaller

## SYNOPSIS
Returns Chocolatey Install DSC Configuration Status in cChocoEx.

## DESCRIPTION
The `Test-cChocoExInstaller` function checks the installation status of Chocolatey in cChocoEx and returns the results as a PowerShell Custom Object.

## SYNTAX

```powershell
Test-cChocoExInstaller [-Quiet <Switch>]
```

## PARAMETERS

### -Quiet
If specified, returns a boolean value indicating the overall status of the installation tests.

```powershell
Type: Switch
Parameter Sets: (All)
Required: False
```

## EXAMPLES

### Example 1: Test Chocolatey Installation
```powershell
Test-cChocoExInstaller
```
Returns the status of the Chocolatey installation.

### Example 2: Quiet Mode
```powershell
Test-cChocoExInstaller -Quiet
```
Returns `True` or `False` based on the status of the installation test without detailed output.

## OUTPUTS
Returns a PowerShell Custom Object with the installation status.

## NOTES
- The function imports the installer module and checks the installation directory.
- If the installation is not found, a warning is issued.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx) 