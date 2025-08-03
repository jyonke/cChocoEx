$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -split 'tests' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

InModuleScope 'cChocoEx' {
    Describe 'Test-IsChocoActive' {
        Context 'When choco process is running' {
            BeforeEach {
                # Mock Get-Process to return a choco process
                Mock Get-Process {
                    param($Name, [System.Management.Automation.ActionPreference]$ErrorAction)
                    if ($Name -eq 'choco') {
                        return New-Object -TypeName PSObject -Property @{ Name = 'choco' }
                    }
                }
            }

            It 'Should return $true when choco process is running' {
                $result = Test-IsChocoActive
                $result | Should -Be $true
            }
        }

        Context 'When choco process is not running' {
            BeforeEach {
                # Mock Get-Process to return nothing (simulating no choco process)
                Mock Get-Process {
                    param($Name, [System.Management.Automation.ActionPreference]$ErrorAction)
                    if ($Name -eq 'choco') {
                        # Simulate SilentlyContinue behavior by returning nothing
                        return $null
                    }
                }
            }

            It 'Should return $false when choco process is not running' {
                $result = Test-IsChocoActive
                $result | Should -Be $false
            }
        }
    }
}
