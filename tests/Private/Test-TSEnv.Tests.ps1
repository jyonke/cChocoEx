$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

InModuleScope 'cChocoEx' {
    Describe 'Test-TSEnv' {
        BeforeEach {
            Mock Get-Process { $null }
            Mock Test-Path { $false }
            Mock Write-Verbose {}
            Mock Write-Warning {}
        }

        It 'Should return true if TSProgressUI process exists' {
            Mock Get-Process { @{ Name = 'TSProgressUI' } }
            (Test-TSEnv) | Should -Be $true
        }

        It 'Should return true if _SMSTSEnv variable exists' {
            Mock Test-Path { param($Path) if ($Path -eq 'env:_SMSTSEnv') { $true } else { $false } }
            (Test-TSEnv) | Should -Be $true
        }

        It 'Should return false if neither TSProgressUI process nor _SMSTSEnv variable exists' {
            (Test-TSEnv) | Should -Be $false
        }

        It 'Should warn and return false on error' {
            Mock Get-Process { throw 'error' }
            $result = Test-TSEnv
            $result | Should -Be $false
            Should -Invoke Write-Warning -Exactly 1
        }
    }
} 