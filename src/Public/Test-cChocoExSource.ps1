<#
.SYNOPSIS
Returns Chocolatey Source DSC Configuration Status in cChocoEx
.DESCRIPTION
Returns Chocolatey Source DSC Configuration Status in cChocoEx as a PowerShell Custom Object
#>
function Test-cChocoExSource {
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
        $ModulePath = (Join-Path $Global:ModuleBase "cChocoSource")
        Import-Module $ModulePath    

        if ($Path) {
            $cChocoExSourceFile = $Path
        }
        else {
            $cChocoExSourceFile = (Join-Path -Path $Global:cChocoExConfigurationFolder -ChildPath 'sources.psd1')
        }
    }
    
    process {
        if ($cChocoExSourceFile) {
            if (-not (Test-Path -Path $cChocoExSourceFile)) {
                Write-Warning "The source file '$cChocoExSourceFile' does not exist. Skipping import."
                return
            }
            $FileFullPath = (Resolve-Path -Path $cChocoExSourceFile).Path
            $ConfigImport = Import-PowerShellDataFile -Path $cChocoExSourceFile
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
                    PSTypeName = 'cChocoExSource'
                    Name       = $Configuration.Name
                    Priority   = $Configuration.Priority
                    DSC        = $null
                    Source     = $Configuration.Source
                    Ensure     = $Configuration.Ensure
                    User       = $Configuration.User
                    KeyFile    = $Configuration.KeyFile
                    VPN        = $Configuration.VPN
                    Tags       = $Configuration.Tags
                    Warning    = $null
                    Path       = $FileFullPath
                }
                $Configuration.Remove("VPN")
                $Configuration.Remove("User")
                $Configuration.Remove("Password")
                $Configuration.Remove("KeyFile")
                $Configuration.Remove("Tags")
    
                $DSC = Test-TargetResource -Name $Configuration.Name -Ensure $Configuration.Ensure -Source $Configuration.Source -Priority $Configuration.Priority
                $Object.DSC = $DSC
                $Status += $Object
            }
        }
        else {
            Write-Warning 'No cChocoEx Source file found'
        }
        #Remove Module for Write-Host limitations
        Remove-Module "cChocoSource"

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