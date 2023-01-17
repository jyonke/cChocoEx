<#
.SYNOPSIS
Returns Maintenance Window DSC Configuration in cChocoEx
.DESCRIPTION
Returns Maintenance Window DSC Configuration in cChocoEx as a PowerShell Custom Object
#>

function Get-cChocoExMaintenanceWindow {
    [CmdletBinding()]
    param (
        # Path
        [Alias('FullName', 'Path')]
        [Parameter(ValueFromPipelineByPropertyName = $true, Position = 0)]
        [string[]]
        $cChocoExConfigFile = (Join-Path -Path $Global:cChocoExConfigurationFolder -ChildPath 'config.psd1'),
        # EffectiveDateTime
        [Parameter()]
        [string]
        $EffectiveDateTime,
        # Start Time
        [Parameter()]
        [string]
        $Start,
        # End Time
        [Parameter()]
        [string]
        $End,
        # UTC
        [Parameter()]
        [Nullable[boolean]]
        $UTC = $null
    )
    
    begin {
        [array]$array = @()
    }
    
    process {
        if (Test-Path $cChocoExConfigFile) {
            $ConfigImport = Import-PowerShellDataFile -Path $cChocoExConfigFile -ErrorAction Stop
            $MaintenanceWindowConfig = $ConfigImport | ForEach-Object { $_.Values  | Where-Object { $_.ConfigName -eq 'MaintenanceWindow' -or $_.Name -eq 'MaintenanceWindow' } }
            $Date = Get-Date
            $CurrentDate = $Date.ToString('MM-dd-yyyy HH:mm')
            $CurrentDateUTC = ($Date.ToUniversalTime()).ToString('MM-dd-yyyy HH:mm')
            $CurrentTZ = Get-TimeZone | Select-Object -ExpandProperty Id
            $FullName = Get-Item $cChocoExConfigFile | Select-Object -ExpandProperty FullName
            Write-Verbose "Processing:$FullName"

            $MaintenanceWindowConfig | ForEach-Object {
                if ($_.Name) {
                    $ConfigName = $_.Name
                }
                else {
                    $ConfigName = $_.ConfigName
                }
                $EffectiveDateTime = (Get-Date $_.EffectiveDateTime).ToString('MM-dd-yyyy HH:mm')
                $array += [PSCustomObject]@{
                    PSTypeName        = 'cChocoExMaintenanceWindow'
                    ConfigName        = $ConfigName
                    UTC               = $_.UTC
                    EffectiveDateTime = $EffectiveDateTime
                    Start             = $_.Start
                    End               = $_.End
                    CurrentDate       = $CurrentDate
                    CurrentDateUTC    = $CurrentDateUTC
                    CurrentTZ         = $CurrentTZ
                    Path              = $FullName
                }
            }
        }
        else {
            Write-Warning 'No cChocoEx Configuration file found'
        }
    }
    
    end {
        #Filter out objects
        if ($UTC -ne $null) {
            $array = $array | Where-Object { [string]$_.UTC -eq [string]$UTC }
        }
        if ($End) {
            $array = $array | Where-Object { $_.End -eq $End }
        }
        if ($Start) {
            $array = $array | Where-Object { $_.Start -eq $Start }
        }
        if ($EffectiveDateTime) {
            $array = $array | Where-Object { $_.EffectiveDateTime -eq $EffectiveDateTime }
        }
        return $array
    }
}