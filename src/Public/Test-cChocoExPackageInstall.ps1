<#
.SYNOPSIS
Returns Chocolatey Package Install DSC Configuration Status in cChocoEx
.DESCRIPTION
Returns Chocolatey Package Install DSC Configuration Status in cChocoEx as a PowerShell Custom Object
#>
function Test-cChocoExPackageInstall {
    [CmdletBinding()]
    param (
        # Path
        [Parameter()]
        [string]
        $Path
    )
    
    begin {
        [array]$Status = @()
        $ChocolateyInstall = $env:ChocolateyInstall
        $cChocoExDataFolder = (Join-Path -Path $env:ProgramData -ChildPath 'cChocoEx')
        $cChocoExConfigurationFolder = (Join-Path -Path $cChocoExDataFolder -ChildPath 'config')
        $ModuleBase = (Get-Module -Name 'cChoco' -ListAvailable -ErrorAction Stop | Sort-Object -Property Version | Select-Object -Last 1).ModuleBase
        $ModulePath = (Join-Path "$ModuleBase\DSCResources" "cChocoPackageInstall")
        Import-Module $ModulePath    

        if ($Path) {
            $cChocoExPackageFiles = Get-Item -Path $Path
        }
        else {
            $cChocoExPackageFiles = Get-ChildItem -Path $cChocoExConfigurationFolder -Filter *.psd1 | Where-Object { $_.Name -notmatch "sources.psd1|config.psd1|features.psd1" } 
        }
    }
    
    process {
        if ($cChocoExPackageFiles) {
            $cChocoExPackageFiles | ForEach-Object {
                $ConfigImport = $null
                $ConfigImport = Import-PowerShellDataFile $_.FullName 
                $Configurations += $ConfigImport | ForEach-Object { $_.Values }
            }        
            $PriorityConfigurations = Get-PackagePriority -Configurations $Configurations
                    
            $PriorityConfigurations | ForEach-Object {
                $DSC = $null
                $Configuration = $_
                $Object = [PSCustomObject]@{
                    Name                      = $Configuration.Name
                    DSC                       = $null
                    Version                   = $Configuration.Version
                    MinimumVersion            = $Configuration.MinimumVersion
                    Ensure                    = $Configuration.Ensure
                    Source                    = $Configuration.Source
                    AutoUpgrade               = $Configuration.AutoUpgrade
                    VPN                       = $Configuration.VPN
                    Params                    = $Configuration.Params
                    ChocoParams               = $Configuration.ChocoParams
                    Ring                      = $Configuration.Ring
                    Priority                  = $Configuration.Priority
                    OverrideMaintenanceWindow = $Configuration.OverrideMaintenanceWindow
                }
                $Configuration.Remove("VPN")
                $Configuration.Remove("Ring")
                $Configuration.Remove("OverrideMaintenanceWindow")
                $Configuration.Remove("Priority")
    
                $DSC = Test-TargetResource @Configuration
                $Object.DSC = $DSC
                $Status += $Object    
            }
        }
        else {
            Write-Warning 'No cChocoEx Package files found'
        }
        #Remove Module for Write-Host limitations
        Remove-Module "cChocoPackageInstall"

    }
    
    end {
        $Status
    }
    
}