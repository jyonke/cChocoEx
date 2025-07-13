$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force
InModuleScope 'cChocoEx' {
    Describe 'Request-cChocoExInit Tests' {
        BeforeAll {
            Mock Test-TSEnv { $false }
            Mock Test-IsWinPE { $false }
            Mock Test-IsWinOs.OOBE { $false }
            Mock Test-IsWinSE { $false }
            Mock Get-ScheduledTask { $null }
            Mock Register-cChocoExBootStrapTask {}
            Mock Start-ScheduledTask {}
            Mock Unregister-ScheduledTask {}
            Mock Write-Warning {}
        }
        It 'Does not run in Task Sequence environment' {
            Mock Test-TSEnv { $true }
            $result = Request-cChocoExInit
            $result | Should -BeNullOrEmpty
        }
        It 'Does not run in WinPE environment' {
            Mock Test-IsWinPE { $true }
            $result = Request-cChocoExInit
            $result | Should -BeNullOrEmpty
        }
        It 'Does not run in OOBE environment' {
            Mock Test-IsWinOs.OOBE { $true }
            $result = Request-cChocoExInit
            $result | Should -BeNullOrEmpty
        }
        It 'Does not run in WinSE environment' {
            Mock Test-IsWinSE { $true }
            $result = Request-cChocoExInit
            $result | Should -BeNullOrEmpty
        }
        # It 'Warns if task already exists' {
        #     Mock Get-ScheduledTask { @{ TaskName = 'cChocoExBootstrapTask' } }
        #     Request-cChocoExInit
        #     Assert-MockCalled Write-Warning -Scope It
        # }
    }
} 