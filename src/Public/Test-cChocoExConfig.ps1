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
        $Quiet,
        # TagFilter
        [Parameter()]
        [string[]]
        $TagFilter,
        # ExcludeTagFilter
        [Parameter()]
        [string[]]
        $ExcludeTagFilter
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
            if (-not (Test-Path -Path $cChocoExConfigFile)) {
                Write-Warning "The configuration file '$cChocoExConfigFile' does not exist. Skipping import."
                return
            }
            $FileFullPath = (Resolve-Path -Path $cChocoExConfigFile).Path
            $ConfigImport = Import-PowerShellDataFile -Path $cChocoExConfigFile
            $Configurations = @()
            foreach ($value in $ConfigImport.Values) {
                if ($value.ConfigName -ne 'MaintenanceWindow' -and $value.Name -ne 'MaintenanceWindow') {
                    $Configurations += $value
                }
            }

            # Apply tag filtering
            if ($TagFilter) {
                $Configurations = $Configurations | Where-Object { 
                    $config = $_
                    $configTags = $config.Tags
                    if ($configTags) {
                        $TagFilter | Where-Object { $configTags -contains $_ }
                    }
                }
            }
            if ($ExcludeTagFilter) {
                $Configurations = $Configurations | Where-Object {
                    $config = $_
                    $configTags = $config.Tags
                    if ($configTags) {
                        -not ($ExcludeTagFilter | Where-Object { $configTags -contains $_ })
                    }
                    else {
                        $true
                    }
                }
            }
 
            $Configurations | ForEach-Object {
                $DSC = $null
                $Configuration = $_
                $Object = [PSCustomObject]@{
                    PSTypeName = 'cChocoExConfig'
                    ConfigName = $Configuration.ConfigName
                    DSC        = $null
                    Ensure     = $Configuration.Ensure
                    Value      = $Configuration.Value
                    Tags       = $Configuration.Tags
                    Path       = $FileFullPath
                }
                $DSC = Test-TargetResource -ConfigName $Configuration.ConfigName -Ensure $Configuration.Ensure -Value $Configuration.Value
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
            return , $Status
        }
    }
}