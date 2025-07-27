$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

InModuleScope 'cChocoEx' {
    Describe 'Set-cChocoExEnvironment' {
        BeforeEach {
            Mock Set-GlobalVariables {}
            Mock Set-EnvironmentalVariables {}
            Mock Test-IsAdmin { return $true }
            Mock Set-cChocoExFolders {}
            Mock Set-RegistryConfiguration {}
            Mock Register-EventSource {}
            Mock Write-Warning {}
            $Global:cChocoExDataFolder = 'TestDrive:\cChocoExData'
        }

        It 'Should call all setup functions when running as admin' {
            Set-cChocoExEnvironment
            Should -Invoke Set-GlobalVariables -Exactly 1
            Should -Invoke Set-EnvironmentalVariables -Exactly 1
            Should -Invoke Set-cChocoExFolders -Exactly 1
            Should -Invoke Set-RegistryConfiguration -Exactly 1
            Should -Invoke Register-EventSource -Exactly 1
            Should -Not -Invoke Write-Warning
        }

        It 'Should warn if not admin and required paths are missing' {
            Mock Test-IsAdmin { return $false }
            Mock Test-Path { return $false }
            Set-cChocoExEnvironment
            Should -Invoke Write-Warning -Exactly 1 -ParameterFilter { $Message -like '*requires elevated access*' }
        }
    }
} 