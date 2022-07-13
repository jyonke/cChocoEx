<#
.SYNOPSIS
Returns Chocolatey Install DSC Configuration Status in cChocoEx
.DESCRIPTION
Returns Chocolatey Install DSC Configuration Status in cChocoEx as a PowerShell Custom Object
#>
function Test-cChocoExInstaller {
    [CmdletBinding()]
    param (
        # Return True or False for all tests
        [Parameter()]
        [switch]
        $Quiet
    )
    
    begin {
        [array]$Status = @()
        $ChocolateyInstall = $env:ChocolateyInstall
        $ModulePath = (Join-Path $Global:ModuleBase "cChocoInstaller")
        Import-Module $ModulePath    
    }
    
    process {
        $Configuration = @{
            InstallDir = $env:ChocolateyInstall
        }

        $Object = [PSCustomObject]@{
            Name       = 'chocolatey'
            DSC        = $null
            InstallDir = $Configuration.InstallDir
        }
        $DSC = $null
        $DSC = Test-TargetResource @Configuration
        $Object.DSC = $DSC
        $Status += $Object
    
        #Remove Module for Write-Host limitations
        Remove-Module "cChocoInstaller"

    }
    
    end {
        if ($Quiet) {
            if ($Status | Where-Object { $_.DSC -eq $False }) {
                return $False
            }
            else {
                return $True
            }
        }
        else {
            return $Status
        }
    }
    
}