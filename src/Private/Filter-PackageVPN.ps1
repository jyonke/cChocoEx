function Filter-PackageVPN {
    [CmdletBinding()]
    param (        
        [Parameter()]
        [array]
        $Configurations
    )
    
    $Array = @()
    #Evaluate VPN Status
    $VPNStatus = Get-VPN -Active

    $Configurations | ForEach-Object {
        $Item = $_
        #Evaluate VPN Restrictions
        if ($null -ne $Item.VPN) {
            if ($Item.VPN -eq $false -and $VPNStatus) {
                Write-Verbose "Configuration restricted when VPN is connected"
                $Item = $null
            }
            if ($Item.VPN -eq $true -and -not($VPNStatus)) {
                Write-Verbose "Configuration restricted when VPN is not established"
                $Item = $null
            }
        }
        if ($Item) {
            $Array += $Item
        }

    }
    return  $Array
}