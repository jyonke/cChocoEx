# Test-ChocolateyConfig

## SYNOPSIS
Tests the Chocolatey configuration status.

## DESCRIPTION
The `Test-ChocolateyConfig` function checks the existence of the Chocolatey configuration and backup files and returns a boolean indicating the status.

## SYNTAX

```powershell
Test-ChocolateyConfig
```

## EXAMPLES

### Example 1: Test Chocolatey Configuration
```powershell
Test-ChocolateyConfig
```
Returns `True` if the Chocolatey configuration file exists, otherwise returns `False`.

## OUTPUTS
Returns a boolean value indicating the existence of the configuration file.

## NOTES
- The function checks both the main configuration file and its backup.
- If the configuration file is not found, it returns `False`.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx) 