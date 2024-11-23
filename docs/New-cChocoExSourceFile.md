# New-cChocoExSourceFile

## SYNOPSIS
Creates a Chocolatey Sources DSC Configuration File for cChocoEx.

## DESCRIPTION
The `New-cChocoExSourceFile` function creates a Chocolatey Sources DSC Configuration File for cChocoEx as a PowerShell Data File. It allows users to specify various source options interactively.

## SYNTAX

```powershell
New-cChocoExSourceFile -Path <String> [-NoClobber <Switch>]
```

## PARAMETERS

### -Path
Specifies the path of the output file where the source configuration will be saved.

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

### Example 1: Create a new source file
```powershell
New-cChocoExSourceFile -Path 'C:\ProgramData\cChocoEx\sources.psd1'
```

Creates a new Chocolatey source file at the specified path.

## OUTPUTS

### PowerShell Data File
Creates a PowerShell Data File containing the specified source options.

## NOTES
- The function prompts the user to select source options using a graphical interface.
- If the specified file already exists and `-NoClobber` is set, the user will be prompted for an alternative path.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx) 