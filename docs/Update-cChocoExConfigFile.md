# Update-cChocoExConfigFile

## SYNOPSIS
Updates the cChocoEx configuration file.

## DESCRIPTION
The `Update-cChocoExConfigFile` function modifies the existing cChocoEx configuration file or creates a new one based on the provided parameters. It ensures that the resulting file is properly formatted.

## SYNTAX

```powershell
Update-cChocoExConfigFile -Path <String> [-Remove <Switch>]
```

## PARAMETERS

### -Path
Specifies the path to the cChocoEx configuration file.

```powershell
Type: String
Parameter Sets: (All)
Required: True
```

### -Remove
Switch to remove the specified configuration from the file.

```powershell
Type: Switch
Parameter Sets: (All)
Required: False
```

## EXAMPLES

### Example 1: Update Configuration File
```powershell
Update-cChocoExConfigFile -Path 'C:\ProgramData\cChocoEx\config.psd1'
```
Updates the specified cChocoEx configuration file.

### Example 2: Remove Configuration
```powershell
Update-cChocoExConfigFile -Path 'C:\ProgramData\cChocoEx\config.psd1' -Remove
```
Removes the specified configuration from the cChocoEx configuration file.

## OUTPUTS
None. This function modifies the configuration file directly.

## NOTES
- The function creates a temporary file to hold the updated configuration before replacing the original file.
- It requires the PSScriptAnalyzer module for formatting the output file.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx) 