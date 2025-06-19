$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'
$ModulePath = (Join-Path $root "src\DSCResources\cChocoPackageInstall")

# Ensure clean state before importing
Get-Module -Name 'cChoco*' -ErrorAction SilentlyContinue | Remove-Module -Force

Import-Module -Name $ModulePath -Force
Import-Module -Name $Module -Force

# Create global mock functions that will be available to the Start-cChocoPackageInstall function
function global:Test-TargetResource {
    param($Name, $Ensure, $Tags)
    return $true
}
function global:Set-TargetResource {
    param($Name, $Ensure, $Tags)
}

# Dot-source specific private functions that are being mocked
#. (Join-Path $root "src\Private\Test-IsWinOS.ps1")
#. (Join-Path $root "src\Private\Test-TSEnv.ps1")
#. (Join-Path $root "src\Private\Get-VPN.ps1")
#. (Join-Path $root "src\Private\Get-PackagePriority.ps1")
#. (Join-Path $root "src\Private\Get-RingValue.ps1")
#. (Join-Path $root "src\Private\Test-PendingReboot.ps1")
#. (Join-Path $root "src\Private\New-PackageInstallNotification.ps1")
#. (Join-Path $root "src\Private\Update-PackageInstallNotification.ps1")
#. (Join-Path $root "src\Private\New-PendingUpdateNotification.ps1")

InModuleScope 'cChocoEx' {
    Describe 'Start-cChocoPackageInstall' {
        BeforeAll {
            # Mock all external dependencies
            Mock Write-Log {}
            Mock Write-Host {}
            Mock Write-Progress {}
            Mock Import-Module {}
            Mock Remove-Module {}
            
            Mock Get-cChocoExRing { return 'Broad' }
            Mock Test-IsWinOS.OOBE { return $false }
            Mock Test-TSEnv { return $false }
            Mock Get-VPN { return $false }
            Mock Get-PackagePriority { param($Configurations) return $Configurations }
            Mock Get-RingValue { param($Name) 
                switch ($Name) {
                    'Broad' { return 1 }
                    'Fast' { return 2 }
                    'Slow' { return 3 }
                    default { return 0 }
                }
            }
            Mock Test-PendingReboot { return $false }
            Mock New-PackageInstallNotification {}
            Mock Update-PackageInstallNotification {}
            Mock New-PendingUpdateNotification {}
            Mock Get-cChocoExMaintenanceWindow { 
                return @{
                    Start = '22:00'
                    End   = '06:00'
                    UTC   = $true
                }
            }
        }

        Context 'Basic Configuration Tests' {
            It 'Should process configurations without tags' {
                $config = @(
                    @{
                        Name   = 'TestPackage'
                        Ensure = 'Present'
                    }
                )

                Start-cChocoPackageInstall -Configurations $config

                Should -Invoke Write-Log -Exactly 1 -ParameterFilter { $Message -like '*Validating Chocolatey Packages are Setup*' }
            }

            It 'Should handle empty configuration' {
                $config = @()

                Start-cChocoPackageInstall -Configurations $config

                Should -Invoke Write-Log -Exactly 1 -ParameterFilter { $Message -like '*Validating Chocolatey Packages are Setup*' }
            }
        }

        Context 'Tag Filter Tests' {
            It 'Should filter configurations by include tags' {
                $config = @(
                    @{
                        Name   = 'TestPackage1'
                        Ensure = 'Present'
                        Tags   = @('Tag1', 'Tag2')
                    },
                    @{
                        Name   = 'TestPackage2'
                        Ensure = 'Present'
                        Tags   = @('Tag3')
                    }
                )

                Start-cChocoPackageInstall -Configurations $config -TagFilter @('Tag1')

                Should -Invoke Write-Log -ParameterFilter { $Message -like '*Processing Tag Filters*' }
            }

            It 'Should filter configurations by exclude tags' {
                $config = @(
                    @{
                        Name   = 'TestPackage1'
                        Ensure = 'Present'
                        Tags   = @('Tag1', 'Tag2')
                    },
                    @{
                        Name   = 'TestPackage2'
                        Ensure = 'Present'
                        Tags   = @('Tag3')
                    }
                )

                Start-cChocoPackageInstall -Configurations $config -ExcludeTagFilter @('Tag1')

                Should -Invoke Write-Log -ParameterFilter { $Message -like '*Processing Tag Filters*' }
            }
        }

        Context 'Ring Tests' {
            It 'Should handle package with higher ring requirement' {
                Mock Get-cChocoExRing { return 'Broad' }

                $config = @(
                    @{
                        Name   = 'TestPackage'
                        Ensure = 'Present'
                        Ring   = 'Fast'
                    }
                )

                Start-cChocoPackageInstall -Configurations $config

                Should -Invoke Write-Log -ParameterFilter { $Message -like '*Configuration restricted to Fast ring*' }
            }

            It 'Should process package with matching ring' {
                Mock Get-cChocoExRing { return 'Fast' }

                $config = @(
                    @{
                        Name   = 'TestPackage'
                        Ensure = 'Present'
                        Ring   = 'Fast'
                    }
                )

                Start-cChocoPackageInstall -Configurations $config

                Should -Invoke Write-Log -ParameterFilter { $Message -like '*Validating Chocolatey Packages are Setup*' }
            }
        }

        Context 'VPN Tests' {
            It 'Should handle VPN restriction when VPN is connected' {
                Mock Get-VPN { return $true }

                $config = @(
                    @{
                        Name   = 'TestPackage'
                        Ensure = 'Present'
                        VPN    = $false
                    }
                )

                Start-cChocoPackageInstall -Configurations $config

                Should -Invoke Write-Log -ParameterFilter { $Message -like '*Configuration restricted when VPN is connected*' }
            }

            It 'Should handle VPN restriction when VPN is not connected' {
                Mock Get-VPN { return $false }

                $config = @(
                    @{
                        Name   = 'TestPackage'
                        Ensure = 'Present'
                        VPN    = $true
                    }
                )

                Start-cChocoPackageInstall -Configurations $config

                Should -Invoke Write-Log -ParameterFilter { $Message -like '*Configuration restricted when VPN is not established*' }
            }
        }

        Context 'Environment Restriction Tests' {
            It 'Should handle Task Sequence environment restriction' {
                Mock Test-TSEnv { return $true }

                $config = @(
                    @{
                        Name                      = 'TestPackage'
                        Ensure                    = 'Present'
                        EnvRestriction            = 'TS'
                        OverrideMaintenanceWindow = $true
                    }
                )

                Start-cChocoPackageInstall -Configurations $config

                Should -Invoke Write-Log -ParameterFilter { $Message -like '*Task Sequence Environment detected*' }
            }

            It 'Should handle OOBE environment restriction' {
                Mock Test-IsWinOS.OOBE { return $true }

                $config = @(
                    @{
                        Name                      = 'TestPackage'
                        Ensure                    = 'Present'
                        EnvRestriction            = 'OOBE'
                        OverrideMaintenanceWindow = $true

                    }
                )

                Start-cChocoPackageInstall -Configurations $config

                Should -Invoke Write-Log -ParameterFilter { $Message -like '*OOBE Environment detected*' }
            }
        }

        Context 'Notification Tests' {
            It 'Should create notifications when updates are pending' {
                # Override the global function for this test
                function global:Test-TargetResource { return $false }
                $Global:EnableNotifications = $true
                $Global:MaintenanceWindowEnabled = $true

                $config = @(
                    @{
                        Name   = 'TestPackage'
                        Ensure = 'Present'
                    }
                )

                Start-cChocoPackageInstall -Configurations $config

                Should -Invoke New-PackageInstallNotification -Exactly 1
            }

            It 'Should create pending update notification' {
                # Override the global function for this test
                function global:Test-TargetResource { return $false }
                $Global:EnableNotifications = $true
                $Global:MaintenanceWindowEnabled = $false

                $config = @(
                    @{
                        Name   = 'TestPackage'
                        Ensure = 'Present'
                    }
                )

                Start-cChocoPackageInstall -Configurations $config

                Should -Invoke New-PendingUpdateNotification -Exactly 1
            }
        }

        Context 'Error Handling' {
            It 'Should handle Test-TargetResource failure' {
                # Override the global function for this test
                function global:Test-TargetResource { return $false }
                function global:Set-TargetResource { }

                $config = @(
                    @{
                        Name                      = 'TestPackage'
                        Ensure                    = 'Present'
                        OverrideMaintenanceWindow = $true
                    }
                )

                Start-cChocoPackageInstall -Configurations $config

                # Test that the function completed without errors
                Should -Invoke Write-Log -ParameterFilter { $Message -like '*Validating Chocolatey Packages are Setup*' }
            }
        }
    }
} 

AfterAll {
    # Clean up modules and global functions
    Get-Module -Name 'cChoco*' -ErrorAction SilentlyContinue | Remove-Module -Force
    Remove-Item -Path 'function:global:Test-TargetResource' -ErrorAction SilentlyContinue
    Remove-Item -Path 'function:global:Set-TargetResource' -ErrorAction SilentlyContinue
} 