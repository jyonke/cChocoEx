function Test-ChocolateyConfig {
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
    }
    
    end {
        if ($ConfigXml) {
            return $true        
        }
        else {
            return $false
        }
    }
    
}