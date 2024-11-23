# New-cChocoExPackageInstallFile

## SYNOPSIS
Creates a Chocolatey Packages DSC Configuration File for cChocoEx.

## DESCRIPTION
The `New-cChocoExPackageInstallFile` function creates a Chocolatey Packages DSC Configuration File for cChocoEx as a PowerShell Data File. It allows users to specify various package installation options interactively.

## SYNTAX

```powershell
New-cChocoExPackageInstallFile -Path <String> [-NoClobber <Switch>]
```

## PARAMETERS

### -Path
Specifies the path of the output file where the package installation configuration will be saved.

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

### Example 1: Create a new package installation file
```powershell
New-cChocoExPackageInstallFile -Path 'C:\ProgramData\cChocoEx\packages.psd1'
```

Creates a new Chocolatey package installation file at the specified path.

## OUTPUTS

### PowerShell Data File
Creates a PowerShell Data File containing the specified package installation options.

## NOTES
- The function prompts the user to select package installation options using a graphical interface.
- If the specified file already exists and `-NoClobber` is set, the user will be prompted for an alternative path.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx) 