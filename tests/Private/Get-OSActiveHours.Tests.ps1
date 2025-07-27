$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

InModuleScope 'cChocoEx' {
    Describe 'Get-OSActiveHours' {
        BeforeEach {
            # Mock Write-Log to prevent log output during tests
            Mock Write-Log {}
        }

        Context 'When Active Hours registry values exist' {
            BeforeEach {
                # Mock Get-ItemPropertyValue to return specific Active Hours values
                Mock Get-ItemPropertyValue {
                    param($Path, $Name)
                    switch ($Name) {
                        'ActiveHoursStart' { return 8 }
                        'ActiveHoursEnd' { return 17 }
                    }
                }
            }

            It 'Should return a PSCustomObject with Start and Stop properties' {
                $result = Get-OSActiveHours
                $result | Should -BeOfType [PSCustomObject]
                $result.PSObject.Properties.Name | Should -Contain 'Start'
                $result.PSObject.Properties.Name | Should -Contain 'Stop'
            }

            It 'Should return correct Start and Stop times for same-day Active Hours' {
                $result = Get-OSActiveHours
                $today = (Get-Date).Date
                $expectedStart = $today.AddHours(8)
                $expectedStop = $today.AddHours(17)
                
                $result.Start | Should -Be $expectedStart
                $result.Stop | Should -Be $expectedStop
            }
        }

        Context 'When Active Hours span midnight' {
            BeforeEach {
                # Mock Get-ItemPropertyValue to return Active Hours that span midnight
                Mock Get-ItemPropertyValue {
                    param($Path, $Name)
                    switch ($Name) {
                        'ActiveHoursStart' { return 22 }
                        'ActiveHoursEnd' { return 6 }
                    }
                }
            }

            It 'Should return Stop time on the next day when Active Hours span midnight' {
                $result = Get-OSActiveHours
                $today = (Get-Date).Date
                $expectedStart = $today.AddHours(22)
                $expectedStop = $today.AddHours(6).AddDays(1)
                
                $result.Start | Should -Be $expectedStart
                $result.Stop | Should -Be $expectedStop
            }
        }

        Context 'When registry values do not exist' {
            BeforeEach {
                # Mock Get-ItemPropertyValue to throw an exception (simulating missing registry values)
                Mock Get-ItemPropertyValue {
                    throw "Registry value not found"
                }
            }

            It 'Should return nothing when registry values are missing' {
                $result = Get-OSActiveHours
                $result | Should -BeNullOrEmpty
            }

            It 'Should call Write-Log with a warning when an error occurs' {
                Get-OSActiveHours
                Should -Invoke Write-Log -Exactly 1 -Scope It
            }
        }
    }
}
