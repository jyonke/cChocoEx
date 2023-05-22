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
            $FullName = Get-Item $Path | Select-Object -ExpandProperty FullName
            [array]$Data = Get-cChocoExPackageInstall -Path $FullName | Select-Object -ExcludeProperty Path
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
                if ($Property -match 'EnvRestriction') {
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