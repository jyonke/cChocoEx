<#
.SYNOPSIS
Updates or removes a Chocolatey feature in a cChocoEx feature configuration file.

.DESCRIPTION
This function allows you to add, update, or remove Chocolatey features in a cChocoEx feature configuration file.
It can modify existing features or add new ones, and it ensures that the resulting file is properly formatted.

.PARAMETER Path
The path to the cChocoEx feature configuration file.

.PARAMETER FeatureName
The name of the Chocolatey feature to update or remove.

.PARAMETER Ensure
Specifies whether the feature should be present or absent. Default is 'Present'.

.PARAMETER Tags
An array of tags to associate with the feature. These tags can be used for filtering and organization.

.PARAMETER Remove
Switch to remove the specified feature from the configuration file.

.EXAMPLE
Update-cChocoExFeatureFile -Path 'C:\ProgramData\cChocoEx\config\feature.psd1' -FeatureName 'useFipsCompliantChecksums' -Ensure 'Present' -Tags @('security', 'compliance')

This example updates or adds the 'useFipsCompliantChecksums' feature with associated tags.

.EXAMPLE
Update-cChocoExFeatureFile -Path 'C:\ProgramData\cChocoEx\config\feature.psd1' -FeatureName 'powershellHost' -Remove

This example removes the 'powershellHost' feature from the specified configuration file.

.NOTES
This function requires the PSScriptAnalyzer module for formatting the output file.

.LINK
https://github.com/jyonke/cChocoEx
#>
function Update-cChocoExFeatureFile {
    [CmdletBinding(DefaultParameterSetName = 'Present')]
    param (
        # Path
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string[]]
        $Path,
        # FeatureName
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $FeatureName,
        # Ensure
        [Parameter(ParameterSetName = 'Present')]
        [Parameter(ParameterSetName = 'Absent')]
        [ValidateSet('Present', 'Absent')]
        [string]
        $Ensure = 'Present',
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
            [array]$Data = Get-cChocoExFeature -Path $FullName | Select-Object * -ExcludeProperty Path
        }
        catch {
            Write-Error $_.Exception.Message
            continue
        }

        #Remove feature
        if ($Remove) {
            Write-Verbose "Removing Config $FeatureName"
            $Data = $Data | ForEach-Object {
                if (-Not($PSItem.FeatureName -eq $FeatureName)) { $PSItem }            
            }
        }
        #Add/Update feature
        if (-not($Remove)) {
            #Update Object
            Write-Verbose "Filtering $($Data.Count) features on $FeatureName"
            $Config = $Data | Where-Object { $PSItem.FeatureName -eq $FeatureName }
            if (($Config | Measure-Object).Count -eq 1) {
                Write-Verbose "Updating feature $FeatureName"
                $Config.Ensure = $Ensure
                if ($Tags) {
                    $Config.Tags = $Tags
                }
            }
            if (($Config | Measure-Object).Count -gt 1) {
                throw "Multiple features found for FeatureName $FeatureName"
                continue
            }
            if (($Config | Measure-Object).Count -lt 1) {
                Write-Verbose "Adding feature $FeatureName"
                $Data += [PSCustomObject]@{
                    FeatureName = $FeatureName
                    Ensure      = $Ensure
                    Tags        = $Tags
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
            $Description = "$($Item.FeatureName)"

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
        Add-Content -Path $TMPFile.FullName -Value '}'

        #Validate File Structure, Format and Update File
        try {
            $null = Get-cChocoExFeature -Path $TMPFile.FullName
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