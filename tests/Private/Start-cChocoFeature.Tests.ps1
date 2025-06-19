$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'
$ModulePath = (Join-Path $root "src\DSCResources\cChocoFeature")

# Ensure clean state before importing
Get-Module -Name 'cChoco*' -ErrorAction SilentlyContinue | Remove-Module -Force

Import-Module -Name $ModulePath -Force
Import-Module -Name $Module -Force

# Create global mock functions that will be available to the Start-cChocoFeature function
# Define these after module imports to ensure they're not overwritten
function global:Test-TargetResource { 
    param($FeatureName, $Ensure, $Tags)
    return $true 
}
function global:Set-TargetResource { 
    param($FeatureName, $Ensure, $Tags)
}

InModuleScope 'cChocoEx' {
    Describe 'Start-cChocoFeature' {
        BeforeAll {
            # Mock all external dependencies
            Mock Write-Log {}
            Mock Write-Host {}
            Mock Import-Module {}
            Mock Remove-Module {}
        }

        BeforeEach {
            # Ensure global functions are available for each test
            function global:Test-TargetResource { 
                param($FeatureName, $Ensure, $Tags)
                return $true 
            }
            function global:Set-TargetResource { 
                param($FeatureName, $Ensure, $Tags)
            }
        }

        Context 'Basic Configuration Tests' {
            It 'Should process configurations without tags' {
                $config = @{
                    'Feature1' = @{
                        FeatureName = 'TestFeature'
                        Ensure      = 'Present'
                    }
                }

                Start-cChocoFeature -ConfigImport $config

                Should -Invoke Write-Log -Exactly 1 -ParameterFilter { $Message -like '*Validating Chocolatey Configurations are Setup*' }
            }

            It 'Should handle empty configuration' {
                $config = @{}

                Start-cChocoFeature -ConfigImport $config

                Should -Invoke Write-Log -Exactly 1 -ParameterFilter { $Message -like '*Validating Chocolatey Configurations are Setup*' }
            }
        }

        Context 'Tag Filter Tests' {
            It 'Should filter configurations by include tags' {
                $config = @{
                    'Feature1' = @{
                        FeatureName = 'TestFeature1'
                        Ensure      = 'Present'
                        Tags        = @('Tag1', 'Tag2')
                    }
                    'Feature2' = @{
                        FeatureName = 'TestFeature2'
                        Ensure      = 'Present'
                        Tags        = @('Tag3')
                    }
                }

                Start-cChocoFeature -ConfigImport $config -TagFilter @('Tag1')

                # Test that the function completed without errors
                Should -Invoke Write-Log -ParameterFilter { $Message -like '*Processing Tag Filters*' }
            }

            It 'Should filter configurations by exclude tags' {
                $config = @{
                    'Feature1' = @{
                        FeatureName = 'TestFeature1'
                        Ensure      = 'Present'
                        Tags        = @('Tag1', 'Tag2')
                    }
                    'Feature2' = @{
                        FeatureName = 'TestFeature2'
                        Ensure      = 'Present'
                        Tags        = @('Tag3')
                    }
                }

                Start-cChocoFeature -ConfigImport $config -ExcludeTagFilter @('Tag1')

                # Test that the function completed without errors
                Should -Invoke Write-Log -ParameterFilter { $Message -like '*Processing Tag Filters*' }
            }
        }

        Context 'Error Handling' {
            It 'Should handle Test-TargetResource failure' {
                # Override the global function for this test
                function global:Test-TargetResource { 
                    param($FeatureName, $Ensure, $Tags)
                    return $false 
                }
                function global:Set-TargetResource { 
                    param($FeatureName, $Ensure, $Tags)
                }

                $config = @{
                    'Feature1' = @{
                        FeatureName = 'TestFeature'
                        Ensure      = 'Present'
                    }
                }

                Start-cChocoFeature -ConfigImport $config

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