<#
.SYNOPSIS
Updates or removes a Chocolatey configuration in a cChocoEx configuration file.

.DESCRIPTION
This function allows you to add, update, or remove Chocolatey configurations in a cChocoEx configuration file.
It can modify existing configurations or add new ones, and it ensures that the resulting file is properly formatted.

.PARAMETER Path
The path to the cChocoEx configuration file.

.PARAMETER ConfigName
The name of the Chocolatey configuration to update or remove.

.PARAMETER Ensure
Specifies whether the configuration should be present or absent. Default is 'Present'.

.PARAMETER Value
The value to set for the configuration.

.PARAMETER Tags
An array of tags to associate with the configuration. These tags can be used for filtering and organization.

.PARAMETER Remove
Switch to remove the specified configuration from the configuration file.

.EXAMPLE
Update-cChocoExConfigFile -Path 'C:\ProgramData\cChocoEx\config\config.psd1' -ConfigName 'webRequestTimeoutSeconds' -Value '30' -Tags @('timeout', 'web')

This example updates or adds the 'webRequestTimeoutSeconds' configuration with a value of 30 and associated tags.

.EXAMPLE
Update-cChocoExConfigFile -Path 'C:\ProgramData\cChocoEx\config\config.psd1' -ConfigName 'proxy' -Remove

This example removes the 'proxy' configuration from the specified configuration file.

.NOTES
This function requires the PSScriptAnalyzer module for formatting the output file.

.LINK
https://github.com/jyonke/cChocoEx
#>
function Update-cChocoExConfigFile {
    [CmdletBinding(DefaultParameterSetName = 'Present')]
    param (
        # Path
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string[]]
        $Path,
        # ConfigName
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $ConfigName,
        # Ensure
        [Parameter(ParameterSetName = 'Present')]
        [Parameter(ParameterSetName = 'Absent')]
        [ValidateSet('Present', 'Absent')]
        [string]
        $Ensure = 'Present',
        # Value
        [Parameter(ParameterSetName = 'Present')]
        [string]
        $Value,
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
        $Path = $Path | Sort-Object -Unique
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
            $DataR = Get-cChocoExMaintenanceWindow -Path $FullName | Select-Object -Property 'ConfigName', 'UTC', 'EffectiveDateTime', 'Start', 'End' 
            [array]$Data = Get-cChocoExConfig -Path $FullName | Select-Object * -ExcludeProperty Path
        }
        catch {
            Write-Error $_.Exception.Message
            continue
        }

        #Remove Config
        if ($Remove) {
            Write-Verbose "Removing Config $ConfigName"
            $Data = $Data | ForEach-Object {
                if (-Not($PSItem.ConfigName -eq $ConfigName)) { $PSItem }            
            }
        }
        #Add/Update Config
        if (-not($Remove)) {
            #Update Object
            Write-Verbose "Filtering $($Data.Count) configurations on config $ConfigName"
            $Config = $Data | Where-Object { $PSItem.ConfigName -eq $ConfigName }
            if (($Config | Measure-Object).Count -eq 1) {
                Write-Verbose "Updating configuration $ConfigName"
                $Config.Ensure = $Ensure
                $Config.Value = $Value
                if ($Tags) {
                    $Config.Tags = $Tags
                }
            }
            if (($Config | Measure-Object).Count -gt 1) {
                throw "Multiple configurations found for ConfigName $ConfigName"
                continue
            }
            if (($Config | Measure-Object).Count -lt 1) {
                Write-Verbose "Adding configuration $ConfigName"
                $Data += [PSCustomObject]@{
                    ConfigName = $ConfigName
                    Ensure     = $Ensure
                    Value      = $Value
                    Tags       = $Tags
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
        foreach ($Item in ($DataF | Sort-Object -Property Name)) {
            $Properties = $Item.PSObject.Properties.Name
            $Description = "$($Item.ConfigName)"

            Add-Content -Path $TMPFile.FullName -Value "`"$Description`" = @{"

            #Build properties and account for both single and double quote usage
            foreach ($Property in $Properties) {
                Write-Verbose "Formatting Property $Property"
                if ($Property -match 'Tags') {
                    $String = ($($Item.$Property) | ForEach-Object { "`'$_`'" }) -join ','
                    Add-Content -Path $TMPFile.FullName -Value "$Property = @($String)" 
                    continue
                }
                Add-Content -Path $TMPFile.FullName -Value "$Property = `'$($Item.$Property)`'" 
            }
            Add-Content -Path $TMPFile.FullName -Value '}'
        }
        if ($DataR) {
            foreach ($Item in ($DataR | Sort-Object -Property Name)) {
                $Properties = $Item.PSObject.Properties.Name
                $Description = "$($Item.ConfigName)"
    
                Add-Content -Path $TMPFile.FullName -Value "`"$Description`" = @{"
    
                #Build properties and account for both single and double quote usage
                foreach ($Property in $Properties) {
                    Write-Verbose "Formatting Property $Property"
                    if ($Property -match 'UTC') {
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
                    else {
                        Add-Content -Path $TMPFile.FullName -Value "$Property = `'$($Item.$Property)`'" 
                    }
                }
                Add-Content -Path $TMPFile.FullName -Value '}'
            }
        }
        Add-Content -Path $TMPFile.FullName -Value '}'

        #Validate File Structure, Format and Update File
        try {
            $null = Get-cChocoExConfig -Path $TMPFile.FullName
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