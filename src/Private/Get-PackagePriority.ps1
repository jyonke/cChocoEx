function Get-PackagePriority {
    [CmdletBinding()]
    param (        
        [Parameter()]
        [array]
        $Configurations
    )


    #Evaluate Ring Status
    $Ring = Get-cChocoExRing
    [int]$SystemRingValue = Get-RingValue -Name $Ring
    
    #Filter Package Sets with the same name and select an appropriate package based on SystemRingValue
    $GroupedMatches = $Configurations.Name | Group-Object | Where-Object { $_.Count -gt 1 }
    $MultiPackageSets = $GroupedMatches | Where-Object { $GroupedMatches.Name -contains $_.Name }
    $MultiPackageSets | ForEach-Object {
        $PackageSet = $_
        $ConfigurationsFiltered = $Configurations | Where-Object { $_.Name -eq $PackageSet.Name } 
        $ConfigurationsFiltered | ForEach-Object { [int]$_.RingValue = (Get-RingValue -Name $_.Ring) }
        $EligibleRingValue = $ConfigurationsFiltered.RingValue | Sort-Object | Where-Object { $SystemRingValue -ge $_ } | Select-Object -Last 1
        $RingPackage = $ConfigurationsFiltered | Where-Object { $EligibleRingValue -eq $_.RingValue }

        #Fix for casting issue when only a single package is defined multiple times
        if ($null -eq ($Configurations | Where-Object { $_.Name -ne $RingPackage.Name })) {
            [array]$Configurations = @()
        }
        else {
            $Configurations = $Configurations | Where-Object { $_.Name -ne $RingPackage.Name }
        }
        $Configurations += $RingPackage
    }
    #Remove Temp RingValue Property
    $Configurations | ForEach-Object { $_.Remove("RingValue") } 

    #Sort by Priority Value
    $Configurations = $Configurations.GetEnumerator() | Sort-Object { $_.Priority }

    return $Configurations
}