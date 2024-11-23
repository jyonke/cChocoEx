# Start-cChocoEx

## SYNOPSIS
Bootstraps and manages the cChocoEx PowerShell DSC Module configuration.

## DESCRIPTION
The `Start-cChocoEx` function initializes, configures, and manages the cChocoEx environment. It handles installation, configuration management, and scheduled task creation for Chocolatey package management.

### Key Features:
- Chocolatey installation and configuration
- Package source management
- Feature configuration
- Package installation
- Maintenance window management
- Environment variable configuration
- Scheduled task management

## SYNTAX

```powershell
Start-cChocoEx 
    [-SettingsURI <String>] 
    [-InstallDir <String>] 
    [-ChocoInstallScriptUrl <String>] 
    [-ChocoDownloadUrl <String>] 
    [-SourcesConfig <String>] 
    [-PackageConfig <Array>] 
    [-ChocoConfig <String>] 
    [-FeatureConfig <String>] 
    [-NoCache <Switch>] 
    [-WipeCache <Switch>] 
    [-RandomDelay <Switch>] 
    [-Loop <Switch>] 
    [-LoopDelay <Int>] 
    [-MigrateLegacyConfigurations <Switch>] 
    [-OverrideMaintenanceWindow <Switch>] 
    [-EnableNotifications <Switch>] 
    [-SetcChocoExEnvironment <Switch>]
```

## PARAMETERS

### -SettingsURI
URI to a PowerShell Data File containing cChocoEx settings.

```powershell
Type: String
Parameter Sets: (All)
Required: False
```

### -InstallDir
Installation directory for Chocolatey. Defaults to `$env:ProgramData\chocolatey`.

```powershell
Type: String
Parameter Sets: (All)
Required: False
Default value: "$env:ProgramData\chocolatey"
```

### -ChocoInstallScriptUrl
URL to the Chocolatey installation script. Defaults to the official source.

```powershell
Type: String
Parameter Sets: (All)
Required: False
Default value: 'https://chocolatey.org/install.ps1'
```

### -ChocoDownloadUrl
Optional URL to a specific Chocolatey nupkg for installation.

```powershell
Type: String
Parameter Sets: (All)
Required: False
```

### -SourcesConfig
Path or URL to the Chocolatey sources configuration file.

```powershell
Type: String
Parameter Sets: (All)
Required: False
```

### -PackageConfig
Array of paths or URLs to package configuration files.

```powershell
Type: Array
Parameter Sets: (All)
Required: False
```

### -ChocoConfig
Path or URL to the Chocolatey configuration file.

```powershell
Type: String
Parameter Sets: (All)
Required: False
```

### -FeatureConfig
Path or URL to the Chocolatey features configuration file.

```powershell
Type: String
Parameter Sets: (All)
Required: False
```

### -NoCache
Prevents caching of configuration files. Files are downloaded to a temporary location.

```powershell
Type: Switch
Parameter Sets: (All)
Required: False
```

### -WipeCache
Wipes locally cached psd1 configurations.

```powershell
Type: Switch
Parameter Sets: (All)
Required: False
```

### -RandomDelay
Adds a random delay before starting the process.

```powershell
Type: Switch
Parameter Sets: (All)
Required: False
```

### -Loop
Enables continuous execution of the function.

```powershell
Type: Switch
Parameter Sets: (All)
Required: False
```

### -LoopDelay
Specifies the delay in minutes between task executions when looping.

```powershell
Type: Int
Parameter Sets: (All)
Required: False
Default value: 60
```

### -MigrateLegacyConfigurations
Enables migration of legacy configuration files.

```powershell
Type: Switch
Parameter Sets: (All)
Required: False
```

### -OverrideMaintenanceWindow
Overrides the maintenance window settings.

```powershell
Type: Switch
Parameter Sets: (All)
Required: False
```

### -EnableNotifications
Enables desktop notifications.

```powershell
Type: Switch
Parameter Sets: (All)
Required: False
```

### -SetcChocoExEnvironment
Sets machine environment variables for cChocoEx.

```powershell
Type: Switch
Parameter Sets: (All)
Required: False
```

## EXAMPLES

### Example 1: Basic Initialization
```powershell
Start-cChocoEx
```
Initializes the cChocoEx environment with default settings.

### Example 2: Custom Installation Directory
```powershell
Start-cChocoEx -InstallDir 'C:\Chocolatey'
```
Sets the installation directory for Chocolatey to `C:\Chocolatey`.

### Example 3: Using a Settings URI
```powershell
Start-cChocoEx -SettingsURI 'http://example.com/cChocoExSettings.psd1'
```
Downloads and applies settings from the specified URI.

### Example 4: Multiple Package Configurations
```powershell
Start-cChocoEx -PackageConfig @("packages1.psd1", "packages2.psd1") -NoCache
```
Processes multiple package configurations without caching files.

### Example 5: Enable Looping with Delay
```powershell
Start-cChocoEx -Loop -LoopDelay 120
```
Starts cChocoEx in continuous mode with 2-hour intervals.

### Example 6: Wipe Cache Before Starting
```powershell
Start-cChocoEx -WipeCache
```
Wipes any previously downloaded psd1 configuration files before starting.

### Example 7: Enable Notifications
```powershell
Start-cChocoEx -EnableNotifications
```
Enables desktop notifications during the execution of cChocoEx.

## OUTPUTS
None. This function does not generate any output.

## NOTES
- Administrative privileges are required for full functionality.
- The function includes checks for existing tasks and configurations to prevent conflicts.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx) 