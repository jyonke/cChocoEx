function Reset-ChocolateyConfig {
    [CmdletBinding()]
    param (
        
    )
    
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