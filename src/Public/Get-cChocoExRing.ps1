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
    $Path = "HKLM:\Software\Chocolatey\cChoco\"
    
    try {
        $Ring = (Get-ItemProperty -Path "HKLM:\Software\Chocolatey\cChoco\" -Name 'Ring').Ring
    }
    catch {
        Write-Warning 'No Value Defined, Default Deployment Ring.'
        $Ring = 'Broad'
    }
    return $Ring
}