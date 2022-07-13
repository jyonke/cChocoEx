<#
.SYNOPSIS
Returns Chocolatey Package DSC Configuration in cChocoEx
.DESCRIPTION
Returns Chocolatey Package DSC Configuration in cChocoEx as a PowerShell Custom Object
#>
function Get-cChocoExPackageInstall {
    [CmdletBinding()]
    param (
        # Path
        [Parameter()]
        [string]
        $Path
    )
    
    begin {
        [array]$array = @()
        [array]$Configurations = $null

        if ($Path) {
            $cChocoExPackageFiles = Get-Item -Path $Path
        }
        else {
            if (-Not(Test-Path $Global:cChocoExConfigurationFolder)) {
                throw "$Global:cChocoExConfigurationFolder Not Found"
            }
            $cChocoExPackageFiles = Get-ChildItem -Path $Global:cChocoExConfigurationFolder -Filter *.psd1 | Where-Object { $_.Name -notmatch "sources.psd1|config.psd1|features.psd1" } 
        }
    }
    
    process {
        if ($cChocoExPackageFiles) {
            $cChocoExPackageFiles | ForEach-Object {
                $cChocoExPackageFile = $_.FullName 
                $ConfigImport = $null
                $ConfigImport = Import-PowerShellDataFile $_.FullName -ErrorAction Stop
                $Configurations += $ConfigImport | ForEach-Object { $_.Values }

                #Validate Keys
                $ValidHashTable = @{
                    Name                      = $null
                    Version                   = $null
                    Source                    = $null
                    MinimumVersion            = $null
                    Ensure                    = $null
                    AutoUpgrade               = $null
                    Params                    = $null
                    ChocoParams               = $null
                    OverrideMaintenanceWindow = $null
                    VPN                       = $null
                    Ring                      = $null
                    Priority                  = $null
                }
            
                $Configurations.Keys | Sort-Object -Unique | ForEach-Object {
                    if ($_ -notin $ValidHashTable.Keys) {
                        throw "Invalid Configuration Key ($_) Found In File: $cChocoExPackageFile"
                    }
                }
            }     
            
            
                    
            $Configurations | ForEach-Object {
                $array += [PSCustomObject]@{
                    Name                      = $_.Name
                    Version                   = $_.Version
                    Source                    = $_.Source
                    MinimumVersion            = $_.MinimumVersion
                    Ensure                    = $_.Ensure
                    AutoUpgrade               = $_.AutoUpgrade
                    Params                    = $_.Params
                    ChocoParams               = $_.ChocoParams
                    OverrideMaintenanceWindow = $_.OverrideMaintenanceWindow
                    VPN                       = $_.VPN
                    Ring                      = $_.Ring
                    Priority                  = $_.Priority
                }
            }
        }
        else {
            Write-Warning 'No cChocoEx Package files found'
        }
    }
    
    end {
        $array
    }
}