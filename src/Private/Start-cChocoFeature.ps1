function Start-cChocoFeature {
    [CmdletBinding()]
    param (
        [Parameter()]
        [hashtable]
        $ConfigImport,
        [Parameter()]
        [string[]]
        $TagFilter,
        [Parameter()]
        [string[]]
        $ExcludeTagFilter
    )
    Write-Log -Severity 'Information' -Message "cChocoConfig:Validating Chocolatey Configurations are Setup"
    $ModulePath = (Join-Path $ModuleBase "cChocoFeature")
    Import-Module $ModulePath
    $Configurations = $ConfigImport | ForEach-Object { $_.Values }
    $Status = @()
    
    # Process Tag Filters
    if ($TagFilter -or $ExcludeTagFilter) {
        Write-Log -Severity 'Information' -Message "Processing Tag Filters for Features"
        if ($TagFilter) {
            Write-Log -Severity 'Information' -Message "Including features with tags: $($TagFilter -join ', ')"
            $Configurations = $Configurations | Where-Object { 
                $config = $_
                $configTags = $config.Tags
                if ($configTags) {
                    $TagFilter | Where-Object { $configTags -contains $_ }
                }
            }
        }
        if ($ExcludeTagFilter) {
            Write-Log -Severity 'Information' -Message "Excluding features with tags: $($ExcludeTagFilter -join ', ')"
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
    }
    
    $Configurations | ForEach-Object {
        $DSC = $null
        $Configuration = $_
        $Object = [PSCustomObject]@{
            FeatureName = $Configuration.FeatureName
            DSC         = $null
            Ensure      = $Configuration.Ensure
        }
        # Remove non-standard properties
        $Configuration.Remove("Tags")

        $DSC = Test-TargetResource @Configuration
        if (-not($DSC)) {
            $null = Set-TargetResource @Configuration
            $DSC = Test-TargetResource @Configuration
        }
    
        $Object.DSC = $DSC
        $Status += $Object
    }
    #Remove Module for Write-Host limitations
    Remove-Module "cChocoFeature"

    Write-Log -Severity 'Information' -Message 'Starting cChocoFeature'
    $Status | ForEach-Object {
        Write-Host '-------------cChocoFeature--------------' -ForegroundColor DarkCyan
        Write-Log -Severity 'Information' -Message "FeatureName: $($_.FeatureName)"
        Write-Log -Severity 'Information' -Message "DSC: $($_.DSC)"
        Write-Log -Severity 'Information' -Message "Ensure: $($_.Ensure)"
    }
    Write-Host '-------------cChocoFeature--------------' -ForegroundColor DarkCyan
}