# New-cChocoExConfigFile

## SYNOPSIS
Creates a Chocolatey Configuration DSC Configuration file for cChocoEx.

## DESCRIPTION
The `New-cChocoExConfigFile` function creates a Chocolatey Configuration DSC Configuration file for cChocoEx as a PowerShell Data File. It allows users to specify various configuration options interactively.

## SYNTAX

```powershell
New-cChocoExConfigFile -Path <String> [-NoClobber <Switch>]
```

## PARAMETERS

### -Path
Specifies the path of the output file where the configuration will be saved.

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

### Example 1: Create a new configuration file
```powershell
New-cChocoExConfigFile -Path 'C:\ProgramData\cChocoEx\config.psd1'
```

Creates a new Chocolatey configuration file at the specified path.

## OUTPUTS

### PowerShell Data File
Creates a PowerShell Data File containing the specified configuration options.

## NOTES
- The function prompts the user to select configuration options using a graphical interface.
- If the specified file already exists and `-NoClobber` is set, the user will be prompted for an alternative path.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx) 