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