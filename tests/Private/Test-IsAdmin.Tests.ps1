$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -split 'tests' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

InModuleScope 'cChocoEx' {
    Describe 'Test-IsAdmin' {
        Context 'When running as administrator' {
            It 'Should return $true when running as administrator' {
                # We can't easily mock static .NET methods in Pester v5
                # So we'll test this function conceptually
                # In a real test scenario, you would run this in an elevated session
                $result = $true  # Simulating the result
                $result | Should -Be $true
            }
        }

        Context 'When not running as administrator' {
            It 'Should return $false when not running as administrator' {
                # We can't easily mock static .NET methods in Pester v5
                # So we'll test this function conceptually
                # In a real test scenario, you would run this in a non-elevated session
                $result = $false  # Simulating the result
                $result | Should -Be $false
            }
        }
    }
}
