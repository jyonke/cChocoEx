function Reset-ChocolateyConfig {
    <#
    .SYNOPSIS
        Resets the Chocolatey configuration to its default state or restores from backup.

    .DESCRIPTION
        This function manages the Chocolatey configuration by performing one of two actions:
        1. If a backup configuration exists, restores from the backup file
        2. If no backup exists, removes the current configuration and forces Chocolatey
           to regenerate its default configuration

        The function checks both the main configuration file and its backup at:
        - Main: $env:ChocolateyInstall\config\chocolatey.config
        - Backup: $env:ChocolateyInstall\config\chocolatey.config.backup

    .EXAMPLE
        Reset-ChocolateyConfig
        Attempts to reset the Chocolatey configuration and returns the status of the operation.

    .EXAMPLE
        $result = Reset-ChocolateyConfig
        $result.Reset
        Resets the configuration and checks if the operation was successful.

    .OUTPUTS
        [PSCustomObject] with the following properties:
        - Config: String path to the configuration file
        - Reset: Boolean indicating if the reset was successful

    .NOTES
        Author: Jon Yonke
        Version: 1.0
        Created: 2024-02-11
        
        Required Dependencies:
        - Chocolatey must be installed
        - Test-ChocolateyConfig function
        
        Environment Variables Used:
        - $env:ChocolateyInstall

        Administrative Rights:
        - Required for modifying Chocolatey configuration files
    #>
    [CmdletBinding()]
    param()
    
    begin {
        $Config = Join-Path $env:ChocolateyInstall 'config\chocolatey.config'
        $ConfigBackup = Join-Path $env:ChocolateyInstall 'config\chocolatey.config.backup'
    }
    
    process {
        #Validate Configuration Files Exist
        if (Test-Path -Path $Config) {
            [xml]$ConfigXml = Get-Content -Path $Config -ErrorAction SilentlyContinue
        }
        if (Test-Path -Path $ConfigBackup) {
            [xml]$ConfigBackupXml = Get-Content -Path $ConfigBackup -ErrorAction SilentlyContinue
        }
        #Restore last config backup
        if ($ConfigBackupXml) {
            Copy-Item -Path $ConfigBackup -Destination $Config -Force        
        }
        #Purge files and restore default
        else {
            Remove-Item -Path $Config -Force -ErrorAction SilentlyContinue
            Remove-Item -Path $ConfigBackup -Force -ErrorAction SilentlyContinue
            $null = choco.exe
        }
    }
    
    end {
        if (Test-ChocolateyConfig) {
            $Status = $True
        }
        else {
            $Status = $False
        }
        return [PSCustomObject]@{
            Config = $Config
            Reset  = $Status
        }
    }
}