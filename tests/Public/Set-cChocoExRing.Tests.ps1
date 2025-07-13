$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force
InModuleScope 'cChocoEx' {
    Describe 'Set-cChocoExRing Tests' {
        BeforeAll {
            Mock Test-IsAdmin { $true }
            Mock Set-ItemProperty {}
            Mock Test-Path { $true }
            Mock New-Item {}
        }
        It "Sets registry value for <Ring> ring" -ForEach @(
            @{ Ring = 'Preview' }
            @{ Ring = 'Canary' }
            @{ Ring = 'Pilot' }
            @{ Ring = 'Fast' }
            @{ Ring = 'Slow' }
            @{ Ring = 'Broad' }
            @{ Ring = 'Exclude' }
        ) {
            Set-cChocoExRing -Ring $Ring
            Assert-MockCalled Set-ItemProperty -ParameterFilter { $Value -eq $Ring } -Scope It
        }
        It 'Creates registry key if missing' {
            Mock Test-Path { $false }
            Set-cChocoExRing -Ring 'Pilot'
            Assert-MockCalled New-Item -Scope It
        }
        It 'Warns if not admin' {
            Mock Test-IsAdmin { $false }
            Set-cChocoExRing -Ring 'Pilot' -WarningVariable WarnVar
            $WarnVar | Should -Contain "This function requires elevated access, please reopen PowerShell as an Administrator"
        }
    }
} 