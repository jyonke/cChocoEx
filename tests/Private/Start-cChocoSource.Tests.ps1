$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'
$ModulePath = (Join-Path $root "src\DSCResources\cChocoSource")

# Ensure clean state before importing
Get-Module -Name 'cChoco*' -ErrorAction SilentlyContinue | Remove-Module -Force

Import-Module -Name $ModulePath -Force
Import-Module -Name $Module -Force

# Create global mock functions that will be available to the Start-cChocoSource function
function global:Test-TargetResource {
    param($Name, $Ensure, $Tags)
    return $true
}
function global:Set-TargetResource {
    param($Name, $Ensure, $Tags)
}

# Dot-source specific private functions that are being mocked
#. (Join-Path $root "src\Private\New-PSCredential.ps1")
#. (Join-Path $root "src\Private\Get-VPN.ps1")

InModuleScope 'cChocoEx' {
    Describe 'Start-cChocoSource' {
        BeforeAll {
            # Mock all external dependencies
            Mock Write-Log {}
            Mock Write-Host {}
            Mock Import-Module {}
            Mock Remove-Module {}
            
            Mock Get-VPN { return $false }
            Mock Test-Path { return $true }
            Mock New-PSCredential { 
                param($User, $Password, $KeyFile)
                $securePassword = ConvertTo-SecureString -String "MockPassword" -AsPlainText -Force
                return New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $securePassword
            }
        }

        Context 'Basic Configuration Tests' {
            It 'Should process configurations without tags' {
                $config = @{
                    'Source1' = @{
                        Name   = 'TestSource'
                        Source = 'https://test.source'
                        Ensure = 'Present'
                    }
                }

                Start-cChocoSource -ConfigImport $config

                Should -Invoke Write-Log -Exactly 1 -ParameterFilter { $Message -like '*Validating Chocolatey Sources are Setup*' }
            }

            It 'Should handle empty configuration' {
                $config = @{}

                Start-cChocoSource -ConfigImport $config

                Should -Invoke Write-Log -Exactly 1 -ParameterFilter { $Message -like '*Validating Chocolatey Sources are Setup*' }
            }
        }

        Context 'Tag Filter Tests' {
            It 'Should filter configurations by include tags' {
                $config = @{
                    'Source1' = @{
                        Name   = 'TestSource1'
                        Source = 'https://test.source1'
                        Ensure = 'Present'
                        Tags   = @('Tag1', 'Tag2')
                    }
                    'Source2' = @{
                        Name   = 'TestSource2'
                        Source = 'https://test.source2'
                        Ensure = 'Present'
                        Tags   = @('Tag3')
                    }
                }

                Start-cChocoSource -ConfigImport $config -TagFilter @('Tag1')

                # Test that the function completed without errors
                Should -Invoke Write-Log -ParameterFilter { $Message -like '*Processing Tag Filters*' }
            }

            It 'Should filter configurations by exclude tags' {
                $config = @{
                    'Source1' = @{
                        Name   = 'TestSource1'
                        Source = 'https://test.source1'
                        Ensure = 'Present'
                        Tags   = @('Tag1', 'Tag2')
                    }
                    'Source2' = @{
                        Name   = 'TestSource2'
                        Source = 'https://test.source2'
                        Ensure = 'Present'
                        Tags   = @('Tag3')
                    }
                }

                Start-cChocoSource -ConfigImport $config -ExcludeTagFilter @('Tag1')

                # Test that the function completed without errors
                Should -Invoke Write-Log -ParameterFilter { $Message -like '*Processing Tag Filters*' }
            }
        }

        Context 'VPN Restriction Tests' {
            It 'Should handle VPN restriction when VPN is connected' {
                Mock Get-VPN { return $true }

                $config = @{
                    'Source1' = @{
                        Name   = 'TestSource'
                        Source = 'https://test.source'
                        Ensure = 'Present'
                        VPN    = $false
                    }
                }

                Start-cChocoSource -ConfigImport $config

                Should -Invoke Write-Log -ParameterFilter { $Message -like '*Configuration restricted when a VPN adapter is found*' }
            }

            It 'Should handle VPN restriction when VPN is not connected' {
                Mock Get-VPN { return $false }

                $config = @{
                    'Source1' = @{
                        Name   = 'TestSource'
                        Source = 'https://test.source'
                        Ensure = 'Present'
                        VPN    = $true
                    }
                }

                Start-cChocoSource -ConfigImport $config

                Should -Invoke Write-Log -ParameterFilter { $Message -like '*Configuration restricted when VPN adapter is not found*' }
            }
        }

        Context 'Credential Tests' {
            It 'Should handle credential configuration' {
                $keyContent = @'
                253
157
0
45
86
200
195
13
241
237
200
92
101
96
225
154
27
215
10
96
136
139
83
178
73
131
13
31
96
98
39
214
'@
                $keyContent | Out-File -FilePath 'TestDrive:\AES.key'
                $config = @{
                    'Source1' = @{
                        Name     = 'TestSource'
                        Source   = 'https://test.source'
                        Ensure   = 'Present'
                        User     = 'testuser'
                        Password = '76492d1116743f0423413b16050a5345MgB8AFYAbgBIAFYAQgBVAFEAWQB1AGsALwAwADgAegB6AEgAdgBIAHcAVABtAFEAPQA9AHwANgBlADIAMAAwAGMANAAzADQANwA3AGEAMAAzAGIAYwBhADUAMwBiAGEAMABlADYAYgBmADQAYwAwADQAYwA3AGMANgA1AGEAMgBjAGUANQA4AGQAMAA2ADkANAAxADQAYQA3AGMAYwA3ADQAYQBkAGMANQBiADMAYQAxADgAYQA='
                        KeyFile  = 'TestDrive:\AES.key'
                    }
                }

                Start-cChocoSource -ConfigImport $config

                Should -Invoke New-PSCredential -Exactly 1 
            }

            It 'Should handle missing keyfile' {
                Mock Test-Path { return $false }

                $config = @{
                    'Source1' = @{
                        Name     = 'TestSource'
                        Source   = 'https://test.source'
                        Ensure   = 'Present'
                        User     = 'testuser'
                        Password = 'testpass'
                        KeyFile  = 'C:\test\key.pfx'
                    }
                }

                Start-cChocoSource -ConfigImport $config

                Should -Invoke Write-Log -ParameterFilter { $Message -like '*Keyfile not accessible*' }
                Should -Not -Invoke New-PSCredential
            }

            It 'Should handle credential creation failure' {
                Mock New-PSCredential { throw "Credential creation failed" }

                $config = @{
                    'Source1' = @{
                        Name     = 'TestSource'
                        Source   = 'https://test.source'
                        Ensure   = 'Present'
                        User     = 'testuser'
                        Password = 'testpass'
                        KeyFile  = 'C:\test\key.pfx'
                    }
                }

                Start-cChocoSource -ConfigImport $config

                Should -Invoke Write-Log -ParameterFilter { $Message -like '*Can not create PSCredential*' }
            }
        }

        Context 'Error Handling' {
            It 'Should handle Test-TargetResource failure' {
                # Override the global function for this test
                function global:Test-TargetResource { return $false }
                function global:Set-TargetResource { }

                $config = @{
                    'Source1' = @{
                        Name   = 'TestSource'
                        Source = 'https://test.source'
                        Ensure = 'Present'
                    }
                }

                Start-cChocoSource -ConfigImport $config

                # Test that the function completed without errors
                Should -Invoke Write-Log -ParameterFilter { $Message -like '*Validating Chocolatey Sources are Setup*' }
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