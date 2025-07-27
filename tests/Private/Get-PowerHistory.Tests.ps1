$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

InModuleScope 'cChocoEx' {
    Describe 'Get-PowerHistory' {
        BeforeEach {
            # Mock Write-Warning to prevent warning output during tests
            Mock Write-Warning {}
        }

        Context 'When power events exist' {
            BeforeEach {
                # Create mock events
                $baseTime = Get-Date
                $mockEvents = @(
                    New-Object -TypeName PSObject -Property @{
                        Id          = 42
                        TimeCreated = $baseTime
                        Message     = ''
                        Properties  = @()
                        ProviderName = 'Microsoft-Windows-Kernel-Power'
                    }
                    New-Object -TypeName PSObject -Property @{
                        Id          = 1074
                        TimeCreated = $baseTime.AddHours(-1)
                        Message     = ''
                        Properties  = @(
                            New-Object -TypeName PSObject -Property @{ value = @('Shutdown', '', '', '', 'power off') }
                        )
                        ProviderName = 'User32'
                    }
                    New-Object -TypeName PSObject -Property @{
                        Id          = 6005
                        TimeCreated = $baseTime.AddHours(-2)
                        Message     = ''
                        Properties  = @()
                        ProviderName = 'Service Control Manager'
                    }
                    New-Object -TypeName PSObject -Property @{
                        Id          = 6006
                        TimeCreated = $baseTime.AddHours(-3)
                        Message     = ''
                        Properties  = @()
                        ProviderName = 'Service Control Manager'
                    }
                    New-Object -TypeName PSObject -Property @{
                        Id          = 6008
                        TimeCreated = $baseTime.AddDays(-1)
                        Message     = ''
                        Properties  = @()
                        ProviderName = 'Service Control Manager'
                    }
                    New-Object -TypeName PSObject -Property @{
                        Id          = 1
                        TimeCreated = $baseTime.AddHours(-4)
                        Message     = ''
                        Properties  = @()
                        ProviderName = 'Microsoft-Windows-Power-Troubleshooter'
                    }
                )

                # Mock Get-WinEvent to return our mock events
                # and properly filter based on StartTime if provided
                Mock Get-WinEvent {
                    param($FilterHashtable)
                    
                    # Filter events based on Id
                    if ($FilterHashtable.Id -contains 1) {
                        $filteredEvents = $mockEvents | Where-Object { $_.Id -eq 1 }
                    }
                    else {
                        $filteredEvents = $mockEvents | Where-Object { $_.Id -ne 1 }
                    }
                    
                    # Filter events based on StartTime if provided
                    if ($FilterHashtable.StartTime) {
                        $filteredEvents = $filteredEvents | Where-Object { $_.TimeCreated -ge $FilterHashtable.StartTime }
                    }
                    
                    return $filteredEvents
                }

                # Mock Get-Culture to return a consistent culture
                Mock Get-Culture {
                    $culture = New-Object -TypeName PSObject
                    $culture | Add-Member -MemberType NoteProperty -Name TextInfo -Value (
                        New-Object -TypeName PSObject |
                        Add-Member -MemberType ScriptMethod -Name ToTitleCase -Value { param($s) return "Power Off" } -PassThru
                    )
                    return $culture
                }
            }

            It 'Should return events' {
                $result = Get-PowerHistory
                $result | Should -Not -BeNullOrEmpty
                # Check that result has Count property (indicating it's a collection)
                $result.Count | Should -BeGreaterThan 0
            }

            It 'Should correctly set messages for different event types' {
                $result = Get-PowerHistory
                
                # Check that events have the correct messages
                ($result | Where-Object { $_.Id -eq 42 }).Message | Should -Be 'Sleep'
                ($result | Where-Object { $_.Id -eq 1074 }).Message | Should -Be 'Power Off'
                ($result | Where-Object { $_.Id -eq 6005 }).Message | Should -Be 'Power On'
                ($result | Where-Object { $_.Id -eq 6006 }).Message | Should -Be 'Power Off'
                ($result | Where-Object { $_.Id -eq 6008 }).Message | Should -Be 'Unexpected Shutdown'
                ($result | Where-Object { $_.Id -eq 1 -and $_.ProviderName -eq 'Microsoft-Windows-Power-Troubleshooter' }).Message | Should -Be 'Wake from Sleep'
            }

            It 'Should filter events by days when specified' {
                $result = Get-PowerHistory -Days 1
                
                # Should not contain events older than 1 day (6008 event is 1 day old)
                $oldEvents = $result | Where-Object { $_.Id -eq 6008 }
                $oldEventsCount = if ($oldEvents -eq $null) { 0 } else { $oldEvents.Count }
                $oldEventsCount | Should -Be 0
            }
        }

        Context 'When no power events exist' {
            BeforeEach {
                # Mock Get-WinEvent to return empty results
                Mock Get-WinEvent { return @() }
                
                # Mock Get-Culture
                Mock Get-Culture {
                    $culture = New-Object -TypeName PSObject
                    $culture | Add-Member -MemberType NoteProperty -Name TextInfo -Value (
                        New-Object -TypeName PSObject |
                        Add-Member -MemberType ScriptMethod -Name ToTitleCase -Value { param($s) return "Power Off" } -PassThru
                    )
                    return $culture
                }
            }

            It 'Should return nothing when no events are found' {
                $result = Get-PowerHistory
                $result | Should -BeNullOrEmpty
            }
        }

        Context 'When an error occurs retrieving events' {
            BeforeEach {
                # Mock Get-WinEvent to throw an exception
                Mock Get-WinEvent { throw "Failed to retrieve events" }
            }

            It 'Should return nothing and write a warning when an error occurs' {
                $result = Get-PowerHistory
                $result | Should -BeNullOrEmpty
                Should -Invoke Write-Warning -Exactly 1 -Scope It
            }
        }
    }
}
