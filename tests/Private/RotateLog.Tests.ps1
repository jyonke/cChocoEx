$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -split 'tests' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

InModuleScope 'cChocoEx' {
    Describe 'RotateLog' {
        BeforeAll {
            # Set a temporary log path for tests
            $Global:LogPath = 'TestDrive:\temp'
        }

        BeforeEach {
            # Mock all file system cmdlets
            Mock Test-Path { return $false }
            Mock Get-Item { } 
            Mock Copy-Item { }
            Mock Clear-Content { }
        }

        Context 'When log file is larger than 10MB' {
            It 'Should rotate the log file' {
                Mock Test-Path { return $true }
                $mockLogFile = [pscustomobject]@{ Length = 11MB }
                Mock Get-Item { return $mockLogFile }

                RotateLog

                Should -Invoke 'Copy-Item' -Exactly 1 -ParameterFilter {
                    $Path -eq 'TestDrive:\temp\cChoco.log' -and
                    $Destination -eq 'TestDrive:\temp\cChoco.1.log'
                }
                Should -Invoke 'Clear-Content' -Exactly 1 -ParameterFilter {
                    $Path -eq 'TestDrive:\temp\cChoco.log'
                }
            }
        }

        Context 'When log file is smaller than 10MB' {
            It 'Should not rotate the log file' {
                Mock Test-Path { return $true }
                $mockLogFile = [pscustomobject]@{ Length = 5MB }
                Mock Get-Item { return $mockLogFile }

                RotateLog

                Should -Not -Invoke 'Copy-Item'
                Should -Not -Invoke 'Clear-Content'
            }
        }

        Context 'When log file does not exist' {
            It 'Should not take any action' {
                Mock Test-Path { return $false }

                RotateLog

                Should -Not -Invoke 'Get-Item'
                Should -Not -Invoke 'Copy-Item'
                Should -Not -Invoke 'Clear-Content'
            }
        }
    }
}
