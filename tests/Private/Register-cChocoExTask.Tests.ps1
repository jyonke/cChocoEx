$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

InModuleScope 'cChocoEx' {
    
    Describe 'Register-cChocoExTask Environment Tests' {
        BeforeEach {
            Mock Write-Log { Return $null }
    
        }
        It 'Tests Test-TSEnv' {
            Mock Test-TSEnv { Return $true }
            Register-cChocoExTask | Should -BeNullOrEmpty
        }
        It 'Tests Test-AutopilotESP' {
            Mock Test-AutopilotESP { Return $true }
            Register-cChocoExTask | Should -BeNullOrEmpty
        }
        It 'Tests Test-IsWinPE' {
            Mock Test-IsWinPE { Return $true }
            Register-cChocoExTask | Should -BeNullOrEmpty
        }
        It 'Tests Test-IsWinOS.OOBE' {
            Mock Test-IsWinOS.OOBE { Return $true }
            Register-cChocoExTask | Should -BeNullOrEmpty
        }
        It 'Tests Test-IsWinSE' {
            Mock Test-IsWinSE { Return $true }
            Register-cChocoExTask | Should -BeNullOrEmpty
        }
    }
    
}