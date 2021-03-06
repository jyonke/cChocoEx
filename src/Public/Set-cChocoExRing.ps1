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
        [ValidateSet("Preview", "Canary", "Pilot", "Fast", "Slow", "Broad", "Exclude")]
        [string]
        $Ring
    )
    
    #Ensure Running as Administrator
    if ((Test-IsAdmin) -eq $false) {
        Write-Warning "This function requires elevated access, please reopen PowerShell as an Administrator"
        Break
    }
        
    $Path = "HKLM:\Software\cChocoEx\"
    if (-not(Test-Path $Path)) {
        $null = New-Item -ItemType Directory -Path $Path -Force
    }

    Set-ItemProperty -Path $Path -Name 'Ring' -Value $Ring
}