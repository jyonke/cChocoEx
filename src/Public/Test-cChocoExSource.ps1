<#
.SYNOPSIS
Returns Chocolatey Source DSC Configuration Status in cChocoEx
.DESCRIPTION
Returns Chocolatey Source DSC Configuration Status in cChocoEx as a PowerShell Custom Object
#>
function Test-cChocoExSource {
    [CmdletBinding()]
    param (
        # Path
        [Parameter()]
        [string]
        $Path,
        # Return True or False for all tests
        [Parameter()]
        [switch]
        $Quiet
    )
    
    begin {
        [array]$Status = @()
        $ChocolateyInstall = $env:ChocolateyInstall
        $cChocoExDataFolder = (Join-Path -Path $env:ProgramData -ChildPath 'cChocoEx')
        $cChocoExConfigurationFolder = (Join-Path -Path $cChocoExDataFolder -ChildPath 'config')
        $ModuleBase = (Get-Module -Name 'cChoco' -ListAvailable -ErrorAction Stop | Sort-Object -Property Version | Select-Object -Last 1).ModuleBase
        $ModulePath = (Join-Path "$ModuleBase\DSCResources" "cChocoSource")
        Import-Module $ModulePath    

        if ($Path) {
            $cChocoExSourceFile = $Path
        }
        else {
            $cChocoExSourceFile = (Get-ChildItem -Path $cChocoExConfigurationFolder -Filter 'sources.psd1').FullName
        }
    }
    
    process {
        if ($cChocoExSourceFile) {
            $ConfigImport = Import-PowerShellDataFile -Path $cChocoExSourceFile
            $Configurations = $ConfigImport | ForEach-Object { $_.Values }
                    
            $Configurations | ForEach-Object {
                $DSC = $null
                $Configuration = $_
                $Object = [PSCustomObject]@{
                    Name     = $Configuration.Name
                    Priority = $Configuration.Priority
                    DSC      = $null
                    Source   = $Configuration.Source
                    Ensure   = $Configuration.Ensure
                    User     = $Configuration.User
                    KeyFile  = $Configuration.KeyFile
                    VPN      = $Configuration.VPN
                    Warning  = $null
                }
                $Configuration.Remove("VPN")
                $Configuration.Remove("User")
                $Configuration.Remove("Password")
                $Configuration.Remove("KeyFile")
    
                $DSC = Test-TargetResource @Configuration
                $Object.DSC = $DSC
                $Status += $Object
            }
        }
        else {
            Write-Warning 'No cChocoEx Source file found'
        }
        #Remove Module for Write-Host limitations
        Remove-Module "cChocoSource"

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