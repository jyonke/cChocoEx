$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

Describe 'Get-cChocoExPackageInstall Tests' {
    BeforeAll {
        $Path = 'TestDrive:\packages.psd1'
        Set-Content -Path $Path -Value @'        
        @{
            "adobereader"                        = @{
                Name        = "adobereader"
                Ensure      = 'Present'
                AutoUpgrade = $True
                Priority    = 10
                Tags        = @("browser", "pdf")
            }
            "7zip.install"                       = @{
                Name        = "7zip.install"
                Ensure      = 'Present'
                AutoUpgrade = $True
                Priority    = 0
                Tags        = @("utility", "compression")
            }
            "notepadplusplus.install"            = @{
                Name        = "notepadplusplus.install"
                Ensure      = 'Present'
                AutoUpgrade = $True
                Priority    = 0
                Tags        = @("editor", "text")
            }
            "vlc-broad"                          = @{
                Name                      = "vlc"
                MinimumVersion            = "2.0.1"
                Ensure                    = 'Present'
                OverrideMaintenanceWindow = $True
                Ring                      = 'Broad'
                Tags                      = @("media", "player")
            }
            "vlc-preview"                        = @{
                Name        = "vlc"
                Ensure      = 'Present'
                AutoUpgrade = $True
                Ring        = 'Preview'
                Tags        = @("media", "player", "preview")
            }
            "vlc-slow"                           = @{
                Name           = "vlc"
                Ensure         = 'Present'
                MinimumVersion = "3.0.0"
                Ring           = 'Slow'
                Tags           = @("media", "player", "slow")
            }
            "vlc-fast"                           = @{
                Name                      = "vlc"
                Ensure                    = 'Present'
                MinimumVersion            = "3.0.15"
                OverrideMaintenanceWindow = $True
                Ring                      = 'Fast'
                Tags                      = @("media", "player", "fast")
            }
            "jre8"                               = @{
                Name                      = "jre8"
                Ensure                    = 'Present'
                AutoUpgrade               = $True
                OverrideMaintenanceWindow = $False
                Tags                      = @("runtime", "java")
            }
            "git.install"                        = @{
                Name        = "git.install"
                Ensure      = 'Present'
                AutoUpgrade = $True
                chocoParams = '--execution-timeout 0'
                Source      = 'https://chocolatey.org/api/v2/'
                Tags        = @("dev", "version-control")
            }
            "adobeair"                           = @{
                Name        = "adobeair"
                Ensure      = 'Present'
                AutoUpgrade = $True
                VPN         = $True
                Tags        = @("runtime", "adobe")
            }
            "chocolatey-windowsupdate.extension" = @{
                Name        = "chocolatey-windowsupdate.extension"
                Ensure      = 'Present'
                AutoUpgrade = $True
                VPN         = $False
                Tags        = @("extension", "windows")
            }
            'firefox'                            = @{
                Name    = 'firefox'
                Version = "87.0"
                Ensure  = 'Present'
                Ring    = 'broad'
                Tags    = @("browser", "web")
            }
            'firefox-esr'                        = @{
                Name        = 'firefox-esr'
                Ensure      = 'Present'
                AutoUpgrade = $True
                Ring        = 'Pilot'
                Tags        = @("browser", "web", "pilot")
            }
            'microsoft-edge'                     = @{
                Name        = 'microsoft-edge'
                Ensure      = 'Present'
                AutoUpgrade = $True
                Ring        = 'Broad'
                Tags        = @("browser", "web", "microsoft")
            }
            'winscp'                             = @{
                Name        = 'winscp'
                Ensure      = 'Present'
                AutoUpgrade = $True
                Ring        = 'Broad'
                Tags        = @("utility", "ftp")
            }
        }
'@
    }

    It 'Confirm Configuration Data File Exits' {
        $Path | Should -Exist
    }
    It 'Returns 15 Packages' {
        (Get-cChocoExPackageInstall -Path $Path | Select-Object -ExpandProperty 'Name').Count | Should -Be 15
    }
    It 'Verify Name' {
        (Get-cChocoExPackageInstall -Path $Path | Select-Object -ExpandProperty 'Name') | Should -Not -BeNullOrEmpty
    }
    It 'Verify Ensure' {
        (Get-cChocoExPackageInstall -Path $Path | Select-Object -ExpandProperty 'Ensure') | Should -Match 'Absent|Present'
    }
    It 'Verify Return Type' {
        (Get-cChocoExPackageInstall -Path $Path) | Should -BeOfType PSCustomObject
    }
    It 'Filters by Tag' {
        $result = Get-cChocoExPackageInstall -Path $Path -Tag "browser"
        $result.Count | Should -Be 4
        $result.Name | Should -Contain "adobereader"
        $result.Name | Should -Contain "firefox"
        $result.Name | Should -Contain "firefox-esr"
        $result.Name | Should -Contain "microsoft-edge"
    }
    It 'Filters by Multiple Tags' {
        $result = Get-cChocoExPackageInstall -Path $Path -Tag @("media", "adobe", "ftp")
        $result.Count | Should -Be 6
        $result.Name | Should -Contain "vlc"
        $result.Name | Should -Contain "winscp"
        $result.Name | Should -Not -Contain "git.install"
        $result.Name | Should -Contain "adobeair"
    }
    It 'Returns Empty When No Tags Match' {
        $result = Get-cChocoExPackageInstall -Path $Path -Tag "nonexistent"
        $result.Count | Should -Be 0
    }
}
