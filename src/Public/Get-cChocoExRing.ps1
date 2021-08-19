<#
.SYNOPSIS
Returns Chocolatey DSC Configuration Deployment Ring Restriction in cChocoEx
.DESCRIPTION
Returns Chocolatey DSC Configuration Deployment Ring Restriction in cChocoEx as a String
#>
function Get-cChocoExRing {
    [CmdletBinding()]
    param (
    )
    $Path = "HKLM:\Software\cChocoEx\"
    $LegacyPath = "HKLM:\Software\Chocolatey\cChoco\"

    if (Test-Path -Path $LegacyPath) {
        Write-Warning "Legacy Registry Path Found, Migrating to $Path"
        $LegacyRing = (Get-ItemProperty -Path $LegacyPath -Name 'Ring' -ErrorAction SilentlyContinue).Ring
        if ($LegacyRing -and ($LegacyRing -match 'Preview|Canary|Pilot|Fast|Slow|Broad')) {
            Write-Warning 'Legacy Ring Found Migrating'
            Write-Warning $LegacyRing
            Set-cChocoExRing -Ring $LegacyRing
        }
        #Wipe Legacy Path
        $null = Get-Item $LegacyPath -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }
    try {
        $Ring = (Get-ItemProperty -Path $Path -Name 'Ring' -ErrorAction SilentlyContinue).Ring
        if ($Ring -notmatch 'Preview|Canary|Pilot|Fast|Slow|Broad' -and $null -ne $Ring) {
            Write-Warning "$Ring is an Invalid Ring Value, Defaulting to Broad Ring"
            $Ring = 'Broad'
            Set-cChocoExRing -Ring $Ring
        }
        if ($null -eq $Ring) {
            Write-Warning 'No Value Defined, Default Deployment Ring.'
            $Ring = 'Broad'
            Set-cChocoExRing -Ring $Ring    
        }
    }
    catch {
        Write-Warning 'No Value Defined, Default Deployment Ring.'
        $Ring = 'Broad'
        Set-cChocoExRing -Ring $Ring
    }
    return $Ring
}