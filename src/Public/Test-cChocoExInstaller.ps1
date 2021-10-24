<#
.SYNOPSIS
Returns Chocolatey Install DSC Configuration Status in cChocoEx
.DESCRIPTION
Returns Chocolatey Install DSC Configuration Status in cChocoEx as a PowerShell Custom Object
#>
function Test-cChocoExInstaller {
    [CmdletBinding()]
    param ()
    
    begin {
        [array]$Status = @()
        $ChocolateyInstall = $env:ChocolateyInstall
        $ModuleBase = (Get-Module -Name 'cChoco' -ListAvailable -ErrorAction Stop | Sort-Object -Property Version | Select-Object -Last 1).ModuleBase
        $ModulePath = (Join-Path "$ModuleBase\DSCResources" "cChocoInstaller")
        Import-Module $ModulePath    
    }
    
    process {
        $Configuration = @{
            InstallDir            = $env:ChocolateyInstall
        }

        $Object = [PSCustomObject]@{
            Name                  = 'chocolatey'
            DSC                   = $null
            InstallDir            = $Configuration.InstallDir
        }
        $DSC = $null
        $DSC = Test-TargetResource @Configuration
        $Object.DSC = $DSC
        $Status += $Object
    
        #Remove Module for Write-Host limitations
        Remove-Module "cChocoInstaller"

    }
    
    end {
        $Status
    }
    
}