# cChocoEx

A PowerShell DSC module for advanced Chocolatey package management and configuration in enterprise environments.

[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/cChocoEx)](https://www.powershellgallery.com/packages/cChocoEx)
[![Documentation](https://img.shields.io/badge/docs-gitbook-blue)](https://jon-yonke.gitbook.io/cchocoex/)

## Overview

cChocoEx extends Chocolatey's functionality with enterprise-focused features:
- Automated package installation and configuration
- Maintenance window management
- Task scheduling
- Configuration management
- Source control
- Feature management
- Detailed logging

## Quick Start

### Installation
```powershell
# Install from PowerShell Gallery
Install-Module -Name cChocoEx -Scope AllUsers

# Import the module
Import-Module cChocoEx
```

### Basic Usage

1. Initialize the environment:
```powershell
Set-cChocoExEnvironment
```

2. Start cChocoEx with remote configurations:
```powershell
Start-cChocoEx -PackageConfig "https://config.contoso.com/chocolatey/packages.psd1"
```

## Features

### Maintenance Windows
Control when package installations and updates occur:
```powershell
New-cChocoExMaintenanceWindow -Start "22:00" -End "04:00" -UTC $false
```

### Package Management
Install and configure multiple packages:
```powershell
Start-cChocoEx -PackageConfig @(
    "https://config.contoso.com/chocolatey/dev-packages.psd1",
    "https://config.contoso.com/chocolatey/security-packages.psd1"
)
```

### Scheduled Tasks
Automate package management:
```powershell
Start-cChocoEx -Loop -LoopDelay 120 -RandomDelay
```

### Configuration Management
Manage Chocolatey settings:
```powershell
Start-cChocoEx -ChocoConfig "https://config.contoso.com/chocolatey/config.psd1" `
               -SourcesConfig "https://config.contoso.com/chocolatey/sources.psd1" `
               -FeatureConfig "https://config.contoso.com/chocolatey/features.psd1"
```

## Configuration Files

### Package Configuration
```powershell
# https://config.contoso.com/chocolatey/packages.psd1
@{
    'Packages' = @{
        'googlechrome' = @{
            'Name' = 'googlechrome'
            'Version' = 'Latest'
            'Ensure' = 'Present'
            'AutoUpgrade' = $true
            'Source' = 'chocolatey'
        }
        'vscode' = @{
            'Name' = 'vscode'
            'Version' = '1.85.1'
            'Ensure' = 'Present'
            'AutoUpgrade' = $false
            'Source' = 'chocolatey'
            'Params' = '/NoDesktopIcon'
        }
    }
}
```

### Source Configuration
```powershell
# https://config.contoso.com/chocolatey/sources.psd1
@{
    'Sources' = @{
        'chocolatey' = @{
            'Name' = 'chocolatey'
            'Source' = 'https://community.chocolatey.org/api/v2/'
            'Priority' = 0
            'Ensure' = 'Present'
            'User' = ''
            'Password' = ''
        }
        'internal' = @{
            'Name' = 'internal'
            'Source' = 'https://nuget.contoso.com/chocolatey'
            'Priority' = 1
            'Ensure' = 'Present'
            'User' = '$env:ChocoInternalUser'
            'Password' = '$env:ChocoInternalPassword'
        }
    }
}
```

### Feature Configuration
```powershell
# https://config.contoso.com/chocolatey/features.psd1
@{
    'Features' = @{
        'allowGlobalConfirmation' = @{
            'Name' = 'allowGlobalConfirmation'
            'Ensure' = 'Present'
        }
        'useRememberedArgumentsForUpgrades' = @{
            'Name' = 'useRememberedArgumentsForUpgrades'
            'Ensure' = 'Present'
        }
    }
}
```

## Enterprise Features

- Remote configuration deployment
- Task Sequence awareness
- Windows PE detection
- Event logging
- Detailed execution logs
- Error handling and recovery
- Configuration backup and restore

## Requirements

- Windows PowerShell 5.1 or PowerShell 7+
- Administrative privileges
- Internet connectivity (for package downloads)
- Chocolatey installation (automatic if not present)

## Documentation

Detailed documentation is available on [GitBook](https://jon-yonke.gitbook.io/cchocoex/).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

Jon Yonke

## Support

For issues and feature requests, please use the GitHub issues page.

