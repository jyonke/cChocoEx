$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

InModuleScope 'cChocoEx' {
    Describe 'VPN Filter Tests' {
        BeforeAll {
            $ConfigImport = @{
                "adobereader"             = @{
                    Name        = "adobereader"
                    Ensure      = 'Present'
                    AutoUpgrade = $True
                    Priority    = 10
                    VPN         = $True
                }
                "7zip.install"            = @{
                    Name        = "7zip.install"
                    Ensure      = 'Present'
                    AutoUpgrade = $True
                    Priority    = 0
                    VPN         = $false
                }
                "notepadplusplus.install" = @{
                    Name        = "notepadplusplus.install"
                    Ensure      = 'Present'
                    AutoUpgrade = $True
                    Priority    = 0
                }
                "vlc"                     = @{
                    Name                      = "vlc"
                    MinimumVersion            = "2.0.1"
                    Ensure                    = 'Present'
                    OverrideMaintenanceWindow = $True
                }
            }
            [array]$Configurations = @()
            $Configurations += $ConfigImport | ForEach-Object { $_.Keys | ForEach-Object { $ConfigImport.$_ } }
        }

        It 'Confirm Configuration Data Exits' {
            $Configurations | Should -Not -BeNullOrEmpty
        }
        It 'Returns VPN Required Packages Count' {
            Mock Get-VPN { return $true }
            Filter-PackageVPN -Configurations $Configurations | Should -HaveCount 3
        }
        It 'Returns VPN Restricted Packages Count' {
            Mock Get-VPN { return $false }
            Filter-PackageVPN -Configurations $Configurations | Should -HaveCount 3
        }
        It 'Returns VPN Restricted Package' {
            Mock Get-VPN { return $false }
            Filter-PackageVPN -Configurations $Configurations | Where-Object { $_.Name -eq '7zip.install' } | Should -Not -BeNullOrEmpty
        }
        It 'Returns VPN Required Package' {
            Mock Get-VPN { return $true }
            Filter-PackageVPN -Configurations $Configurations | Where-Object { $_.Name -eq 'adobereader' } | Should -Not -BeNullOrEmpty
        }
    }
}
