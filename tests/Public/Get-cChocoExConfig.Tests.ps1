
$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force



Describe 'Get-cChocoExConfig Tests' {
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
    It 'Returns 2 Config Names and Exclude Maintenance Window' {
        (Get-cChocoExConfig -Path $Path | Select-Object -ExpandProperty ConfigName).Count | Should -Be 2 
    }
    It 'Verify Ensure Values' {
        (Get-cChocoExConfig -Path $Path | Select-Object -ExpandProperty Ensure) | Should -Match 'Absent|Present'
    }
    It 'Verify ConfigName' {
        (Get-cChocoExConfig -Path $Path | Select-Object -ExpandProperty ConfigName) | Should -Not -BeNullOrEmpty
    }
    It 'Verify Value' {
        (Get-cChocoExConfig -Path $Path | Select-Object -Index 1).Value | Should -Be 30
    }
    It 'Verify Return Type' {
        (Get-cChocoExConfig -Path $Path) | Should -BeOfType PSCustomObject
    }
}