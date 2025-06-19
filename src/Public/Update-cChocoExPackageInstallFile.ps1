<#
.SYNOPSIS
Updates or removes a Chocolatey package installation configuration in a cChocoEx package configuration file.

.DESCRIPTION
This function allows you to add, update, or remove Chocolatey package installations in a cChocoEx package configuration file.
It can modify existing package configurations or add new ones, and it ensures that the resulting file is properly formatted.

.PARAMETER Path
The path to the cChocoEx package configuration file.

.PARAMETER Name
The name of the Chocolatey package to update or remove.

.PARAMETER Ring
The deployment ring for the package. Valid values are: Preview, Canary, Pilot, Fast, Slow, Broad, Exclude.

.PARAMETER Ensure
Specifies whether the package should be present or absent. Default is 'Present'.

.PARAMETER Source
The source URL or path for the package.

.PARAMETER MinimumVersion
The minimum version of the package to install.

.PARAMETER Version
The specific version of the package to install.

.PARAMETER OverrideMaintenanceWindow
Whether to override the maintenance window for this package installation.

.PARAMETER AutoUpgrade
Whether to automatically upgrade the package when a new version is available.

.PARAMETER VPN
Whether a VPN connection is required to access the package source.

.PARAMETER Params
Additional parameters to pass to the package installation.

.PARAMETER ChocoParams
Additional parameters to pass to Chocolatey during installation.

.PARAMETER Priority
The installation priority of the package. Lower numbers have higher priority.

.PARAMETER EnvRestriction
An array of environment restrictions for the package installation.

.PARAMETER Tags
An array of tags to associate with the package. These tags can be used for filtering and organization.

.PARAMETER Remove
Switch to remove the specified package from the configuration file.

.EXAMPLE
Update-cChocoExPackageInstallFile -Path 'C:\ProgramData\cChocoEx\config\packages.psd1' -Name 'firefox' -Ring 'Broad' -Ensure 'Present' -AutoUpgrade $true -Tags @('browser', 'default')

This example updates or adds the Firefox package configuration for the Broad ring with auto-upgrade enabled and associated tags.

.EXAMPLE
Update-cChocoExPackageInstallFile -Path 'C:\ProgramData\cChocoEx\config\packages.psd1' -Name 'vlc' -Ring 'Fast' -Remove

This example removes the VLC package configuration for the Fast ring from the specified configuration file.

.NOTES
This function requires the PSScriptAnalyzer module for formatting the output file.

.LINK
https://github.com/jyonke/cChocoEx
#>
function Update-cChocoExPackageInstallFile {
    [CmdletBinding(DefaultParameterSetName = 'Present')]
    param (
        # Path
        [Parameter(ParameterSetName = 'Present')]
        [Parameter(ParameterSetName = 'Absent')]
        [Parameter(ParameterSetName = 'Remove')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string[]]
        $Path,
        # Name
        [Parameter(ParameterSetName = 'Present')]
        [Parameter(ParameterSetName = 'Absent')]
        [Parameter(ParameterSetName = 'Remove')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $Name,
        # Ring
        [Parameter(ParameterSetName = 'Present')]
        [Parameter(ParameterSetName = 'Absent')]
        [Parameter(ParameterSetName = 'Remove')]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("Preview", "Canary", "Pilot", "Fast", "Slow", "Broad", "Exclude")]
        [string]
        $Ring,
        # Ensure
        [Parameter(ParameterSetName = 'Present')]
        [Parameter(ParameterSetName = 'Absent')]
        [ValidateSet('Present', 'Absent')]
        [string]
        $Ensure = 'Present',
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
        # Parameter help description
        [Parameter(ParameterSetName = 'Present')]
        [array]
        $EnvRestriction,
        # Tags
        [Parameter(ParameterSetName = 'Present')]
        [array]
        $Tags,
        # Remove
        [Parameter(ParameterSetName = 'Remove')]
        [switch]
        $Remove
    )
    
    begin {
        
    }
    
    process {
        #Create Data Object and Ensure it is valid
        try {
            Install-PSScriptAnalyzer
            if (-not (Test-Path $Path)) {
                Write-Warning "File not found at path: $Path"
                continue
            }
            $FullName = Get-Item $Path | Select-Object -ExpandProperty FullName
            [array]$Data = Get-cChocoExPackageInstall -Path $FullName | Select-Object * -ExcludeProperty Path
        }
        catch {
            Write-Error $_.Exception.Message
            continue
        }

        #Remove Package
        if ($Remove) {
            Write-Verbose "Removing Package $Name - $Ring"
            $Data = $Data | ForEach-Object {  
                if ($Ring) {
                    if (-Not($PSItem.Name -eq $Name -and $PSItem.Ring -eq $Ring)) { $PSItem }   
                }
                if (-Not($Ring)) {
                    if (-Not($PSItem.Name -eq $Name)) { $PSItem }            
                }
            }
        }
        #Add/Update Package
        if (-not($Remove)) {
            #Update Object
            Write-Verbose "Filtering $($Data.Count) packages on package $Name and ring $Ring"
            $Package = $Data | Where-Object { $PSItem.Name -eq $Name -and $PSItem.Ring -eq $Ring }
            if (($Package | Measure-Object).Count -eq 1) {
                Write-Verbose "Updating Package $Name - $Ring"
                $Package.Ensure = $Ensure
                $Package.Source = $Source
                $Package.MinimumVersion = $MinimumVersion
                $Package.Version = $Version
                $Package.OverRideMaintenanceWindow = $OverrideMaintenanceWindow
                $Package.AutoUpgrade = $AutoUpgrade
                $Package.VPN = $VPN
                $Package.Params = $Params
                $Package.ChocoParams = $ChocoParams
                $Package.Priority = $Priority
                $Package.EnvRestriction = $EnvRestriction
                if ($Tags) {
                    $Package.Tags = $Tags
                }
            }
            if (($Package | Measure-Object).Count -gt 1) {
                throw "Multiple packages found for Name $Name and Ring $Ring"
                continue
            }
            if (($Package | Measure-Object).Count -lt 1) {
                Write-Verbose "Adding Package $Name - $Ring"
                $Data += [PSCustomObject]@{
                    Name                      = $Name
                    Ring                      = $Ring
                    Ensure                    = $Ensure
                    Source                    = $Source
                    MinimumVersion            = $MinimumVersion
                    Version                   = $Version
                    OverRideMaintenanceWindow = $OverrideMaintenanceWindow
                    AutoUpgrade               = $AutoUpgrade
                    VPN                       = $VPN
                    Params                    = $Params
                    ChocoParams               = $ChocoParams
                    Priority                  = $Priority
                    EnvRestriction            = $EnvRestriction
                    Tags                      = $Tags
                }
            }        
        }        

        #Remove NULL Properties
        $DataF = foreach ($Item in $Data) {
            $Properties = $Item.PSObject.Properties.Name.Where{ ![string]::IsNullOrWhiteSpace($Item.$_) }
            $Item | Select-Object -Property $Properties
        }

        #Create Temporary File
        $TMPFile = New-TemporaryFile

        #Generate File Data
        Add-Content -Path $TMPFile.FullName -Value '@{'
        foreach ($Item in ($DataF | Sort-Object -Property Name, Ring)) {
            #Default Ring Value
            if ([string]::IsNullOrWhiteSpace($Item.'Ring')) {
                $Item | Add-Member -MemberType NoteProperty -Name 'Ring' -Value 'Broad' -Force
            }
            $Properties = $Item.PSObject.Properties.Name
            $Description = "$($Item.Name)-$($Item.Ring)"

            Add-Content -Path $TMPFile.FullName -Value "`"$Description`" = @{"

            #Build properties and account for both single and double quote usage
            foreach ($Property in $Properties) {
                Write-Verbose "Formatting Property $Property"
                #Strings
                if ($Property -match 'Name|Ensure|Ring|Version|MinimumVersion|Source') {
                    Add-Content -Path $TMPFile.FullName -Value "$Property = `'$($Item.$Property)`'" 
                    continue                
                }
                #Boolean
                if ($Property -match 'AutoUpgrade|VPN|OverrideMaintenanceWindow') {
                    switch -Wildcard ($Item.$Property) {
                        'True' { 
                            Add-Content -Path $TMPFile.FullName -Value "$Property = `$true" 
                        }
                        'False' { 
                            Add-Content -Path $TMPFile.FullName -Value "$Property = `$false" 
                        }
                    }           
                    continue
                }
                #Integer
                if ($Property -match 'Priority') {
                    Add-Content -Path $TMPFile.FullName -Value "$Property = $($Item.$Property)"
                    continue
                }
                #Params
                if ($Property -match 'ChocoParams|Params') {
                    switch -Wildcard ($Item.$Property) {
                        `'* { 
                            Add-Content -Path $TMPFile.FullName -Value "$Property = `"$($Item.$Property)`"" 
                        }
                        `"* { 
                            Add-Content -Path $TMPFile.FullName -Value "$Property = `'$($Item.$Property)`'" 
                        }
                        Default {
                            Add-Content -Path $TMPFile.FullName -Value "$Property = `'$($Item.$Property)`'" 
                        }
                    }
                    continue
                }
                #Array
                if ($Property -match 'EnvRestriction|Tags') {
                    $String = ($($Item.$Property) | ForEach-Object { "`'$_`'" }) -join ','
                    Add-Content -Path $TMPFile.FullName -Value "$Property = @($String)" 
                    continue
                }
            }
            Add-Content -Path $TMPFile.FullName -Value '}'
        }
        Add-Content -Path $TMPFile.FullName -Value '}'

        #Validate File Structure, Format and Update File
        try {
            $null = Get-cChocoExPackageInstall -Path $TMPFile.FullName
            Invoke-Formatter -ScriptDefinition (Get-Content $TMPFile.FullName -Raw) | Set-Content $Path -Force
        }
        catch {
            Write-Error $_.Exception.Message
        }
        finally {
            #Remove Temp File
            Remove-Item $TMPFile.FullName -Force
        }
    }
    
    end {
        
    }
}