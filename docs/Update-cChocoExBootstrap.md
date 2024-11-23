# Update-cChocoExBootstrap

## SYNOPSIS
Updates the cChocoEx bootstrap file.

## DESCRIPTION
The `Update-cChocoExBootstrap` function compares the provided remote URI file hash to the local `bootstrap.ps1` file and updates it if necessary.

## SYNTAX

```powershell
Update-cChocoExBootstrap -Uri <String>
```

## PARAMETERS

### -Uri
Specifies the URL of the bootstrap PowerShell script.

```powershell
Type: String
Parameter Sets: (All)
Required: False
Default value: $env:cChocoExBootstrapUri
```

## EXAMPLES

### Example 1: Update Bootstrap File
```powershell
Update-cChocoExBootstrap -Uri 'https://contoso.com/bootstrap.ps1'
```
Updates the local bootstrap file if the remote file has a different hash.

## OUTPUTS
Returns a PSCustomObject with details about the update process.

## NOTES
- The function requires elevated privileges to run.
- If the URI is not provided, it defaults to the environment variable `cChocoExBootstrapUri`.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx) 