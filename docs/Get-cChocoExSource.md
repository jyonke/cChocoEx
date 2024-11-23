# Get-cChocoExSource

## SYNOPSIS
Returns Chocolatey Sources DSC Configuration settings from cChocoEx.

## DESCRIPTION
The `Get-cChocoExSource` function retrieves and returns the Chocolatey sources configuration from cChocoEx as PowerShell Custom Objects. This function allows filtering based on various parameters, making it useful for managing package sources in a Chocolatey environment.

## SYNTAX

```powershell
Get-cChocoExSource 
    [-cChocoExSourceFile <String[]>] 
    [-Name <String>] 
    [-Ensure <String>] 
    [-Source <String>] 
    [-Priority <Nullable[Int32>]] 
    [-User <String>] 
    [-Password <String>] 
    [-Keyfile <String>] 
    [-VPN <Nullable[Boolean>]]
```

## PARAMETERS

### -cChocoExSourceFile
Specifies the path to the cChocoEx sources configuration file. If not specified, defaults to 'sources.psd1' in the cChocoEx configuration folder.

```powershell
Type: String[]
Parameter Sets: (All)
Aliases: FullName, Path
Required: False
```

### -Name
Filters results to return only configurations with the specified source name.

```powershell
Type: String
Parameter Sets: (All)
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
Filters results to return only configurations with the specified source URL.

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

### -User
Filters results to return only configurations with the specified user.

```powershell
Type: String
Parameter Sets: Present
Required: False
```

### -Password
Filters results to return only configurations with the specified password.

```powershell
Type: String
Parameter Sets: Present
Required: False
```

### -Keyfile
Filters results to return only configurations with the specified key file.

```powershell
Type: String
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

## EXAMPLES

### Example 1: Get all sources
```powershell
Get-cChocoExSource
```

Returns all sources from the default sources file.

### Example 2: Get a specific source
```powershell
Get-cChocoExSource -Name 'mySource'
```

Returns the configuration for the source named 'mySource'.

### Example 3: Get sources with a specific priority
```powershell
Get-cChocoExSource -Priority 1
```

Returns all sources with a priority of 1.

## OUTPUTS

### PSCustomObject[]
Returns an array of source configurations as PowerShell Custom Objects with the following properties:
- PSTypeName: Set to 'cChocoExSource'
- Name: The name of the source
- Ensure: The state of the source (Present/Absent)
- Priority: The priority of the source
- Source: The source URL
- User: The user for the source
- Password: The password for the source
- KeyFile: The key file for the source
- VPN: Indicates if VPN is required

## NOTES
- The function validates the existence of the sources configuration file and raises a warning if not found.
- If no filters are applied, all source configurations are returned.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx) 