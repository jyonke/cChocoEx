# Update-cChocoExSourceFile

## SYNOPSIS
Updates or removes a Chocolatey source in a cChocoEx source configuration file.

## DESCRIPTION
The `Update-cChocoExSourceFile` function allows you to add, update, or remove Chocolatey sources in a cChocoEx source configuration file. It ensures that the resulting file is properly formatted.

## SYNTAX

```powershell
Update-cChocoExSourceFile -Path <String> -Name <String> [-Ensure <String>] [-Remove <Switch>]
```

## PARAMETERS

### -Path
Specifies the path to the cChocoEx source configuration file.

```powershell
Type: String
Parameter Sets: (All)
Required: True
```

### -Name
Specifies the name of the Chocolatey source to update or remove.

```powershell
Type: String
Parameter Sets: (All)
Required: True
```

### -Ensure
Specifies whether the source should be present or absent. Default is 'Present'.

```powershell
Type: String
Parameter Sets: (All)
Required: False
Default value: 'Present'
```

### -Remove
Switch to remove the specified source from the configuration file.

```powershell
Type: Switch
Parameter Sets: (All)
Required: False
```

## EXAMPLES

### Example 1: Update Source File
```powershell
Update-cChocoExSourceFile -Path 'C:\ProgramData\cChocoEx\config\sources.psd1' -Name 'chocolatey' -Source 'https://chocolatey.org/api/v2/' -Priority 0
```
Updates or adds the specified source in the configuration file.

### Example 2: Remove Source
```powershell
Update-cChocoExSourceFile -Path 'C:\ProgramData\cChocoEx\config\sources.psd1' -Name 'internal' -Remove
```
Removes the specified source from the configuration file.

## OUTPUTS
None. This function modifies the source configuration file directly.

## NOTES
- The function creates a temporary file to hold the updated sources before replacing the original file.
- It requires the PSScriptAnalyzer module for formatting the output file.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx)