function Get-VPN {
    [CmdletBinding()]
    param (
        # Active VPN Connection
        [Parameter()]
        [switch]
        $Active
    )
    $RegEx = 'pangp|cisco|juniper|vpn|Wintun'
    Write-Log -Severity 'Information' -Message "Looking for VPN Network Adapter"
    if ($Active) {
        Write-Log -Severity 'Information' -Message "VPN Filter Set to Active Only"
        $NetAdapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }
    }
    else {
        $NetAdapters = Get-NetAdapter
    }
    
    $VPNAdapter = $NetAdapters | Where-Object { $_.InterfaceDescription -match $RegEx } | Select-Object -First 1
    if ($VPNAdapter) {
        Write-Log -Severity 'Information' -Message "Name: $($VPNAdapter.Name)"
        Write-Log -Severity 'Information' -Message "InterfaceDescription: $($VPNAdapter.InterfaceDescription)"
        Write-Log -Severity 'Information' -Message "ifIndex: $($VPNAdapter.ifIndex)"
        Write-Log -Severity 'Information' -Message "Status: $($VPNAdapter.Status)"
        Return $true
    }
    else {
        Write-Log -Severity 'Information' -Message "VPN Status: InActive"
        Return $false
    }
}