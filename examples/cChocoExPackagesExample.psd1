@{
    "7zip.install-Broad"                       = @{
        Name        = '7zip.install'
        Ensure      = 'Present'
        AutoUpgrade = $true
        Ring        = 'Broad'
        Priority    = 0
        Tags        = @('compression', 'utility')
    }
    "chocolatey-windowsupdate.extension-Broad" = @{
        Name        = 'chocolatey-windowsupdate.extension'
        Ensure      = 'Present'
        AutoUpgrade = $true
        VPN         = $false
        Ring        = 'Broad'
        Tags        = @('windows', 'update', 'extension')
    }
    "firefox-Pilot"                            = @{
        Name           = 'firefox'
        Ensure         = 'Present'
        AutoUpgrade    = $true
        Ring           = 'Pilot'
        EnvRestriction = @('TSEnv', 'OOBE')
        Tags           = @('browser', 'web')
    }
    "firefox-broad"                            = @{
        Name           = 'firefox'
        Version        = '115.0.1'
        Ensure         = 'Present'
        Ring           = 'Broad'
        EnvRestriction = @('TSEnv', 'OOBE')
        Tags           = @('browser', 'web', 'stable')
    }
    "git.install-Broad"                        = @{
        Name        = 'git.install'
        Source      = 'https://chocolatey.org/api/v2/'
        Ensure      = 'Present'
        AutoUpgrade = $true
        ChocoParams = '--execution-timeout 0'
        Ring        = 'Broad'
        Tags        = @('development', 'version-control')
    }
    "notepadplusplus.install-Broad"            = @{
        Name        = 'notepadplusplus.install'
        Ensure      = 'Present'
        AutoUpgrade = $true
        Ring        = 'Broad'
        Priority    = 0
        Tags        = @('editor', 'text')
    }
    "winscp-Broad"                             = @{
        Name        = 'winscp'
        Ensure      = 'Present'
        AutoUpgrade = $true
        Ring        = 'Broad'
        Tags        = @('ftp', 'sftp', 'transfer')
    }
}
