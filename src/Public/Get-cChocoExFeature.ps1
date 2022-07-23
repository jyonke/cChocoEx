<#
.SYNOPSIS
Returns Chocolatey Features DSC Configuration in cChocoEx
.DESCRIPTION
Returns Chocolatey Features DSC Configuration in cChocoEx as a PowerShell Custom Object
#>
function Get-cChocoExFeature {
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
            $cChocoExFeatureFile = $Path
        }
        else {
            $cChocoExFeatureFile = (Join-Path -Path $Global:cChocoExConfigurationFolder -ChildPath 'features.psd1')
        }
    }
    
    process {
        if ($cChocoExFeatureFile) {
            $ConfigImport = Import-PowerShellDataFile -Path $cChocoExFeatureFile -ErrorAction Stop
            $Configurations = $ConfigImport | ForEach-Object { $_.Values }
            
            #Validate Keys
            $ValidHashTable = @{
                FeatureName = $null
                Ensure      = $null
            }
            
            $Configurations.Keys | Sort-Object -Unique | ForEach-Object {
                if ($_ -notin $ValidHashTable.Keys) {
                    throw "Invalid Configuration Key ($_) Found In File: $cChocoExFeatureFile"
                }
            }
            $Configurations | ForEach-Object {
                $array += [PSCustomObject]@{
                    PSTypeName  = 'cChocoExFeature'
                    FeatureName = $_.FeatureName
                    Ensure      = $_.Ensure
                }
            }
        }
        else {
            Write-Warning 'No cChocoEx Features file found'
        }
    }
    
    end {
        $array
    }
}