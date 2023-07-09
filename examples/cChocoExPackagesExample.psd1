@{
    "7zip.install-Broad"                       = @{
        Name        = '7zip.install'
        Ensure      = 'Present'
        AutoUpgrade = $true
        Ring        = 'Broad'
        Priority    = 0
    }
    "chocolatey-windowsupdate.extension-Broad" = @{
        Name        = 'chocolatey-windowsupdate.extension'
        Ensure      = 'Present'
        AutoUpgrade = $true
        VPN         = $false
        Ring        = 'Broad'
    }
    "firefox-Pilot"                            = @{
        Name           = 'firefox'
        Ensure         = 'Present'
        AutoUpgrade    = $true
        Ring           = 'Pilot'
        EnvRestriction = @('TSEnv', 'OOBE')
    }
    "firefox-broad"                            = @{
        Name           = 'firefox'
        Version        = '115.0.1'
        Ensure         = 'Present'
        Ring           = 'Broad'
        EnvRestriction = @('TSEnv', 'OOBE')
    }
    "git.install-Broad"                        = @{
        Name        = 'git.install'
        Source      = 'https://chocolatey.org/api/v2/'
        Ensure      = 'Present'
        AutoUpgrade = $true
        ChocoParams = '--execution-timeout 0'
        Ring        = 'Broad'
    }
    "notepadplusplus.install-Broad"            = @{
        Name        = 'notepadplusplus.install'
        Ensure      = 'Present'
        AutoUpgrade = $true
        Ring        = 'Broad'
        Priority    = 0
    }
    "winscp-Broad"                             = @{
        Name        = 'winscp'
        Ensure      = 'Present'
        AutoUpgrade = $true
        Ring        = 'Broad'
    }
}
