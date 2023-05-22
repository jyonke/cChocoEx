<#
.SYNOPSIS
Returns Chocolatey Package DSC Configuration in cChocoEx
.DESCRIPTION
Returns Chocolatey Package DSC Configuration in cChocoEx as a PowerShell Custom Object
#>
function Get-cChocoExPackageInstall {
    [CmdletBinding(DefaultParameterSetName = 'Present')]
    param (
        [Alias('FullName', 'Path')]
        [Parameter(ValueFromPipelineByPropertyName = $true, Position = 0)]
        [string[]]
        $cChocoExPackageFile = (Get-ChildItem -Path $Global:cChocoExConfigurationFolder -Filter *.psd1 | Where-Object { $_.Name -notmatch "sources.psd1|config.psd1|features.psd1" } | Select-Object -ExpandProperty FullName),
        # Name
        [Parameter(ParameterSetName = 'Present')]
        [Parameter(ParameterSetName = 'Absent')]
        [Parameter(ParameterSetName = 'Remove')]
        [string]
        $Name,
        # Ring
        [Parameter(ParameterSetName = 'Present')]
        [Parameter(ParameterSetName = 'Absent')]
        [Parameter(ParameterSetName = 'Remove')]
        [ValidateSet("Preview", "Canary", "Pilot", "Fast", "Slow", "Broad", "Exclude")]
        [string]
        $Ring,
        # Ensure
        [Parameter(ParameterSetName = 'Present')]
        [Parameter(ParameterSetName = 'Absent')]
        [ValidateSet('Present', 'Absent')]
        [string]
        $Ensure,
        # Source
        [Parameter(ParameterSetName = 'Present')]
        [string]
        $Source,
        # MinimumVersion
        [Parameter(ParameterSetName = 'Present')]
        [string]
        $MinimumVersion,
        # Version
        [Parameter(ParameterSetName = 'Present')]
        [string]
        $Version,
        # OverrideMaintenanceWindow
        [Parameter(ParameterSetName = 'Present')]
        [Nullable[boolean]]
        $OverrideMaintenanceWindow = $null,
        # AutoUpgrade
        [Parameter(ParameterSetName = 'Present')]
        [Nullable[boolean]]
        $AutoUpgrade = $null,
        # VPN
        [Parameter(ParameterSetName = 'Present')]
        [Nullable[boolean]]
        $VPN = $null,
        # Params
        [Parameter(ParameterSetName = 'Present')]
        [string]
        $Params,
        # ChocoParams
        [Parameter(ParameterSetName = 'Present')]
        [string]
        $ChocoParams,
        # Priority
        [Parameter(ParameterSetName = 'Present')]
        [System.Nullable[int]]
        $Priority,
        # EnvRestriction
        [Parameter(ParameterSetName = 'Present')]
        [ValidateSet("VPN", "TSEnv", "OOBE", "Autopilot")]
        [string]
        $EnvRestriction = $null
    )
    
    begin {
        [array]$array = @()
    }
    
    process {
        if (Test-Path $cChocoExPackageFile) {
            $ConfigImport = Import-PowerShellDataFile -Path $cChocoExPackageFile -ErrorAction Continue
            $Configurations = $ConfigImport | ForEach-Object { $_.Values }
            $FullName = Get-Item $cChocoExPackageFile | Select-Object -ExpandProperty FullName
            Write-Verbose "Processing:$FullName"

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
                EnvRestriction            = $null
            }
            
            $Configurations.Keys | Sort-Object -Unique | ForEach-Object {
                if ($_ -notin $ValidHashTable.Keys) {
                    Write-Error "Invalid Configuration Key ($_) Found In File: $cChocoExPackageFile"
                    Return
                }
            }
                
                    
            $Configurations | ForEach-Object {
                #Default Ring to Broad if none defined
                if (-Not($_.Ring)) {
                    $_.Ring = 'Broad'
                }
                $array += [PSCustomObject]@{
                    PSTypeName                = 'cChocoExPackageInstall'
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
                    EnvRestriction            = $_.EnvRestriction
                    Path                      = $FullName
                }
            }
        }
        else {
            Write-Warning 'No cChocoEx Package files found'
        }
    }
    
    end {
        #Filter objects
        if ($Name) {
            $array = $array | Where-Object { $_.Name -eq $Name }
        }
        if ($Ensure) {
            $array = $array | Where-Object { $_.Ensure -eq $Ensure }
        }
        if ($Priority -ne $null) {
            $array = $array | Where-Object { [int]$_.Priority -eq [int]$Priority }
        }
        if ($Version) {
            $array = $array | Where-Object { $_.Version -eq $Version }
        }
        if ($Source) {
            $array = $array | Where-Object { $_.Source -eq $Source }
        }
        if ($MinimumVersion) {
            $array = $array | Where-Object { $_.MinimumVersion -eq $MinimumVersion }
        }
        if ($AutoUpgrade -ne $Null) {
            $array = $array | Where-Object { [string]$_.AutoUpgrade -eq [string]$AutoUpgrade }
        }
        if ($Params) {
            $array = $array | Where-Object { $_.Params -eq $Params }
        }
        if ($ChocoParams) {
            $array = $array | Where-Object { $_.ChocoParams -eq $ChocoParams }
        }
        if ($Ring) {
            $array = $array | Where-Object { $_.Ring -eq $Ring }
        }
        if ($VPN -ne $Null) {
            $array = $array | Where-Object { [string]$_.VPN -eq [string]$VPN }
        }
        if ($OverrideMaintenanceWindow -ne $Null) {
            $array = $array | Where-Object { [string]$_.OverrideMaintenanceWindow -eq [string]$OverrideMaintenanceWindow }
        }
        if ($EnvRestriction) {
            $array = $array | Where-Object { $_.EnvRestriction -contains $EnvRestriction }
        }
        
        return ($array | Sort-Object -Property Name)
    }
}