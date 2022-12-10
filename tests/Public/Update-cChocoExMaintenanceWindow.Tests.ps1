$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

InModuleScope 'cChocoEx' {
    BeforeDiscovery {
        
    }
    Describe 'Tests updating/adding/removing a maintenance window config file' {
        BeforeAll {
            $Path = Join-Path $TestDrive 'config.psd1'
            Set-Content -Path $Path -Value @'        
        @{
            "webRequestTimeoutSeconds" = @{
                ConfigName = "webRequestTimeoutSeconds"
                Ensure     = 'Present'
                Value      = 30
            }
        
            "proxy"                    = @{
                ConfigName = "proxy"
                Ensure     = 'Absent'
            }
        
            "MaintenanceWindow"        = @{
                Name              = 'MaintenanceWindow'
                EffectiveDateTime = "04-05-2021 21:00"
                Start             = '23:00'
                End               = '05:30'
                UTC               = $false
            }
        }
'@
        }
        It 'Confirm Configuration Data File Exits' {
            $Path | Should -Exist
        }
        It "Test optional parameter (<Parameter> - <Expected>)" -TestCases @(
            @{Parameter = 'EffectiveDateTime'; Expected = '01-01-1900 03:00' }
            @{Parameter = 'Start'; Expected = '01:30' }
            @{Parameter = 'End'; Expected = '08:30' }
            @{Parameter = 'UTC'; Expected = $true }
        ) {
            $Parameters = @{
                EffectiveDateTime = '01/01/1900 03:00'
                Start             = '01:30'
                End               = '08:30'
                UTC               = $true
            }
            Get-ChildItem -Path $Path | Update-cChocoExMaintenanceWindowFile @Parameters
            (Get-cChocoExMaintenanceWindow -Path $Path).$Parameter | Should -Be $Expected

        }
        It "Removes a maintenance window - Returns 0)" {
            Get-ChildItem -Path $Path | Update-cChocoExMaintenanceWindowFile -Remove
            (Get-cChocoExMaintenanceWindow -Path $Path | Measure-Object).Count | Should -Be 0
        } 
    }
}