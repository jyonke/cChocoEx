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