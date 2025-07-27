$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'
$ModulePath = (Join-Path $root "src\DSCResources\cChocoConfig")

# Ensure clean state before importing
Get-Module -Name 'cChoco*' -ErrorAction SilentlyContinue | Remove-Module -Force

Import-Module -Name $ModulePath -Force
Import-Module -Name $Module -Force

# Create global mock functions that will be available to the Start-cChocoConfig function
function global:Test-TargetResource {
    param($Name, $Ensure, $Tags)
    return $true
}
function global:Set-TargetResource {
    param($Name, $Ensure, $Tags)
}

InModuleScope 'cChocoEx' {
    Describe 'Start-cChocoConfig' {
        BeforeAll {
            # Mock all external dependencies
            Mock Write-Log {}
            Mock Write-Host {}
            Mock Write-EventLog {}
            Mock Import-Module {}
            Mock Remove-Module {}
            
            Mock Get-MaintenanceWindow { 
                return @{
                    MaintenanceWindowEnabled = $true
                    MaintenanceWindowActive  = $true
                }
            }
            Mock Test-TSEnv { return $false }
            Mock Test-IsWinPe { return $false }
            Mock Test-IsWinOS { return $false }
            Mock Test-IsWinSE { return $false }
        }

        Context 'Basic Configuration Tests' {

            It 'Should process configurations without tags' {
                $config = @{
                    'Config1' = @{
                        ConfigName = 'TestConfig'
                        Ensure     = 'Present'
                        Value      = 'TestValue'
                    }
                }

                Start-cChocoConfig -ConfigImport $config

                Should -Invoke Write-Log -Exactly 1 -ParameterFilter { $Message -like '*Validating Chocolatey Configurations are Setup*' }
            }

            It 'Should handle empty configuration' {
                $config = @{}

                Start-cChocoConfig -ConfigImport $config

                Should -Invoke Write-Log -Exactly 1 -ParameterFilter { $Message -like '*Validating Chocolatey Configurations are Setup*' }
            }
        }

        Context 'Tag Filter Tests' {
            It 'Should filter configurations by include tags' {
                $config = @{
                    'Config1' = @{
                        ConfigName = 'TestConfig1'
                        Ensure     = 'Present'
                        Value      = 'TestValue1'
                        Tags       = @('Tag1', 'Tag2')
                    }
                    'Config2' = @{
                        ConfigName = 'TestConfig2'
                        Ensure     = 'Present'
                        Value      = 'TestValue2'
                        Tags       = @('Tag3')
                    }
                }

                Start-cChocoConfig -ConfigImport $config -TagFilter @('Tag1')

                # Test that the function completed without errors
                Should -Invoke Write-Log -ParameterFilter { $Message -like '*Processing Tag Filters*' }
            }

            It 'Should filter configurations by exclude tags' {
                $config = @{
                    'Config1' = @{
                        ConfigName = 'TestConfig1'
                        Ensure     = 'Present'
                        Value      = 'TestValue1'
                        Tags       = @('Tag1', 'Tag2')
                    }
                    'Config2' = @{
                        ConfigName = 'TestConfig2'
                        Ensure     = 'Present'
                        Value      = 'TestValue2'
                        Tags       = @('Tag3')
                    }
                }

                Start-cChocoConfig -ConfigImport $config -ExcludeTagFilter @('Tag1')

                # Test that the function completed without errors
                Should -Invoke Write-Log -ParameterFilter { $Message -like '*Processing Tag Filters*' }
            }
        }

        Context 'Maintenance Window Tests' {
            It 'Should handle maintenance window configuration' {
                $config = @{
                    'MaintenanceWindow' = @{
                        ConfigName        = 'MaintenanceWindow'
                        Start             = '22:00'
                        End               = '06:00'
                        EffectiveDateTime = (Get-Date)
                        UTC               = $true
                    }
                }

                Start-cChocoConfig -ConfigImport $config

                Should -Invoke Get-MaintenanceWindow -Exactly 1
                Should -Invoke Write-EventLog -Exactly 2
            }

            It 'Should override maintenance window in Task Sequence environment' {
                Mock Test-TSEnv { return $true }

                $config = @{
                    'MaintenanceWindow' = @{
                        ConfigName        = 'MaintenanceWindow'
                        Start             = '22:00'
                        End               = '06:00'
                        EffectiveDateTime = (Get-Date)
                        UTC               = $true
                    }
                }

                Start-cChocoConfig -ConfigImport $config

                Should -Invoke Write-Log -ParameterFilter { $Message -like '*Task Sequence Environment Detected*' }
                Should -Not -Invoke Get-MaintenanceWindow
            }

            It 'Should override maintenance window in WinPE environment' {
                Mock Test-IsWinPe { return $true }

                $config = @{
                    'MaintenanceWindow' = @{
                        ConfigName        = 'MaintenanceWindow'
                        Start             = '22:00'
                        End               = '06:00'
                        EffectiveDateTime = (Get-Date)
                        UTC               = $true
                    }
                }

                Start-cChocoConfig -ConfigImport $config

                Should -Invoke Write-Log -ParameterFilter { $Message -like '*WinPE Environment Detected*' }
                Should -Not -Invoke Get-MaintenanceWindow
            }
        }

        Context 'Environment Restriction Tests' {
            It 'Should override maintenance window in WinOS OOBE environment' {
                Mock Test-IsWinOS.OOBE { return $true }

                $config = @{
                    'MaintenanceWindow' = @{
                        ConfigName        = 'MaintenanceWindow'
                        Start             = '22:00'
                        End               = '06:00'
                        EffectiveDateTime = (Get-Date)
                        UTC               = $true
                    }
                }

                Start-cChocoConfig -ConfigImport $config

                Should -Invoke Write-Log -ParameterFilter { $Message -like '*WinOS OOBE Environment Detected*' }
                Should -Not -Invoke Get-MaintenanceWindow
            }

            It 'Should override maintenance window in WinSE OOBE environment' {
                Mock Test-IsWinSE { return $true }

                $config = @{
                    'MaintenanceWindow' = @{
                        ConfigName        = 'MaintenanceWindow'
                        Start             = '22:00'
                        End               = '06:00'
                        EffectiveDateTime = (Get-Date)
                        UTC               = $true
                    }
                }

                Start-cChocoConfig -ConfigImport $config

                Should -Invoke Write-Log -ParameterFilter { $Message -like '*WinSE OOBE Environment Detected*' }
                Should -Not -Invoke Get-MaintenanceWindow
            }
        }

        Context 'Maintenance Window Edge Cases' {
            It 'Should log a warning when no Maintenance Window is defined' {
                $config = @{
                    'Config1' = @{
                        ConfigName = 'TestConfig'
                        Ensure     = 'Present'
                        Value      = 'TestValue'
                    }
                }

                Start-cChocoConfig -ConfigImport $config

                Should -Invoke Write-Log -ParameterFilter { $Message -like '*No Defined Maintenance Window*' }
            }
        }

        Context 'Property Handling' {
            It 'Should remove Tags property from configuration objects' {
                $config = @{
                    'Config1' = @{
                        ConfigName = 'TestConfig'
                        Ensure     = 'Present'
                        Value      = 'TestValue'
                        Tags       = @('Tag1')
                    }
                }

                $global:TagsRemoved = $false
                Mock Test-TargetResource {
                    param($ConfigName, $Ensure, $Value)
                    if (-not $PSBoundParameters.ContainsKey('Tags')) {
                        $global:TagsRemoved = $true
                    }
                    return $true
                }

                Start-cChocoConfig -ConfigImport $config

                $global:TagsRemoved | Should -Be $true
            }
        }

        Context 'Status Logging' {
            It 'Should log all config object properties during status reporting' {
                $config = @{
                    'Config1' = @{
                        ConfigName = 'TestConfig'
                        Ensure     = 'Present'
                        Value      = 'TestValue'
                    }
                }

                Mock Write-Log {}
                Mock Write-Host {}

                Start-cChocoConfig -ConfigImport $config

                Should -Invoke Write-Log -ParameterFilter { $Message -like '*ConfigName: TestConfig*' }
                Should -Invoke Write-Log -ParameterFilter { $Message -like '*DSC: True*' }
                Should -Invoke Write-Log -ParameterFilter { $Message -like '*Ensure: Present*' }
                Should -Invoke Write-Log -ParameterFilter { $Message -like '*Value: TestValue*' }
            }
        }

        Context 'Error Handling' {
            It 'Should handle Test-TargetResource failure' {
                # Override the global function for this test
                function global:Test-TargetResource { return $false }
                function global:Set-TargetResource { }

                $config = @{
                    'Config1' = @{
                        ConfigName = 'TestConfig'
                        Ensure     = 'Present'
                        Value      = 'TestValue'
                    }
                }

                Start-cChocoConfig -ConfigImport $config

                # Test that the function completed without errors
                Should -Invoke Write-Log -ParameterFilter { $Message -like '*Validating Chocolatey Configurations are Setup*' }
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
