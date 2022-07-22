$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

InModuleScope 'cChocoEx' {
    Describe 'Test Importing PowerShell Data File' {
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
        BeforeEach {

        }
    }
    
}