function Filter-PackageRing {
    [CmdletBinding()]
    param (        
        [Parameter()]
        [array]
        $Configurations
    )
    
    $Array = @()
    #Evaluate Ring Status
    $Ring = Get-cChocoExRing

    if ($Ring) {
        $SystemRingValue = Get-RingValue -Name $Ring
        Write-Verbose "System Ring Value $SystemRingValue"
    }

    $Configurations | ForEach-Object {
        $Item = $_
        $ConfigurationRingValue = $null

        #Evaluate Ring Restrictions
        if ($null -ne $Item.Ring) {
            Write-Verbose "Evaluating $($Item.Name) - $($Item.Ring)" 
            $ConfigurationRingValue = Get-RingValue -Name $Item.Ring
            Write-Verbose "Ring Value $ConfigurationRingValue"

            #Remove configuration if machine is not in minimum ring
            if ($SystemRingValue -lt $ConfigurationRingValue ) {
                Write-Verbose "Removing: $SystemRingValue -lt  $ConfigurationRingValue"
                $item = $null
            }
            if ($SystemRingValue -ge $ConfigurationRingValue) {
                $Item.RingValue = $ConfigurationRingValue
            }
        }
        if ($Item) {
            $Array += $Item
        }

    }

    #Group and Filter
    [array]$FilteredArray = @()
    $Array | Group-Object -Property { $_.Name } | ForEach-Object {
        $FilteredArray += $_ | Select-Object -ExpandProperty Group | Sort-Object { $_.RingValue } | Select-Object -Last 1
    } 
    #Remove Ring Value Propery
    $FilteredArray | ForEach-Object {
        if ($_.RingValue) {
            $_.Remove('RingValue')
        }
    }
    return  $FilteredArray
}