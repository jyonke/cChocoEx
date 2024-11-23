# Update-cChocoExPackageInstallFile

## SYNOPSIS
Updates or removes a Chocolatey package installation in a cChocoEx package installation configuration file.

## DESCRIPTION
The `Update-cChocoExPackageInstallFile` function allows you to add, update, or remove Chocolatey package installations in a cChocoEx package installation configuration file. It ensures that the resulting file is properly formatted.

## SYNTAX

```powershell
Update-cChocoExPackageInstallFile -Path <String> -Name <String> -Ring <String> [-Ensure <String>] [-Remove <Switch>]
```

## PARAMETERS

### -Path
Specifies the path to the cChocoEx package installation configuration file.

```powershell
Type: String
Parameter Sets: (All)
Required: True
```

### -Name
Specifies the name of the Chocolatey package to update or remove.

```powershell
Type: String
Parameter Sets: (All)
Required: True
```

### -Ring
Specifies the deployment ring for the package.

```powershell
Type: String
Parameter Sets: (All)
Required: True
```

### -Ensure
Specifies whether the package should be present or absent. Default is 'Present'.

```powershell
Type: String
Parameter Sets: (All)
Required: False
Default value: 'Present'
```

### -Remove
Switch to remove the specified package from the configuration file.

```powershell
Type: Switch
Parameter Sets: (All)
Required: False
```

## EXAMPLES

### Example 1: Update Package Install File
```powershell
Update-cChocoExPackageInstallFile -Path 'C:\ProgramData\cChocoEx\config\packages.psd1' -Name 'SomePackage' -Ring 'Broad' -Ensure 'Present'
```
Updates or adds the specified package installation in the configuration file.

### Example 2: Remove Package Installation
```powershell
Update-cChocoExPackageInstallFile -Path 'C:\ProgramData\cChocoEx\config\packages.psd1' -Name 'SomePackage' -Ring 'Broad' -Remove
```
Removes the specified package installation from the configuration file.

## OUTPUTS
None. This function modifies the package installation configuration file directly.

## NOTES
- The function creates a temporary file to hold the updated package installations before replacing the original file.
- It requires the PSScriptAnalyzer module for formatting the output file.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx) 