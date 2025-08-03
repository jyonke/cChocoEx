$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -split 'tests' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

InModuleScope 'cChocoEx' {
    Describe 'Get-AutoPilotStatus' {
        Context 'When device is not enrolled in AutoPilot' {
            BeforeEach {
                # Mock Get-ItemProperty to return null for CloudAssignedTenantId
                Mock Get-ItemProperty {
                    param($Path, $Name, [System.Management.Automation.ActionPreference]$ErrorAction)
                    if ($Path -eq 'HKLM:\SOFTWARE\Microsoft\Provisioning\Diagnostics\AutoPilot' -and $Name -eq 'CloudAssignedTenantId') {
                        return New-Object -TypeName PSObject -Property @{ CloudAssignedTenantId = $null }
                    }
                }
            }

            It 'Should return Complete = $true when CloudAssignedTenantId is null or empty' {
                $result = Get-AutoPilotStatus
                $result.Complete | Should -Be $true
            }

            It 'Should return all completion statuses as $false when CloudAssignedTenantId is null or empty' {
                $result = Get-AutoPilotStatus
                $result.DevicePrepComplete | Should -Be $false
                $result.DeviceSetupComplete | Should -Be $false
                $result.AccountSetupComplete | Should -Be $false
            }
        }

        Context 'When device is enrolled in AutoPilot but setup is incomplete' {
            BeforeEach {
                # Mock Get-ItemProperty to return a tenant ID
                Mock Get-ItemProperty {
                    param($Path, $Name, [System.Management.Automation.ActionPreference]$ErrorAction)
                    switch ($Path) {
                        'HKLM:\SOFTWARE\Microsoft\Provisioning\Diagnostics\AutoPilot' {
                            if ($Name -eq 'CloudAssignedTenantId') {
                                return New-Object -TypeName PSObject -Property @{ CloudAssignedTenantId = '12345678-1234-1234-1234-123456789012' }
                            }
                        }
                        'HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\JoinInfo\12345678-1234-1234-1234-123456789012' {
                            if ($Name -eq 'TenantId') {
                                return New-Object -TypeName PSObject -Property @{ TenantId = '12345678-1234-1234-1234-123456789012' }
                            }
                        }
                        'HKLM:\SOFTWARE\Microsoft\Provisioning\AutopilotSettings' {
                            switch ($Name) {
                                'DevicePreparationCategory.Status' {
                                    return New-Object -TypeName PSObject -Property @{ 
                                        'DevicePreparationCategory.Status' = '{"categorySucceeded":"False","categoryState":"inProgress"}' 
                                    }
                                }
                                'DeviceSetupCategory.Status' {
                                    return New-Object -TypeName PSObject -Property @{ 
                                        'DeviceSetupCategory.Status' = '{"categorySucceeded":"False","categoryState":"notStarted"}' 
                                    }
                                }
                                'AccountSetupCategory.Status' {
                                    return New-Object -TypeName PSObject -Property @{ 
                                        'AccountSetupCategory.Status' = '{"categorySucceeded":"False","categoryState":"pending"}' 
                                    }
                                }
                            }
                        }
                    }
                }

                # Mock Get-ChildItem to return a GUID
                Mock Get-ChildItem {
                    param($Path, [System.Management.Automation.ActionPreference]$ErrorAction)
                    if ($Path -eq 'HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\JoinInfo') {
                        return @(
                            New-Object -TypeName PSObject -Property @{ PSChildName = '12345678-1234-1234-1234-123456789012' }
                        )
                    }
                }
            }

            It 'Should return Complete = $false when setup is incomplete' {
                $result = Get-AutoPilotStatus
                $result.Complete | Should -Be $false
            }

            It 'Should return correct completion statuses for incomplete setup' {
                $result = Get-AutoPilotStatus
                $result.DevicePrepComplete | Should -Be $false
                $result.DeviceSetupComplete | Should -Be $false
                $result.AccountSetupComplete | Should -Be $false
            }
        }

        Context 'When device is enrolled in AutoPilot and setup is complete' {
            BeforeEach {
                # Mock Get-ItemProperty to return a tenant ID and complete status
                Mock Get-ItemProperty {
                    param($Path, $Name, [System.Management.Automation.ActionPreference]$ErrorAction)
                    switch ($Path) {
                        'HKLM:\SOFTWARE\Microsoft\Provisioning\Diagnostics\AutoPilot' {
                            if ($Name -eq 'CloudAssignedTenantId') {
                                return New-Object -TypeName PSObject -Property @{ CloudAssignedTenantId = '12345678-1234-1234-1234-123456789012' }
                            }
                        }
                        'HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\JoinInfo\12345678-1234-1234-1234-123456789012' {
                            if ($Name -eq 'TenantId') {
                                return New-Object -TypeName PSObject -Property @{ TenantId = '12345678-1234-1234-1234-123456789012' }
                            }
                        }
                        'HKLM:\SOFTWARE\Microsoft\Provisioning\AutopilotSettings' {
                            switch ($Name) {
                                'DevicePreparationCategory.Status' {
                                    return New-Object -TypeName PSObject -Property @{ 
                                        'DevicePreparationCategory.Status' = '{"categorySucceeded":"True","categoryState":"succeeded"}' 
                                    }
                                }
                                'DeviceSetupCategory.Status' {
                                    return New-Object -TypeName PSObject -Property @{ 
                                        'DeviceSetupCategory.Status' = '{"categorySucceeded":"True","categoryState":"succeeded"}' 
                                    }
                                }
                                'AccountSetupCategory.Status' {
                                    return New-Object -TypeName PSObject -Property @{ 
                                        'AccountSetupCategory.Status' = '{"categorySucceeded":"True","categoryState":"succeeded"}' 
                                    }
                                }
                            }
                        }
                    }
                }

                # Mock Get-ChildItem to return a GUID
                Mock Get-ChildItem {
                    param($Path, [System.Management.Automation.ActionPreference]$ErrorAction)
                    if ($Path -eq 'HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\JoinInfo') {
                        return @(
                            New-Object -TypeName PSObject -Property @{ PSChildName = '12345678-1234-1234-1234-123456789012' }
                        )
                    }
                }
            }

            It 'Should return Complete = $true when setup is complete' {
                $result = Get-AutoPilotStatus
                $result.Complete | Should -Be $true
            }

            It 'Should return all completion statuses as $true when setup is complete' {
                $result = Get-AutoPilotStatus
                $result.DevicePrepComplete | Should -Be $true
                $result.DeviceSetupComplete | Should -Be $true
                $result.AccountSetupComplete | Should -Be $true
            }
        }

        Context 'When tenant IDs do not match' {
            BeforeEach {
                # Mock Get-ItemProperty to return different tenant IDs
                Mock Get-ItemProperty {
                    param($Path, $Name, [System.Management.Automation.ActionPreference]$ErrorAction)
                    switch ($Path) {
                        'HKLM:\SOFTWARE\Microsoft\Provisioning\Diagnostics\AutoPilot' {
                            if ($Name -eq 'CloudAssignedTenantId') {
                                return New-Object -TypeName PSObject -Property @{ CloudAssignedTenantId = '12345678-1234-1234-1234-123456789012' }
                            }
                        }
                        'HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\JoinInfo\12345678-1234-1234-1234-123456789012' {
                            if ($Name -eq 'TenantId') {
                                return New-Object -TypeName PSObject -Property @{ TenantId = '98765432-4321-4321-4321-210987654321' }
                            }
                        }
                    }
                }

                # Mock Get-ChildItem to return a GUID
                Mock Get-ChildItem {
                    param($Path, [System.Management.Automation.ActionPreference]$ErrorAction)
                    if ($Path -eq 'HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\JoinInfo') {
                        return @(
                            New-Object -TypeName PSObject -Property @{ PSChildName = '12345678-1234-1234-1234-123456789012' }
                        )
                    }
                }
            }

            It 'Should return Complete = $true when tenant IDs do not match' {
                $result = Get-AutoPilotStatus
                $result.Complete | Should -Be $true
            }
        }
    }
}
