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
                Tags       = @("timeout", "web")
            }
        
            "proxy"                    = @{
                ConfigName = "proxy"
                Ensure     = 'Absent'
                Tags       = @("network", "proxy")
            }
        
            "MaintenanceWindow"        = @{
                ConfigName        = 'MaintenanceWindow'
                EffectiveDateTime = "04-05-2021 21:00"
                Start             = '23:00'
                End               = '05:30'
                UTC               = $false
                Tags              = @("maintenance", "window")
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
        (Get-cChocoExConfig -Path $Path | Where-Object { $_.ConfigName -eq "webRequestTimeoutSeconds" }).Value | Should -Be 30
    }
    It 'Verify Return Type' {
        (Get-cChocoExConfig -Path $Path) | Should -BeOfType PSCustomObject
    }
    It 'Filters by Tag' {
        $result = Get-cChocoExConfig -Path $Path -Tag "network"
        $result.Count | Should -Be 1
        $result.ConfigName | Should -Be "proxy"
    }
    It 'Filters by Multiple Tags' {
        $result = Get-cChocoExConfig -Path $Path -Tag @("timeout", "web")
        $result.Count | Should -Be 1
        $result.ConfigName | Should -Be "webRequestTimeoutSeconds"
    }
    It 'Returns Empty When No Tags Match' {
        $result = Get-cChocoExConfig -Path $Path -Tag "nonexistent"
        $result.Count | Should -Be 0
    }
}