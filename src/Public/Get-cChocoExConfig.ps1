<#
.SYNOPSIS
Returns Chocolatey Configuration DSC Configuration in cChocoEx
.DESCRIPTION
Returns Chocolatey Configuration DSC Configuration in cChocoEx as a PowerShell Custom Object
#>
function Get-cChocoExConfig {
    [CmdletBinding(DefaultParameterSetName = 'Present')]
    param (
        # Path
        [Alias('FullName', 'Path')]
        [Parameter(ValueFromPipelineByPropertyName = $true, Position = 0)]
        [string[]]
        $cChocoExConfigFile = (Join-Path -Path $Global:cChocoExConfigurationFolder -ChildPath 'config.psd1'),
        # ConfigName
        [Parameter(ParameterSetName = 'Present')]
        [Parameter(ParameterSetName = 'Absent')]
        [string]
        $ConfigName,
        # Ensure
        [Parameter(ParameterSetName = 'Present')]
        [Parameter(ParameterSetName = 'Absent')]
        [ValidateSet('Present', 'Absent')]
        [string]
        $Ensure,
        # Value
        [Parameter(ParameterSetName = 'Present')]
        [string]
        $Value
    )
    
    begin {
        [array]$array = @()
    }
    
    process {
        if (Test-Path $cChocoExConfigFile) {
            $ConfigImport = Import-PowerShellDataFile -Path $cChocoExConfigFile -ErrorAction Continue
            $Configurations = $ConfigImport | ForEach-Object { $_.Values | Where-Object { $_.ConfigName -ne 'MaintenanceWindow' -and $_.Name -ne 'MaintenanceWindow' } } 
            $FullName = Get-Item $cChocoExConfigFile | Select-Object -ExpandProperty FullName
            Write-Verbose "Processing:$FullName"

            #Validate Keys
            $ValidHashTable = @{
                ConfigName = $null
                Ensure     = $null
                Value      = $null
            }
            
            $Configurations.Keys | Sort-Object -Unique | ForEach-Object {
                if ($_ -notin $ValidHashTable.Keys) {
                    Write-Error "Invalid Configuration Key ($_) Found In File: $cChocoExConfigFile"
                    return
                }
            }
            
            $array += $Configurations | ForEach-Object {
                [PSCustomObject]@{
                    #PSTypeName = 'cChocoExConfig'
                    ConfigName = $_.ConfigName
                    Value      = $_.Value
                    Ensure     = $_.Ensure
                    Path       = $FullName
                }
            }
        }
        else {
            Write-Warning 'No cChocoEx Configuration file found'
        }
    }
    
    end {
        #Filter out objects
        if ($ConfigName) {
            $array = $array | Where-Object { $_.ConfigName -eq $ConfigName }
        }
        if ($Ensure) {
            $array = $array | Where-Object { $_.Ensure -eq $Ensure }
        }
        if ($Value) {
            $array = $array | Where-Object { $_.Value -eq $Value }
        }
        return $array
    }
}