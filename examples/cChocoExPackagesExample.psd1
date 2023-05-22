@{
    "7zip.install-Broad"                       = @{
        Name        = '7zip.install'
        Ensure      = 'Present'
        AutoUpgrade = $true
        Ring        = 'Broad'
        Priority    = 0
    }
    "adobeair-Broad"                           = @{
        Name        = 'adobeair'
        Ensure      = 'Present'
        AutoUpgrade = $true
        VPN         = $true
        Ring        = 'Broad'
    }
    "adobereader-Broad"                        = @{
        Name        = 'adobereader'
        Ensure      = 'Present'
        AutoUpgrade = $true
        Ring        = 'Broad'
        Priority    = 10
    }
    "chocolatey-windowsupdate.extension-Broad" = @{
        Name        = 'chocolatey-windowsupdate.extension'
        Ensure      = 'Present'
        AutoUpgrade = $true
        VPN         = $false
        Ring        = 'Broad'
    }
    "firefox-Pilot"                            = @{
        Name        = 'firefox'
        Ensure      = 'Present'
        AutoUpgrade = $true
        Ring        = 'Pilot'
    }
    "firefox-broad"                            = @{
        Name    = 'firefox'
        Version = '87.0'
        Ensure  = 'Present'
        Ring    = 'broad'
    }
    "git.install-Broad"                        = @{
        Name        = 'git.install'
        Source      = 'https://chocolatey.org/api/v2/'
        Ensure      = 'Present'
        AutoUpgrade = $true
        ChocoParams = '--execution-timeout 0'
        Ring        = 'Broad'
    }
    "jre8-Broad"                               = @{
        Name        = 'jre8'
        Ensure      = 'Present'
        AutoUpgrade = $true
        Ring        = 'Broad'
    }
    "microsoft-edge-Broad"                     = @{
        Name        = 'microsoft-edge'
        Ensure      = 'Present'
        AutoUpgrade = $true
        Ring        = 'Broad'
    }
    "notepadplusplus.install-Broad"            = @{
        Name        = 'notepadplusplus.install'
        Ensure      = 'Present'
        AutoUpgrade = $true
        Ring        = 'Broad'
        Priority    = 0
    }
    "office365business-Broad"                  = @{
        Name           = 'office365business'
        Ensure         = 'Present'
        Ring           = 'Broad'
        EnvRestriction = @('TSEnv', 'OOBE')
    }
    "vlc-Fast"                                 = @{
        Name                      = 'vlc'
        MinimumVersion            = '3.0.15'
        Ensure                    = 'Present'
        OverrideMaintenanceWindow = $true
        Ring                      = 'Fast'
    }
    "vlc-Broad"                                = @{
        Name                      = 'vlc'
        MinimumVersion            = '2.0.1'
        Ensure                    = 'Present'
        OverrideMaintenanceWindow = $true
        Ring                      = 'Broad'
    }
    "winscp-Broad"                             = @{
        Name        = 'winscp'
        Ensure      = 'Present'
        AutoUpgrade = $true
        Ring        = 'Broad'
    }
}

