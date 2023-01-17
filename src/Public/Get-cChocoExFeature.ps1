<#
.SYNOPSIS
Returns Chocolatey Features DSC Configuration in cChocoEx
.DESCRIPTION
Returns Chocolatey Features DSC Configuration in cChocoEx as a PowerShell Custom Object
#>
function Get-cChocoExFeature {
    [CmdletBinding(DefaultParameterSetName = 'Present')]
    param (
        # Path
        [Alias('FullName', 'Path')]
        [Parameter(ValueFromPipelineByPropertyName = $true, Position = 0)]
        [string[]]
        $cChocoExFeatureFile = (Join-Path -Path $Global:cChocoExConfigurationFolder -ChildPath 'features.psd1'),
        # FeatureName
        [Parameter()]
        [string]
        $FeatureName,
        # Ensure
        [Parameter(ParameterSetName = 'Present')]
        [Parameter(ParameterSetName = 'Absent')]
        [ValidateSet('Present', 'Absent')]
        [string]
        $Ensure
              
    )
    
    begin {
        [array]$array = @()
    }
    
    process {
        if (Test-Path $cChocoExFeatureFile) {
            $ConfigImport = Import-PowerShellDataFile -Path $cChocoExFeatureFile -ErrorAction Continue
            $Configurations = $ConfigImport | ForEach-Object { $_.Values }
            $FullName = Get-Item $cChocoExFeatureFile | Select-Object -ExpandProperty FullName
            Write-Verbose "Processing:$FullName"

            #Validate Keys
            $ValidHashTable = @{
                FeatureName = $null
                Ensure      = $null
            }
            
            $Configurations.Keys | Sort-Object -Unique | ForEach-Object {
                if ($_ -notin $ValidHashTable.Keys) {
                    Write-Error "Invalid Configuration Key ($_) Found In File: $cChocoExFeatureFile"
                    return
                }
            }
            $Configurations | ForEach-Object {
                $array += [PSCustomObject]@{
                    PSTypeName  = 'cChocoExFeature'
                    FeatureName = $_.FeatureName
                    Ensure      = $_.Ensure
                    Path        = $FullName
                }
            }
        }
        else {
            Write-Warning 'No cChocoEx Features file found'
        }
    }
    
    end {
        #Filter out objects
        if ($FeatureName) {
            $array = $array | Where-Object { $_.FeatureName -eq $FeatureName }
        }
        if ($Ensure) {
            $array = $array | Where-Object { $_.Ensure -eq $Ensure }
        }
        return $array
    }
}