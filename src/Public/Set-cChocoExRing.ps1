<#
.SYNOPSIS
Sets Chocolatey DSC Configuration Deployment Ring Restriction in cChocoEx
.DESCRIPTION
Sets Chocolatey DSC Configuration Deployment Ring Restriction in cChocoEx as a Registry Key
#>
function Set-cChocoExRing {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet("Preview","Canary","Pilot","Fast","Slow","Broad")]
        [string]
        $Ring
    )
    $Path = "HKLM:\Software\cChocoEx\"
    if (-not(Test-Path $Path)) {
        $null = New-Item -ItemType Directory -Path $Path -Force
    }

    Set-ItemProperty -Path $Path -Name 'Ring' -Value $Ring
}