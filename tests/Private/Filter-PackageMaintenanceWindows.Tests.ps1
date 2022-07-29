$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

InModuleScope 'cChocoEx' {
    Describe 'Maintenance Window Filter Tests' {
        BeforeAll {
            $ConfigImport = @{
                "adobereader"             = @{
                    Name                      = "adobereader"
                    Ensure                    = 'Present'
                    AutoUpgrade               = $True
                    Priority                  = 10
                    OverRideMaintenanceWindow = $True
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
                    OverrideMaintenanceWindow = $false
                }
            }
            [array]$Configurations = @()
            $Configurations += $ConfigImport | ForEach-Object { $_.Keys | ForEach-Object { $ConfigImport.$_ } }
        }

        It 'Confirm Configuration Data Exits' {
            $Configurations | Should -Not -BeNullOrEmpty
        }
        It 'Returns Maintenance Window Enabled Packages Count' {
            $Global:MaintenanceWindowEnabled = $true
            $Global:MaintenanceWindowActive = $true
            Filter-PackageMaintenanceWindow -Configurations $Configurations | Should -HaveCount 4
        }
        It 'Returns Maintenance Window Disabled Packages Count' {
            $Global:MaintenanceWindowEnabled = $false
            $Global:MaintenanceWindowActive = $false
            Filter-PackageMaintenanceWindow -Configurations $Configurations | Should -HaveCount 1
        }
        It 'Returns Maintenance Windows Enabled Package' {
            $Global:MaintenanceWindowEnabled = $true
            $Global:MaintenanceWindowActive = $true
            Filter-PackageMaintenanceWindow -Configurations $Configurations | Where-Object { $_.Name -eq 'vlc' } | Should -Not -BeNullOrEmpty
        }
        It 'Returns Maintenance Windows Disabled Package' {
            $Global:MaintenanceWindowEnabled = $false
            $Global:MaintenanceWindowActive = $false
            Filter-PackageMaintenanceWindow -Configurations $Configurations | Where-Object { $_.Name -eq 'adobereader' } | Should -Not -BeNullOrEmpty
        }
    }
}
