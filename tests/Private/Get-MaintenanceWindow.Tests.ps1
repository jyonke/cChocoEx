$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

InModuleScope 'cChocoEx' {
    Describe 'Test Maintenance Window Enabled General Scenarios' {
        BeforeEach {
            $Global:MaintenanceWindowActive = $null
            $Global:MaintenanceWindowEnabled = $null
            $Params = @{
                UTC               = $true
                StartTime         = '00:00'
                EndTime           = '06:00'
                EffectiveDateTime = '01/01/2021'
            }
            $MockDate = (Get-Date -Date "05:00:00Z").ToUniversalTime()
            Mock Get-Date { Return ( $MockDate ) }
            Mock Test-IsWinOS.OOBE { Return { $False } }
        }
        It 'Validate Return Type' {
            Get-MaintenanceWindow @params | Should -BeOfType 'PSCustomObject'
        }
        It 'Validates Mainteance Windows EffectiveDateTime' {
            (Get-MaintenanceWindow @Params).MaintenanceWindowEnabled | Should -Be $true 
        }
        It 'Validates Mainteance Windows Active' {
            (Get-MaintenanceWindow @Params).MaintenanceWindowActive | Should -Be $true 
        }
    }
    Describe 'Test Maintenance Window Disabled General Scenarios' {
        BeforeEach {
            $Global:MaintenanceWindowActive = $null
            $Global:MaintenanceWindowEnabled = $null
            $Params = @{
                UTC               = $true
                StartTime         = '00:00'
                EndTime           = '06:00'
                EffectiveDateTime = '01/01/3021'
            }
            $MockDate = (Get-Date -Date "08:00:00Z").ToUniversalTime()
            Mock Get-Date { Return ( $MockDate ) }
            Mock Test-IsWinOS.OOBE { Return { $False } }
        }
        It 'Validate Return Type' {
            Get-MaintenanceWindow @params | Should -BeOfType 'PSCustomObject'
        }
        It 'Validates Mainteance Windows EffectiveDateTime' {
            (Get-MaintenanceWindow @Params).MaintenanceWindowEnabled | Should -Be $false
        }
        It 'Validates Mainteance Windows Active' {
            (Get-MaintenanceWindow @Params).MaintenanceWindowActive | Should -Be $false
        }
    }
    Describe 'Test WinPE Environment Scenarios' {
        BeforeEach {
            $Global:MaintenanceWindowActive = $null
            $Global:MaintenanceWindowEnabled = $null
            $Params = @{
                UTC               = $true
                StartTime         = '00:00'
                EndTime           = '06:00'
                EffectiveDateTime = '01/01/2021'
            }            
            $MockDate = (Get-Date -Date "08:00:00Z").ToUniversalTime()
            Mock Get-Date { Return ( $MockDate ) }
            Mock Get-LoggedInUser { return $true }
            Mock Test-IsWinOS.OOBE { Return $false }
            Mock Test-TSEnv { Return $false }
            Mock Test-AutopilotESP { Return $false }
            Mock Test-IsWinPE { Return $true }
        }
        It 'Test WinPE Environment MaintenanceWindowEnabled' {
            (Get-MaintenanceWindow @Params).MaintenanceWindowEnabled | Should -Be $true 
        }
        It 'Test WinPE Environment MaintenanceWindowActive' {
            (Get-MaintenanceWindow @Params).MaintenanceWindowActive | Should -Be $true 
        }
    }
    Describe 'Test Task Sequence Environment Scenarios' {
        BeforeEach {
            $Global:MaintenanceWindowActive = $null
            $Global:MaintenanceWindowEnabled = $null
            $Params = @{
                UTC               = $true
                StartTime         = '00:00'
                EndTime           = '06:00'
                EffectiveDateTime = '01/01/2021'
            }
            $MockDate = (Get-Date -Date "08:00:00Z").ToUniversalTime()
            Mock Get-Date { Return ( $MockDate ) }
            Mock Get-LoggedInUser { return $true }
            Mock Test-IsWinOS.OOBE { Return $false }
            Mock Test-TSEnv { Return $true }
            Mock Test-AutopilotESP { Return $false }
            Mock Test-IsWinPE { Return $false }
        }
        It 'Test Task Sequence Environment MaintenanceWindowEnabled' {
            (Get-MaintenanceWindow @Params).MaintenanceWindowEnabled | Should -Be $true 
        }
        It 'Test Task Sequence Environment MaintenanceWindowActive' {
            (Get-MaintenanceWindow @Params).MaintenanceWindowActive | Should -Be $true 
        }
    }
    Describe 'Test Autopilot ESP Environment Scenarios' {
        BeforeEach {
            $Global:MaintenanceWindowActive = $null
            $Global:MaintenanceWindowEnabled = $null
            $Params = @{
                UTC               = $true
                StartTime         = '00:00'
                EndTime           = '06:00'
                EffectiveDateTime = '01/01/2021'
            }
            $MockDate = (Get-Date -Date "08:00:00Z").ToUniversalTime()
            Mock Get-Date { Return ( $MockDate ) }
            Mock Get-LoggedInUser { return $true }
            Mock Test-IsWinOS.OOBE { Return $false }
            Mock Test-TSEnv { Return $false }
            Mock Test-AutopilotESP { Return $true }
            Mock Test-IsWinPE { Return $false }
        }
        It 'Test Task Sequence Environment MaintenanceWindowEnabled' {
            (Get-MaintenanceWindow @Params).MaintenanceWindowEnabled | Should -Be $true 
        }
        It 'Test Task Sequence Environment MaintenanceWindowActive' {
            (Get-MaintenanceWindow @Params).MaintenanceWindowActive | Should -Be $true 
        }
    }
    Describe 'Test WinOS OOBE Environment Scenarios' {
        BeforeEach {
            $Global:MaintenanceWindowActive = $null
            $Global:MaintenanceWindowEnabled = $null
            $Params = @{
                UTC               = $true
                StartTime         = '00:00'
                EndTime           = '06:00'
                EffectiveDateTime = '01/01/2021'
            }
            $MockDate = (Get-Date -Date "08:00:00Z").ToUniversalTime()
            Mock Get-Date { Return ( $MockDate ) }
            Mock Get-LoggedInUser { Return $true }
            Mock Test-IsWinOS.OOBE { Return $true }
            Mock Test-TSEnv { Return $false }
            Mock Test-AutopilotESP { Return $false }
            Mock Test-IsWinPE { Return $false }
        }
        It 'Test WinOS OOBE Environment MaintenanceWindowEnabled' {
            (Get-MaintenanceWindow @Params).MaintenanceWindowEnabled | Should -Be $true 
        }
        It 'Test WinOS OOBE Environment MaintenanceWindowActive' {
            (Get-MaintenanceWindow @Params).MaintenanceWindowActive | Should -Be $true 
        }
    }
    Describe 'Test Global Override Environment Scenarios' {
        BeforeEach {
            $Global:MaintenanceWindowActive = $null
            $Global:MaintenanceWindowEnabled = $null
            $Global:OverrideMaintenanceWindow = $true
            $Params = @{
                UTC               = $true
                StartTime         = '00:00'
                EndTime           = '06:00'
                EffectiveDateTime = '01/01/2021'
            }
            $MockDate = (Get-Date -Date "08:00:00Z").ToUniversalTime()
            Mock Get-Date { Return ( $MockDate ) }
            Mock Get-LoggedInUser { Return $true }
            Mock Test-IsWinOS.OOBE { Return $false }
            Mock Test-TSEnv { Return $false }
            Mock Test-AutopilotESP { Return $false }
            Mock Test-IsWinPE { Return $false }
        }
        AfterEach {
            $Global:OverrideMaintenanceWindow = $null
        }
        It 'Test Global Override Environment MaintenanceWindowEnabled' {
            (Get-MaintenanceWindow @Params).MaintenanceWindowEnabled | Should -Be $true 
        }
        It 'Test Global Override Environment MaintenanceWindowActive' {
            (Get-MaintenanceWindow @Params).MaintenanceWindowActive | Should -Be $true 
        }
    }
}