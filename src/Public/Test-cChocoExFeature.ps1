<#
.SYNOPSIS
Returns Chocolatey Feature DSC Configuration Status in cChocoEx
.DESCRIPTION
Returns Chocolatey Feature DSC Configuration Status in cChocoEx as a PowerShell Custom Object
#>
function Test-cChocoExFeature {
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
        $ModulePath = (Join-Path $Global:ModuleBase "cChocoFeature")
        Import-Module $ModulePath    

        if ($Path) {
            $cChocoExFeatureFile = $Path
        }
        else {
            $cChocoExFeatureFile = (Join-Path -Path $Global:cChocoExConfigurationFolder -ChildPath 'features.psd1')
        }
    }
    
    process {
        if ($cChocoExFeatureFile) {
            if (-not (Test-Path -Path $cChocoExFeatureFile)) {
                Write-Warning "The feature file '$cChocoExFeatureFile' does not exist. Skipping import."
                return
            }
            $FileFullPath = (Resolve-Path -Path $cChocoExFeatureFile).Path
            $ConfigImport = Import-PowerShellDataFile -Path $cChocoExFeatureFile
            $Configurations = @()
            foreach ($value in $ConfigImport.Values) {
                $Configurations += $value
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
                    PSTypeName  = 'cChocoExFeature'
                    FeatureName = $Configuration.FeatureName
                    DSC         = $null
                    Ensure      = $Configuration.Ensure
                    Tags        = $Configuration.Tags
                    Path        = $FileFullPath
                }
                $DSC = Test-TargetResource -FeatureName $Configuration.FeatureName -Ensure $Configuration.Ensure
                $Object.DSC = $DSC
                $Status += $Object
            }
        }
        else {
            Write-Warning 'No cChocoEx Configuration file found'
        }
        #Remove Module for Write-Host limitations
        Remove-Module "cChocoFeature"

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