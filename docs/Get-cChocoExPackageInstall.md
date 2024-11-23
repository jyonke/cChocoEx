# Get-cChocoExPackageInstall

## SYNOPSIS
Returns Chocolatey Package DSC Configuration settings from cChocoEx.

## DESCRIPTION
The `Get-cChocoExPackageInstall` function retrieves and returns the Chocolatey package installation configurations from cChocoEx as PowerShell Custom Objects. This function allows filtering based on various parameters, making it useful for managing package installations in a Chocolatey environment.

## SYNTAX

```powershell
Get-cChocoExPackageInstall 
    [-cChocoExPackageFile <String[]>] 
    [-Name <String>] 
    [-Ring <String>] 
    [-Ensure <String>] 
    [-Source <String>] 
    [-MinimumVersion <String>] 
    [-Version <String>] 
    [-OverrideMaintenanceWindow <Nullable[Boolean>]] 
    [-AutoUpgrade <Nullable[Boolean>]] 
    [-VPN <Nullable[Boolean>]] 
    [-Params <String>] 
    [-ChocoParams <String>] 
    [-Priority <Nullable[Int32>]] 
    [-EnvRestriction <String>]
```

## PARAMETERS

### -cChocoExPackageFile
Specifies the path to the cChocoEx package configuration files. If not specified, defaults to all `.psd1` files in the configuration folder, excluding specific files.

```powershell
Type: String[]
Parameter Sets: (All)
Aliases: FullName, Path
Required: False
```

### -Name
Filters results to return only configurations with the specified package name.

```powershell
Type: String
Parameter Sets: Present, Absent, Remove
Required: False
```

### -Ring
Filters results to return only configurations with the specified deployment ring.

```powershell
Type: String
Parameter Sets: Present, Absent, Remove
Valid values: "Preview", "Canary", "Pilot", "Fast", "Slow", "Broad", "Exclude"
Required: False
```

### -Ensure
Filters results to return only configurations with the specified state (Present or Absent).

```powershell
Type: String
Parameter Sets: Present, Absent
Valid values: "Present", "Absent"
Required: False
```

### -Source
Filters results to return only configurations with the specified source.

```powershell
Type: String
Parameter Sets: Present
Required: False
```

### -MinimumVersion
Filters results to return only configurations with the specified minimum version.

```powershell
Type: String
Parameter Sets: Present
Required: False
```

### -Version
Filters results to return only configurations with the specified version.

```powershell
Type: String
Parameter Sets: Present
Required: False
```

### -OverrideMaintenanceWindow
Filters results to return only configurations that override the maintenance window setting.

```powershell
Type: Nullable[Boolean]
Parameter Sets: Present
Required: False
```

### -AutoUpgrade
Filters results to return only configurations that have auto-upgrade enabled or disabled.

```powershell
Type: Nullable[Boolean]
Parameter Sets: Present
Required: False
```

### -VPN
Filters results to return only configurations that require VPN.

```powershell
Type: Nullable[Boolean]
Parameter Sets: Present
Required: False
```

### -Params
Filters results to return only configurations with the specified parameters.

```powershell
Type: String
Parameter Sets: Present
Required: False
```

### -ChocoParams
Filters results to return only configurations with the specified Chocolatey parameters.

```powershell
Type: String
Parameter Sets: Present
Required: False
```

### -Priority
Filters results to return only configurations with the specified priority.

```powershell
Type: Nullable[Int32]
Parameter Sets: Present
Required: False
```

### -EnvRestriction
Filters results to return only configurations with the specified environment restriction.

```powershell
Type: String
Parameter Sets: Present
Valid values: "VPN", "TSEnv", "OOBE", "Autopilot"
Required: False
```

## EXAMPLES

### Example 1: Get all package installations
```powershell
Get-cChocoExPackageInstall
```

Returns all package installation configurations from the default package files.

### Example 2: Get a specific package installation
```powershell
Get-cChocoExPackageInstall -Name 'git'
```

Returns the configuration for the 'git' package installation.

### Example 3: Get package installations in a specific ring
```powershell
Get-cChocoExPackageInstall -Ring 'Fast'
```

Returns all package installations that are in the 'Fast' ring.

### Example 4: Get package installations with auto-upgrade enabled
```powershell
Get-cChocoExPackageInstall -AutoUpgrade $true
```

Returns all package installations that have auto-upgrade enabled. 