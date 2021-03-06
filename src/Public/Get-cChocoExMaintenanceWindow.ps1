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
        [Parameter()]
        [string]
        $Path
    )
    
    begin {
        [array]$array = @()
        if ($Path) {
            $cChocoExConfigFile = $Path
        }
        else {
            $cChocoExConfigFile = (Join-Path -Path $Global:cChocoExConfigurationFolder -ChildPath 'config.psd1')
        }
    }
    
    process {
        if ($cChocoExConfigFile) {
            $ConfigImport = Import-PowerShellDataFile -Path $cChocoExConfigFile -ErrorAction Stop
            $MaintenanceWindowConfig = $ConfigImport | ForEach-Object { $_.Values  | Where-Object { $_.ConfigName -eq 'MaintenanceWindow' -or $_.Name -eq 'MaintenanceWindow' } }
            $Date = Get-Date
            $CurrentDate = $Date.ToString('MM-dd-yyyy HH:mm')
            $CurrentDateUTC = ($Date.ToUniversalTime()).ToString('MM-dd-yyyy HH:mm')
            $CurrentTZ = Get-TimeZone | Select-Object -ExpandProperty Id

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
                }
            }
        }
        else {
            Write-Warning 'No cChocoEx Configuration file found'
        }
    }
    
    end {
        $array
    }
}