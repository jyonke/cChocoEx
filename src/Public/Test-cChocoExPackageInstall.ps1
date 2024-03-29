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
        $Path,
        # Return True or False for all tests
        [Parameter()]
        [switch]
        $Quiet
    )
    
    begin {
        [array]$Status = @()
        $ModulePath = (Join-Path $Global:ModuleBase "cChocoPackageInstall")
        Import-Module $ModulePath  

        if ($Path) {
            $cChocoExPackageFiles = Get-Item -Path $Path -ErrorAction Stop
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
                $ConfigImport = $null
                $ConfigImport = Import-PowerShellDataFile $_.FullName 
                $Configurations += $ConfigImport | ForEach-Object { $_.Values }
            }        
            #$PriorityConfigurations = Get-PackagePriority -Configurations $Configurations

            #Filter Out Non Applicable Packages
            $Configurations = Filter-PackageRing -Configurations $Configurations
            $Configurations = Filter-PackageVPN -Configurations $Configurations
            $Configurations = $Configurations | Where-Object { $_.Name }
            
            if (($Configurations | Measure-Object).Count -lt 1) {
                Write-Warning 'No elegible packages found to test'
                return
            }
                   
            $Configurations | ForEach-Object {
                $DSC = $null
                $Configuration = $_
                $Object = [PSCustomObject]@{
                    PSTypeName                = 'cChocoExPackageInstall'
                    Name                      = $Configuration.Name
                    DSC                       = $null
                    InstallVersion            = $null
                    InstallDate               = $null
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
                    EnvRestriction            = $Configuration.EnvRestriction
                }
                $Configuration.Remove("VPN")
                $Configuration.Remove("Ring")
                $Configuration.Remove("OverrideMaintenanceWindow")
                $Configuration.Remove("Priority")
                $Configuration.Remove("EnvRestriction")
    
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
        if ($Quiet) {
            if ($Status | Where-Object { $_.DSC -eq $False }) {
                return $False
            }
            else {
                return $True
            }
        }
        else {
            $ChocoInstalled = Import-Clixml -Path (Join-Path $env:ChocolateyInstall 'cache\ChocoInstalled.xml') -ErrorAction SilentlyContinue
            if ($ChocoInstalled) {
                $Status | ForEach-Object {
                    $item = $_
                    $InstallVersion = $ChocoInstalled | Where-Object { $_.Name -eq $Item.Name } | Select-Object -ExpandProperty Version
                    if ($InstallVersion) {
                        $item.InstallVersion = $InstallVersion
                    }
                    $InstallDate = Get-Item -Path (Join-Path $env:ChocolateyInstall "lib\$($item.Name)") -Filter *.nuspec -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CreationTime
                    if ($InstallDate) {
                        $item.InstallDate = $InstallDate
                    }
                }
                return ($Status | Sort-Object -Property Name)
            }
            else {
                return ($Status | Sort-Object -Property Name)
            }
        }
    }
    
}