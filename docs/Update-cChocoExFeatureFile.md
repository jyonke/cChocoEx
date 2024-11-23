# Update-cChocoExFeatureFile

## SYNOPSIS
Updates or removes a Chocolatey feature in a cChocoEx feature configuration file.

## DESCRIPTION
The `Update-cChocoExFeatureFile` function allows you to add, update, or remove Chocolatey features in a cChocoEx feature configuration file. It ensures that the resulting file is properly formatted.

## SYNTAX

```powershell
Update-cChocoExFeatureFile -Path <String> -FeatureName <String> [-Ensure <String>] [-Remove <Switch>]
```

## PARAMETERS

### -Path
Specifies the path to the cChocoEx feature configuration file.

```powershell
Type: String
Parameter Sets: (All)
Required: True
```

### -FeatureName
Specifies the name of the Chocolatey feature to update or remove.

```powershell
Type: String
Parameter Sets: (All)
Required: True
```

### -Ensure
Specifies whether the feature should be present or absent. Default is 'Present'.

```powershell
Type: String
Parameter Sets: (All)
Required: False
Default value: 'Present'
```

### -Remove
Switch to remove the specified feature from the configuration file.

```powershell
Type: Switch
Parameter Sets: (All)
Required: False
```

## EXAMPLES

### Example 1: Update Feature File
```powershell
Update-cChocoExFeatureFile -Path 'C:\ProgramData\cChocoEx\config\features.psd1' -FeatureName 'SomeFeature' -Ensure 'Present'
```
Updates or adds the specified feature in the configuration file.

### Example 2: Remove Feature
```powershell
Update-cChocoExFeatureFile -Path 'C:\ProgramData\cChocoEx\config\features.psd1' -FeatureName 'SomeFeature' -Remove
```
Removes the specified feature from the configuration file.

## OUTPUTS
None. This function modifies the feature configuration file directly.

## NOTES
- The function creates a temporary file to hold the updated features before replacing the original file.
- It requires the PSScriptAnalyzer module for formatting the output file.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx) 