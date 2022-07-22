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
        Ring        = 'Broad'
    }
    'winscp'                             = @{
        Name        = 'winscp'
        Ensure      = 'Present'
        AutoUpgrade = $True
        Ring        = 'Broad'
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
}