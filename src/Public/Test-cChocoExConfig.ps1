<#
.SYNOPSIS
Returns Chocolatey Configuration DSC Configuration Status in cChocoEx
.DESCRIPTION
Returns Chocolatey Configuration DSC Configuration Status in cChocoEx as a PowerShell Custom Object
#>
function Test-cChocoExConfig {
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
        $ModulePath = (Join-Path $Global:ModuleBase "cChocoConfig")
        Import-Module $ModulePath    

        if ($Path) {
            $cChocoExConfigFile = $Path
        }
        else {
            $cChocoExConfigFile = (Join-Path -Path $Global:cChocoExConfigurationFolder -ChildPath 'config.psd1')
        }
    }
    
    process {
        if ($cChocoExConfigFile) {
            $ConfigImport = Import-PowerShellDataFile -Path $cChocoExConfigFile
            $Configurations = $ConfigImport | ForEach-Object { $_.Values | Where-Object { $_.ConfigName -ne 'MaintenanceWindow' -and $_.Name -ne 'MaintenanceWindow' } } 
 
            $Configurations | ForEach-Object {
                $DSC = $null
                $Configuration = $_
                $Object = [PSCustomObject]@{
                    ConfigName = $Configuration.ConfigName
                    DSC        = $null
                    Ensure     = $Configuration.Ensure
                    Value      = $Configuration.Value
                }
                
                $DSC = Test-TargetResource @Configuration
                $Object.DSC = $DSC
                $Status += $Object
            }
        }
        else {
            Write-Warning 'No cChocoEx Configuration file found'
        }
        #Remove Module for Write-Host limitations
        Remove-Module "cChocoConfig"

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