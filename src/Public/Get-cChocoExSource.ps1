<#
.SYNOPSIS
Returns Chocolatey Sources DSC Configuration in cChocoEx
.DESCRIPTION
Returns Chocolatey Sources DSC Configuration in cChocoEx as a PowerShell Custom Object
#>
function Get-cChocoExSource {
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
            $cChocoExSourceFile = $Path
        }
        else {
            $cChocoExSourceFile = (Join-Path -Path $Global:cChocoExConfigurationFolder -ChildPath 'sources.psd1')
        }
    }
    
    process {
        if ($cChocoExSourceFile) {
            $ConfigImport = Import-PowerShellDataFile -Path $cChocoExSourceFile -ErrorAction Stop
            $Configurations = $ConfigImport | ForEach-Object { $_.Values }
                    
            #Validate Keys
            $ValidHashTable = @{
                Name     = $null
                Ensure   = $null
                Priority = $null
                Source   = $null
                User     = $null
                Password = $null
                KeyFile  = $null
                VPN      = $null
            }
            
            $Configurations.Keys | Sort-Object -Unique | ForEach-Object {
                if ($_ -notin $ValidHashTable.Keys) {
                    throw "Invalid Configuration Key ($_) Found In File: $cChocoExSourceFile"
                }
            }

            $Configurations | ForEach-Object {
                $array += [PSCustomObject]@{
                    Name     = $_.Name
                    Ensure   = $_.Ensure
                    Priority = $_.Priority
                    Source   = $_.Source
                    User     = $_.User
                    Password = $_.Password
                    KeyFile  = $_.KeyFile
                    VPN      = $_.VPN
                }
            }
        }
        else {
            Write-Warning 'No cChocoEx Sources file found'
        }
    }
    
    end {
        $array
    }
}