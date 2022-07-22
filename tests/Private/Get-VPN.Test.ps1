$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

InModuleScope 'cChocoEx' {
    BeforeAll {

    }
    Describe 'Test Disconnected VPN Scenarios' {
        BeforeEach {
            Mock Get-NetAdapter {
                return [PSCustomObject]@{
                    Name                 = "OpenVPN Wintun"
                    InterfaceDescription = 'Wintun Userspace Tunnel'
                    ifIndex              = 0
                    Status               = 'Disconnected'
                }
            }
        }
        It 'Returns False (Active VPN)' {
            Get-VPN -Active | Should -Be $false
        }
        It 'Returns True (VPN Adapter Present)' {
            Get-VPN | Should -Be $true
        }
    }
    Describe 'Test Active VPN Scenarios' {
        BeforeEach {
            Mock Get-NetAdapter {
                return [PSCustomObject]@{
                    Name                 = "OpenVPN Wintun"
                    InterfaceDescription = 'Wintun Userspace Tunnel'
                    ifIndex              = 0
                    Status               = 'Up'
                }
            }
        }
        It 'Returns True (Active VPN)' {
            Get-VPN -Active | Should -Be $true
        }
        It 'Returns True (VPN Adapter Present)' {
            Get-VPN | Should -Be $true
        }
    }
    Describe 'Test No VPN Adapater Present' {
        BeforeEach {
            Mock Get-NetAdapter {
                return [PSCustomObject]@{
                    Name                 = "vEthernet (Default Switch)"
                    InterfaceDescription = 'Hyper-V Virtual Ethernet Adapter'
                    ifIndex              = 0
                    Status               = 'Up'
                }
            }
        }
        It 'Returns False (InActive VPN)' {
            Get-VPN -Active | Should -Be $false
        }
        It 'Returns False (VPN Adapter Not Present)' {
            Get-VPN | Should -Be $false
        }
    }
    
}