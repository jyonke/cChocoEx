$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

InModuleScope 'cChocoEx' {
    Describe 'Ring Filter Tests' {
        BeforeAll {
            $ConfigImport = @{
                "adobereader"                        = @{
                    Name        = "adobereader"
                    Ensure      = 'Present'
                    AutoUpgrade = $True
                    Priority    = 10
                }
                "7zip.install"                       = @{
                    Name        = "7zip.install"
                    Ensure      = 'Present'
                    AutoUpgrade = $True
                    Priority    = 0
                }
                "notepadplusplus.install"            = @{
                    Name        = "notepadplusplus.install"
                    Ensure      = 'Present'
                    AutoUpgrade = $True
                    Priority    = 0
                }
                "vlc-broad"                          = @{
                    Name                      = "vlc"
                    MinimumVersion            = "2.0.1"
                    Ensure                    = 'Present'
                    OverrideMaintenanceWindow = $True
                    Ring                      = 'Broad'
                }
                "vlc-preview"                        = @{
                    Name        = "vlc"
                    Ensure      = 'Present'
                    AutoUpgrade = $True
                    Ring        = 'Preview'
                }
                "vlc-slow"                           = @{
                    Name           = "vlc"
                    Ensure         = 'Present'
                    MinimumVersion = "3.0.0"
                    Ring           = 'Slow'
                }
                "vlc-fast"                           = @{
                    Name                      = "vlc"
                    Ensure                    = 'Present'
                    MinimumVersion            = "3.0.15"
                    OverrideMaintenanceWindow = $True
                    Ring                      = 'Fast'
                }
                "jre8"                               = @{
                    Name                      = "jre8"
                    Ensure                    = 'Present'
                    AutoUpgrade               = $True
                    OverrideMaintenanceWindow = $False
                }
                "git.install"                        = @{
                    Name        = "git.install"
                    Ensure      = 'Present'
                    AutoUpgrade = $True
                    chocoParams = '--execution-timeout 0'
                    Source      = 'https://chocolatey.org/api/v2/'
                }
                "adobeair"                           = @{
                    Name        = "adobeair"
                    Ensure      = 'Present'
                    AutoUpgrade = $True
                    VPN         = $True
                }
                "chocolatey-windowsupdate.extension" = @{
                    Name        = "chocolatey-windowsupdate.extension"
                    Ensure      = 'Present'
                    AutoUpgrade = $True
                    VPN         = $False
                }
                'firefox'                            = @{
                    Name    = 'firefox'
                    Version = "87.0"
                    Ensure  = 'Present'
                    Ring    = 'broad'
                }
                'firefox-latest'                     = @{
                    Name        = 'firefox'
                    Ensure      = 'Present'
                    AutoUpgrade = $True
                    Ring        = 'Pilot'
                }
                'microsoft-edge'                     = @{
                    Name        = 'microsoft-edge'
                    Ensure      = 'Present'
                    AutoUpgrade = $True
                    Ring        = 'Preview'
                }
                'winscp'                             = @{
                    Name        = 'winscp'
                    Ensure      = 'Present'
                    AutoUpgrade = $True
                    Ring        = 'Fast'
                }
            }
            [array]$Configurations = @()
            $Configurations += $ConfigImport | ForEach-Object { $_.Keys | ForEach-Object { $ConfigImport.$_ } }
        }

        It 'Confirm Configuration Data Exits' {
            $Configurations | Should -Not -BeNullOrEmpty
        }
        It 'Returns Broad Ring Packages' {
            Mock Get-cChocoExRing { return 'Broad' }
            Filter-PackageRing -Configurations $Configurations | Should -HaveCount 9
        }
        It 'Returns Fast Ring Packages' {
            Mock Get-cChocoExRing { return 'Fast' }
            Filter-PackageRing -Configurations $Configurations | Should -HaveCount 10
        }
        It 'Returns Preview Ring Packages' {
            Mock Get-cChocoExRing { return 'Preview' }
            Filter-PackageRing -Configurations $Configurations | Should -HaveCount 11
        }
    }
}
