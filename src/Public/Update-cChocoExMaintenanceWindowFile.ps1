function Update-cChocoExMaintenanceWindowFile {
    [CmdletBinding(DefaultParameterSetName = 'Present')]
    param (
        # Path
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string[]]
        $Path,
        # EffectiveDateTime
        [Parameter(Mandatory = $true, ParameterSetName = 'Present')]
        [string]
        $EffectiveDateTime,
        # Start Time
        [Parameter(Mandatory = $true, ParameterSetName = 'Present')]
        [string]
        $Start,
        # End Time
        [Parameter(Mandatory = $true, ParameterSetName = 'Present')]
        [string]
        $End,
        # UTC
        [Parameter(Mandatory = $true, ParameterSetName = 'Present')]
        [bool]
        $UTC,
        # Remove
        [Parameter(ParameterSetName = 'Remove')]
        [switch]
        $Remove
    )
    
    begin {
        $ConfigName = 'MaintenanceWindow'
    }
    
    process {
        #Create Data Object and Ensure it is valid
        try {
            Install-PSScriptAnalyzer
            $FullName = Get-Item $Path | Select-Object -ExpandProperty FullName
            $DataR = Get-cChocoExConfig -Path $FullName
            $Data = Get-cChocoExMaintenanceWindow -Path $FullName | Select-Object -Property 'ConfigName', 'UTC', 'EffectiveDateTime', 'Start', 'End'
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
            $EffectiveDateTimeString = (Get-Date $EffectiveDateTime).ToString('MM-dd-yyyy HH:mm')
            $Config = $Data | Where-Object { $PSItem.ConfigName -eq $ConfigName }
            if (($Config | Measure-Object).Count -eq 1) {
                Write-Verbose "Updating configuration $ConfigName"
                $Config.EffectiveDateTime = $EffectiveDateTimeString
                $Config.Start = $Start
                $Config.End = $End
                $Config.UTC = $UTC
            }
            if (($Config | Measure-Object).Count -gt 1) {
                throw "Multiple configurations found for ConfigName $ConfigName"
                continue
            }
            if (($Config | Measure-Object).Count -lt 1) {
                Write-Verbose "Adding configuration $ConfigName"
                $Data += [PSCustomObject]@{
                    ConfigName        = $ConfigName
                    EffectiveDateTime = $EffectiveDateTimeString
                    Start             = $Start
                    End               = $End
                    UTC               = $UTC                
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
        Add-Content -Path $TMPFile.FullName -Value '@{ '
        foreach ($Item in ($DataF | Sort-Object -Property Name)) {
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
        if ($DataR) {
            foreach ($Item in ($DataR | Sort-Object -Property Name)) {
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
        }
        Add-Content -Path $TMPFile.FullName -Value '}'

        #Validate File Structure, Format and Update File
        try {
            $null = Get-cChocoExMaintenanceWindow -Path $TMPFile.FullName
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