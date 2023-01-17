function Update-cChocoExSourceFile {
    [CmdletBinding(DefaultParameterSetName = 'Present')]
    param (
        # Path
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string[]]
        $Path,
        # Name
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $Name,
        # Ensure
        [Parameter(ParameterSetName = 'Present')]
        [Parameter(ParameterSetName = 'Absent')]
        [ValidateSet('Present', 'Absent')]
        [string]
        $Ensure = 'Present',
        # Source
        [Parameter(Mandatory = $true, ParameterSetName = 'Present')]
        [string]
        $Source,
        # Priority
        [Parameter(Mandatory = $false, ParameterSetName = 'Present')]
        [System.Nullable[int]]
        $Priority,
        # User
        [Parameter(Mandatory = $false, ParameterSetName = 'Present')]
        [string]
        $User,
        # Password
        [Parameter(Mandatory = $false, ParameterSetName = 'Present')]
        [string]
        $Password,
        # Keyfile
        [Parameter(Mandatory = $false, ParameterSetName = 'Present')]
        [string]
        $Keyfile,
        # VPN
        [Parameter(Mandatory = $false, ParameterSetName = 'Present')]
        [Nullable[boolean]]
        $VPN = $null,
        # Remove
        [Parameter(Mandatory = $false, ParameterSetName = 'Remove')]
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
            $Data = Get-cChocoExSource -Path $FullName | Select-Object -ExcludeProperty Path
        }
        catch {
            Write-Error $_.Exception.Message
            continue
        }

        #Remove Source
        if ($Remove) {
            Write-Verbose "Removing Source $Name"
            $Data = $Data | ForEach-Object { if (-Not($PSItem.Name -eq $Name)) { $PSItem } }
        }
        #Add/Update Source
        if (-not($Remove)) {
            #Update Object
            Write-Verbose "Filtering $($Data.Count) sources on source $Name"
            $SourceObject = $Data | Where-Object { $PSItem.Name -eq $Name }
            if (($SourceObject | Measure-Object).Count -eq 1) {
                Write-Verbose "Updating source $Name"
                $SourceObject.Ensure = $Ensure
                $SourceObject.Source = $Source
                $SourceObject.VPN = $VPN
                $SourceObject.Priority = $Priority
                $SourceObject.User = $User
                $SourceObject.Password = $Password
                $SourceObject.Keyfile = $Keyfile
            }
            if (($SourceObject | Measure-Object).Count -gt 1) {
                throw "Multiple packages found for Name $Name"
                continue
            }
            if (($SourceObject | Measure-Object).Count -lt 1) {
                Write-Verbose "Adding source $Name"
                $Data += [PSCustomObject]@{
                    Name     = $Name
                    Ensure   = $Ensure
                    Source   = $Source
                    VPN      = $VPN
                    Priority = $Priority
                    User     = $User
                    Password = $Password
                    Keyfile  = $Keyfile
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
            $Description = "$($Item.Name)"

            Add-Content -Path $TMPFile.FullName -Value "`"$Description`" = @{"

            #Build properties and account for both single and double quote usage
            foreach ($Property in $Properties) {
                Write-Verbose "Formatting Property $Property"
                #Strings
                if ($Property -match 'Name|Ensure|Source|User|Password|Keyfile') {
                    Add-Content -Path $TMPFile.FullName -Value "$Property = `'$($Item.$Property)`'" 
                    continue                
                }
                #Boolean
                if ($Property -match 'VPN') {
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
            }
            Add-Content -Path $TMPFile.FullName -Value '}'
        }
        Add-Content -Path $TMPFile.FullName -Value '}'

        #Validate File Structure, Format and Update File
        try {
            $null = Get-cChocoExSource -Path $TMPFile.FullName
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