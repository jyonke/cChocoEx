$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

InModuleScope 'cChocoEx' {
    BeforeDiscovery {
        
    }
    Describe 'Tests updating/adding/removing a config file' {
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
        It "Returns <expected> (<name>)" -TestCases @(
            @{ ConfigName = "disableCompatibilityChecks"; Ensure = 'Present'; Expected = 1 }
            @{ ConfigName = "useRememberedArgumentsForUpgrades"; Ensure = 'Present'; Expected = 1 }
            @{ ConfigName = "webRequestTimeoutSeconds"; Ensure = 'Absent'; Expected = 1 }

        ) {
            Get-ChildItem -Path $Path | Update-cChocoExConfigFile -ConfigName $ConfigName -Ensure $Ensure
        (Get-cChocoExConfig -Path $Path | Where-Object { $_.ConfigName -eq $ConfigName } | Measure-Object).Count | Should -Be $Expected
        }
        It "Removes a package - Returns <expected> (<name>)" -TestCases @(
            @{ ConfigName = "disableCompatibilityChecks"; Expected = 0 }
            @{ ConfigName = "webRequestTimeoutSeconds"; Expected = 0 }
        ) {
            Get-ChildItem -Path $Path | Update-cChocoExConfigFile -ConfigName $ConfigName -Remove
            (Get-cChocoExConfig -Path $Path | Where-Object { $_.ConfigName -eq $ConfigName } | Measure-Object).Count | Should -Be $Expected
        } 
        It "Test optional parameter (<Parameter> - <Value>)" -TestCases @(
            @{ConfigName = 'webRequestTimeoutSeconds'; Ensure = 'Present'; Parameter = 'Value'; Value = '33' }
        ) {
            $Parameters = @{
                ConfigName = $ConfigName
                Ensure     = $Ensure
                $Parameter = $Value
            }
            Get-ChildItem -Path $Path | Update-cChocoExConfigFile @Parameters
            (Get-cChocoExConfig -Path $Path | Where-Object { $_.ConfigName -eq $ConfigName }).$Parameter | Should -Be $Value

        }
        
    }
}