function Get-VPN {
    [CmdletBinding()]
    param (
        # Active VPN Connection
        [Parameter()]
        [switch]
        $Active
    )
    $RegEx = 'pangp|cisco|juniper|vpn|Wintun'
    if ($Active) {
        $NetAdapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }
    }
    else {
        $NetAdapters = Get-NetAdapter

    }
    
    $VPNAdapter = $NetAdapters | Where-Object { $_.InterfaceDescription -match $RegEx } | Select-Object -First 1
    if ($VPNAdapter) {
        Return $true
    }
    else {
        Return $false
    }
}