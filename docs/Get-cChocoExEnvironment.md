# Get-cChocoExEnvironment

## SYNOPSIS
Returns detailed information about the current cChocoEx environment and system state.

## DESCRIPTION
The `Get-cChocoExEnvironment` function provides comprehensive information about the current cChocoEx environment, including operating system details, configuration paths, Chocolatey installation status, system uptime, and various environment states. This function is useful for diagnostics, troubleshooting, and environment validation.

## SYNTAX

```powershell
Get-cChocoExEnvironment
```

## PARAMETERS
This function does not accept any parameters.

## OUTPUTS

### PSCustomObject
Returns an object with the following properties:

- **OS**: Operating system caption
- **OSVersion**: Operating system version
- **OSEnvironment**: Current OS environment (WinOS, OOBE, WinPE, or WinSE)
- **ModuleBase**: Base path of the cChocoEx module
- **cChocoExDataFolder**: Path to cChocoEx data folder
- **cChocoExConfigurationFolder**: Path to configuration folder
- **cChocoExTMPConfigurationFolder**: Path to temporary configuration folder
- **cChocoExBootstrap**: Bootstrap configuration status
- **cChocoExBootstrapUri**: URI for bootstrap configuration
- **cChocoExChocoConfig**: Path to Chocolatey configuration
- **cChocoExSourcesConfig**: Path to sources configuration
- **cChocoExPackageConfig**: Path to package configuration
- **cChocoExFeatureConfig**: Path to feature configuration
- **cChocoExLogPath**: Path to log files
- **cChocoExMediaFolder**: Path to media folder
- **ChocoDownloadUrl**: Chocolatey download URL
- **ChocoInstallScriptUrl**: Chocolatey install script URL
- **Ring**: Deployment ring configuration
- **TSEnv**: Task Sequence environment status
- **OOBE**: Windows OOBE state
- **VPNActive**: VPN connection status
- **ChocolateyInstall**: Chocolatey installation path
- **ChocolateyVersion**: Installed Chocolatey version
- **LastReboot**: Timestamp of last system reboot
- **Uptime**: System uptime in days, hours, minutes, and seconds

## EXAMPLES

### Example 1: Get environment information
```powershell
Get-cChocoExEnvironment
```

Returns complete environment information.

### Example 2: Check Chocolatey installation status
```powershell
(Get-cChocoExEnvironment).ChocolateyVersion
```

Returns only the installed Chocolatey version.

### Example 3: Get current OS environment
```powershell
(Get-cChocoExEnvironment).OSEnvironment
```

Returns the current operating system environment (WinOS, OOBE, WinPE, or WinSE).

### Example 4: Check system uptime
```powershell
$env = Get-cChocoExEnvironment
"System last rebooted at $($env.LastReboot) (Uptime: $($env.Uptime))"
```

Displays the last reboot time and current system uptime.

## NOTES
- Requires administrative privileges to access some system information
- Some properties may be null if the corresponding feature is not configured
- VPN status detection requires appropriate network adapter information
- Task Sequence environment detection requires running within a Configuration Manager Task Sequence

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx)
- [Test-WinOS.OOBE](./Test-WinOS.OOBE.md)
- [Test-TSEnv](./Test-TSEnv.md)
- [Get-cChocoExRing](./Get-cChocoExRing.md) 