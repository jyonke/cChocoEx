# Get-cChocoExFeature

## SYNOPSIS
Returns Chocolatey Features DSC Configuration settings from cChocoEx.

## DESCRIPTION
The `Get-cChocoExFeature` function retrieves and returns Chocolatey feature configurations from the cChocoEx features file. It returns the features as PowerShell Custom Objects with a PSTypeName of 'cChocoExFeature', allowing for easy filtering and management of Chocolatey features.

## SYNTAX

```powershell
Get-cChocoExFeature 
    [-cChocoExFeatureFile <String[]>] 
    [-FeatureName <String>] 
    [-Ensure <String>]
```

## PARAMETERS

### -cChocoExFeatureFile
Specifies the path to the cChocoEx features configuration file. If not specified, defaults to 'features.psd1' in the cChocoEx configuration folder.

```powershell
Type: String[]
Parameter Sets: (All)
Aliases: FullName, Path
Required: False
Default value: $Global:cChocoExConfigurationFolder\features.psd1
```

### -FeatureName
Filters results to show only features matching the specified name.

```powershell
Type: String
Parameter Sets: (All)
Required: False
```

### -Ensure
Filters results to show only features with the specified state (Present or Absent).

```powershell
Type: String
Parameter Sets: Present, Absent
Valid values: "Present", "Absent"
Required: False
```

## EXAMPLES

### Example 1: Get all Chocolatey features
```powershell
Get-cChocoExFeature
```

Returns all Chocolatey features from the default features file.

### Example 2: Get a specific feature
```powershell
Get-cChocoExFeature -FeatureName 'allowGlobalConfirmation'
```

Returns the configuration for the 'allowGlobalConfirmation' feature.

### Example 3: Get features from a specific file
```powershell
Get-cChocoExFeature -cChocoExFeatureFile 'C:\ProgramData\cChocoEx\config\custom-features.psd1'
```

Returns all features from a specified configuration file.

### Example 4: Get enabled features
```powershell
Get-cChocoExFeature -Ensure 'Present'
```

Returns all features that are enabled (Present).

### Example 5: Get disabled features
```powershell
Get-cChocoExFeature -Ensure 'Absent'
```

Returns all features that are disabled (Absent).

## OUTPUTS

### PSCustomObject
Returns objects with the following properties:
- PSTypeName: Set to 'cChocoExFeature'
- FeatureName: The name of the Chocolatey feature
- Ensure: The state of the feature (Present/Absent)
- Path: The full path to the features configuration file

## NOTES
- The function validates configuration keys against a predefined set of valid keys
- Invalid configuration keys will generate an error
- If the features file doesn't exist, a warning is displayed
- The function supports pipeline input for the file path

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx)
- [Update-cChocoExFeatureFile](./Update-cChocoExFeatureFile.md)
- [Chocolatey Features Documentation](https://docs.chocolatey.org/en-us/configuration#features) 