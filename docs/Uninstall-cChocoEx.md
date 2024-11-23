# Uninstall-cChocoEx

## SYNOPSIS
Uninstalls the cChocoEx PowerShell Module.

## DESCRIPTION
The `Uninstall-cChocoEx` function uninstalls the cChocoEx PowerShell Module and optionally wipes the associated data folder.

## SYNTAX

```powershell
Uninstall-cChocoEx [-Wipe <Switch>]
```

## PARAMETERS

### -Wipe
If specified, this switch will remove the cChocoEx data folder.

```powershell
Type: Switch
Parameter Sets: (All)
Required: False
```

## EXAMPLES

### Example 1: Uninstall cChocoEx Module
```powershell
Uninstall-cChocoEx
```
Uninstalls the cChocoEx PowerShell Module without wiping the data folder.

### Example 2: Uninstall and Wipe Data
```powershell
Uninstall-cChocoEx -Wipe
```
Uninstalls the cChocoEx PowerShell Module and wipes the associated data folder.

## OUTPUTS
None. This function performs the uninstallation and data removal directly.

## NOTES
- The function requires elevated privileges to run.
- It unregisters any scheduled tasks associated with cChocoEx.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx) 