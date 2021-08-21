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
        $ChocolateyInstall = $env:ChocolateyInstall
        $cChocoExDataFolder = (Join-Path -Path $env:ProgramData -ChildPath 'cChocoEx')
        $cChocoExConfigurationFolder = (Join-Path -Path $cChocoExDataFolder -ChildPath 'config')
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
            $Configurations = $ConfigImport | ForEach-Object { $_.Keys | ForEach-Object { $ConfigImport.$_ } }
                    
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