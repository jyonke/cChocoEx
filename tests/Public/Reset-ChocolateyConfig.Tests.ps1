$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force
InModuleScope 'cChocoEx' {
    Describe 'Reset-ChocolateyConfig Tests' {
        BeforeAll {
            function choco.exe { }
            Mock choco.exe {}
            $env:ChocolateyInstall = 'TestDrive:\choco'
            $Config = Join-Path $env:ChocolateyInstall 'config\chocolatey.config'
            $Backup = Join-Path $env:ChocolateyInstall 'config\chocolatey.config.backup'
            New-Item -Path (Split-Path $Config) -ItemType Directory -Force | Out-Null
            Set-Content -Path $Config -Value '<xml></xml>'
            Set-Content -Path $Backup -Value '<xml></xml>'
            Mock Test-ChocolateyConfig { $true }
            Mock Copy-Item {}
            Mock Remove-Item {}
            Mock Get-Content { '<xml></xml>' }
        }
        It 'Restores from backup if backup exists' {
            $result = Reset-ChocolateyConfig
            Assert-MockCalled Copy-Item -Scope It
            $result.Reset | Should -Be $true
            $result.Config | Should -Be (Join-Path $env:ChocolateyInstall 'config\chocolatey.config')
        }
        It 'Removes config and resets if no backup' {
            Mock Test-Path { $false }
            $result = Reset-ChocolateyConfig
            Assert-MockCalled Remove-Item -Scope It
            Assert-MockCalled choco.exe -Scope It
        }
        It 'Returns PSCustomObject with Config and Reset' {
            $result = Reset-ChocolateyConfig
            $result | Should -Not -BeNullOrEmpty
            $result | Should -BeOfType [PSCustomObject]
            $result.Config | Should -Be (Join-Path $env:ChocolateyInstall 'config\chocolatey.config')
            $result.Reset | Should -Match 'True|False'  
        }
    }
} 