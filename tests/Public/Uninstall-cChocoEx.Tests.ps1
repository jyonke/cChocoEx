$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force
InModuleScope 'cChocoEx' {
    Describe 'Uninstall-cChocoEx Tests' {
        BeforeAll {
            Mock Test-IsAdmin { $true }
            Mock Uninstall-Module {}
            Mock Get-ScheduledTask { @{ TaskName = 'cChocoExBootstrapTask' } }
            Mock Unregister-ScheduledTask {}
            Mock Remove-Item {}
            $Global:cChocoExDataFolder = 'TestDrive:\cChocoExData'
            New-Item -Path $Global:cChocoExDataFolder -ItemType Directory | Out-Null
        }
        It 'Warns if not admin' {
            Mock Test-IsAdmin { $false }
            Uninstall-cChocoEx -WarningVariable WarnVar
            $WarnVar | Should -Contain "This function requires elevated access, please reopen PowerShell as an Administrator"
        }
        It 'Calls Uninstall-Module' {
            Uninstall-cChocoEx
            Assert-MockCalled Uninstall-Module -Exactly 1 -Scope It
        }
        It 'Unregisters scheduled tasks if present' {
            Uninstall-cChocoEx
            Assert-MockCalled Unregister-ScheduledTask -Scope It
        }
        It 'Removes data folder if -Wipe is used' {
            Uninstall-cChocoEx -Wipe
            Assert-MockCalled Remove-Item -Scope It
        }
    }
} 