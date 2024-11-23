# New-cChocoExFeatureFile

## SYNOPSIS
Creates a Chocolatey Features DSC Configuration File for cChocoEx.

## DESCRIPTION
The `New-cChocoExFeatureFile` function creates a Chocolatey Features DSC Configuration File for cChocoEx as a PowerShell Data File. It allows users to specify various feature options interactively.

## SYNTAX

```powershell
New-cChocoExFeatureFile -Path <String> [-NoClobber <Switch>]
```

## PARAMETERS

### -Path
Specifies the path of the output file where the feature configuration will be saved.

```powershell
Type: String
Parameter Sets: (All)
Required: True
```

### -NoClobber
Specifies that the command should not overwrite an existing file.

```powershell
Type: Switch
Parameter Sets: (All)
Required: False
```

## EXAMPLES

### Example 1: Create a new feature file
```powershell
New-cChocoExFeatureFile -Path 'C:\ProgramData\cChocoEx\features.psd1'
```

Creates a new Chocolatey feature file at the specified path.

## OUTPUTS

### PowerShell Data File
Creates a PowerShell Data File containing the specified feature options.

## NOTES
- The function prompts the user to select feature options using a graphical interface.
- If the specified file already exists and `-NoClobber` is set, the user will be prompted for an alternative path.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx) 