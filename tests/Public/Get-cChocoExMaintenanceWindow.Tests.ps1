$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

Describe 'Get-cChocoExMaintenanceWindow Tests' {
    BeforeAll {
        $Path = 'TestDrive:\config.psd1'
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
                ConfigName        = 'MaintenanceWindow'
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
    It 'Returns 1 Maintenance Window' {
        (Get-cChocoExMaintenanceWindow -Path $Path | Select-Object -ExpandProperty 'ConfigName').Count | Should -Be 1
    }
    It 'Verify ConfigName' {
        (Get-cChocoExMaintenanceWindow -Path $Path | Select-Object -ExpandProperty 'ConfigName') | Should -Not -BeNullOrEmpty
    }
    It 'Verify EffectiveDateTime' {
        [datetime](Get-cChocoExMaintenanceWindow -Path $Path | Select-Object -ExpandProperty 'EffectiveDateTime') | Should -BeOfType DateTime
    }
    It 'Verify Start Value' {
        (Get-cChocoExMaintenanceWindow -Path $Path | Select-Object -ExpandProperty 'Start') | Should -Be '23:00'
    }
    It 'Verify End Value' {
        (Get-cChocoExMaintenanceWindow -Path $Path | Select-Object -ExpandProperty 'End') | Should -Be '05:30'
    }
    It 'Verify UTC Value' {
        (Get-cChocoExMaintenanceWindow -Path $Path | Select-Object -ExpandProperty 'UTC') | Should -Be $false
    }
    It 'Verify Return Type' {
        (Get-cChocoExMaintenanceWindow -Path $Path) | Should -BeOfType PSCustomObject
    }
}