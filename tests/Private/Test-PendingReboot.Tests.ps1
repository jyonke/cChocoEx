$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -split 'tests' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

InModuleScope 'cChocoEx' {
    Describe 'Test-PendingReboot' {
        BeforeAll {
            # Mock all registry-checking functions to return $false by default
            Mock Test-RegistryKey { return $false }
            Mock Test-RegistryValue { return $false }
            Mock Test-RegistryValueNotNull { return $false }
            Mock Get-ItemProperty { return $null }
            Mock Get-ChildItem { return $null }
            Mock Test-Path { return $false }
        }

        It 'Should return $false when no reboot is pending' {
            Test-PendingReboot | Should -Be $false
        }

        Context 'When RebootPending key exists' {
            It 'Should return $true' {
                Mock Test-RegistryKey -MockWith { param($Key) if ($Key -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending') { $true } else { $false } }
                Test-PendingReboot | Should -Be $true
            }
        }

        Context 'When RebootInProgress key exists' {
            It 'Should return $true' {
                Mock Test-RegistryKey -MockWith { param($Key) if ($Key -eq 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootInProgress') { $true } else { $false } }
                Test-PendingReboot | Should -Be $true
            }
        }

        Context 'When Auto Update\RebootRequired key exists' {
            It 'Should return $true' {
                Mock Test-RegistryKey -MockWith { param($Key) if ($Key -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired') { $true } else { $false } }
                Test-PendingReboot | Should -Be $true
            }
        }

        Context 'When PackagesPending key exists' {
            It 'Should return $true' {
                Mock Test-RegistryKey -MockWith { param($Key) if ($Key -eq 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\PackagesPending') { $true } else { $false } }
                Test-PendingReboot | Should -Be $true
            }
        }

        Context 'When PostRebootReporting key exists' {
            It 'Should return $true' {
                Mock Test-RegistryKey -MockWith { param($Key) if ($Key -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\PostRebootReporting') { $true } else { $false } }
                Test-PendingReboot | Should -Be $true
            }
        }

        Context 'When UpdateExeVolatile is non-zero' {
            It 'Should return $true' {
                Mock Test-Path -MockWith { param($Path) if ($Path -eq 'HKLM:\SOFTWARE\Microsoft\Updates') { $true } else { $false } }
                Mock Get-ItemProperty -MockWith { param($Path, $Name) if ($Path -eq 'HKLM:\SOFTWARE\Microsoft\Updates' -and $Name -eq 'UpdateExeVolatile') { [PSCustomObject]@{ UpdateExeVolatile = 1 } } else { $null } }
                Test-PendingReboot | Should -Be $true
            }
        }

        Context 'When DVDRebootSignal value exists' {
            It 'Should return $true' {
                Mock Test-RegistryValue -MockWith { param($Key, $Value) if ($Key -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce' -and $Value -eq 'DVDRebootSignal') { $true } else { $false } }
                Test-PendingReboot | Should -Be $true
            }
        }

        Context 'When CurrentRebootAttemps key exists' {
            It 'Should return $true' {
                Mock Test-RegistryKey -MockWith { param($Key) if ($Key -eq 'HKLM:\SOFTWARE\Microsoft\ServerManager\CurrentRebootAttemps') { $true } else { $false } }
                Test-PendingReboot | Should -Be $true
            }
        }

        Context 'When Netlogon\JoinDomain value exists' {
            It 'Should return $true' {
                Mock Test-RegistryValue -MockWith { param($Key, $Value) if ($Key -eq 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon' -and $Value -eq 'JoinDomain') { $true } else { $false } }
                Test-PendingReboot | Should -Be $true
            }
        }

        Context 'When Netlogon\AvoidSpnSet value exists' {
            It 'Should return $true' {
                Mock Test-RegistryValue -MockWith { param($Key, $Value) if ($Key -eq 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon' -and $Value -eq 'AvoidSpnSet') { $true } else { $false } }
                Test-PendingReboot | Should -Be $true
            }
        }

        Context 'When active and current computer names do not match' {
            It 'Should return $true' {
                Mock Test-Path -MockWith { return $true }
                Mock Get-ItemProperty -MockWith {
                    param($Path)
                    if ($Path -eq 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName') { @{ ComputerName = 'Active' } }
                    elseif ($Path -eq 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName') { @{ ComputerName = 'Stored' } }
                    else { $null }
                }
                Test-PendingReboot | Should -Be $true
            }
        }

        Context 'When pending services exist' {
            It 'Should return $true' {
                Mock Test-Path -MockWith { param($Path) if ($Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services\Pending') { $true } else { $false } }
                Mock Get-ChildItem -MockWith { param($Path) if ($Path -eq 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services\Pending') { @('some_item') } else { $null } }
                Test-PendingReboot | Should -Be $true
            }
        }
    }
}
