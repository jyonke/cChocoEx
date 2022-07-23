<#
.SYNOPSIS
Returns Chocolatey Configuration DSC Configuration in cChocoEx
.DESCRIPTION
Returns Chocolatey Configuration DSC Configuration in cChocoEx as a PowerShell Custom Object
#>
function Get-cChocoExConfig {
    [CmdletBinding()]
    param (
        # Path
        [Parameter()]
        [string]
        $Path
    )
    
    begin {
        [array]$array = @()
        if ($Path) {
            $cChocoExConfigFile = $Path
        }
        else {
            $cChocoExConfigFile = (Join-Path -Path $Global:cChocoExConfigurationFolder -ChildPath 'config.psd1')
        }
    }
    
    process {
        if ($cChocoExConfigFile) {
            $ConfigImport = Import-PowerShellDataFile -Path $cChocoExConfigFile -ErrorAction Stop
            $Configurations = $ConfigImport | ForEach-Object { $_.Values | Where-Object { $_.ConfigName -ne 'MaintenanceWindow' -and $_.Name -ne 'MaintenanceWindow' } } 
            
            #Validate Keys
            $ValidHashTable = @{
                ConfigName = $null
                Ensure     = $null
                Value      = $null
            }
            
            $Configurations.Keys | Sort-Object -Unique | ForEach-Object {
                if ($_ -notin $ValidHashTable.Keys) {
                    throw "Invalid Configuration Key ($_) Found In File: $cChocoExConfigFile"
                }
            }
            
            $Configurations | ForEach-Object {
                $array += [PSCustomObject]@{
                    PSTypeName = 'cChocoExConfig'
                    ConfigName = $_.ConfigName
                    Value      = $_.Value
                    Ensure     = $_.Ensure
                }
            }
        }
        else {
            Write-Warning 'No cChocoEx Configuration file found'
        }
    }
    
    end {
        $array
    }
}