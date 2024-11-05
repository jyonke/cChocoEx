<#
.SYNOPSIS
Creates a new cChocoEx Maintenance Window configuration.

.DESCRIPTION
This function creates a new Maintenance Window configuration for cChocoEx. It can either use specified times
or automatically generate a window based on the OS Active Hours. It can also update an existing configuration
with confirmation or force.

.PARAMETER Path
The path to the cChocoEx configuration file.

.PARAMETER Start
The start time of the maintenance window. If not specified, it will be calculated based on OS Active Hours.

.PARAMETER End
The end time of the maintenance window. If not specified, it will be calculated based on OS Active Hours.

.PARAMETER UTC
Specifies whether the times are in UTC. Default is $false.

.PARAMETER UseActiveHours
Switch to use OS Active Hours to determine the maintenance window.

.PARAMETER Force
Switch to force update an existing configuration without prompting.

.EXAMPLE
New-cChocoExMaintenanceWindow -Path 'C:\ProgramData\cChocoEx\config\config.psd1' -UseActiveHours

.EXAMPLE
New-cChocoExMaintenanceWindow -Path 'C:\ProgramData\cChocoEx\config\config.psd1' -Start '22:00' -End '06:00' -Force

.NOTES
This function requires the Get-OSActiveHours function to be available when using the UseActiveHours parameter.

.LINK
https://github.com/jyonke/cChocoEx
#>
function New-cChocoExMaintenanceWindow {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName', 'cChocoExConfigFile')]
        [string]
        $Path = (Join-Path -Path $env:cChocoExConfigurationFolder -ChildPath 'config.psd1'),

        [Parameter(Mandatory = $false)]
        [string]
        $Start,

        [Parameter(Mandatory = $false)]
        [string]
        $End,

        [Parameter(Mandatory = $false)]
        [bool]
        $UTC = $false,

        [Parameter(Mandatory = $false)]
        [switch]
        $UseActiveHours,

        [Parameter(Mandatory = $false)]
        [switch]
        $Force
    )

    process {
        # Check if the file exists
        $fileExists = Test-Path $Path

        # Generate maintenance window based on Active Hours if specified
        if ($UseActiveHours) {
            try {
                $activeHours = Get-OSActiveHours -ErrorAction Stop
                if ($null -eq $activeHours) {
                    Write-Warning "Could not retrieve Active Hours from OS. Maintenance window will not be created."
                    return
                }
                
                if ($null -eq $activeHours.Start -or $null -eq $activeHours.Stop) {
                    Write-Warning "Active Hours start or stop time is null. Maintenance window will not be created."
                    return
                }

                $Start = $activeHours.Stop.ToString('HH:mm')
                $End = $activeHours.Start.ToString('HH:mm')
                $UTC = $false
            }
            catch {
                Write-Warning "Error retrieving Active Hours: $($_.Exception.Message)"
                Write-Warning "Maintenance window will not be created."
                return
            }
        }
        elseif (-not $Start -or -not $End) {
            throw "Either specify both Start and End times, or use the UseActiveHours switch."
        }

        # Set the effective date to today
        $EffectiveDateTime = Get-Date -Format 'MM-dd-yyyy HH:mm'

        if (-not $fileExists) {
            # Create the content string directly
            $content = @"
@{
    'MaintenanceWindow' = @{
        ConfigName = 'MaintenanceWindow'
        EffectiveDateTime = '$EffectiveDateTime'
        Start = '$Start'
        End = '$End'
        UTC = `$$UTC
    }
}
"@
            # Write the new configuration to the file
            $content | Set-Content -Path $Path -Force
            
            # Output the maintenance window details
            Write-Output "Maintenance Window configuration created:"
            Write-Output "  Path: $Path"
            Write-Output "  Start Time: $Start"
            Write-Output "  End Time: $End"
            Write-Output "  UTC: $UTC"
            Write-Output "  Effective Date: $EffectiveDateTime"
        }
        else {
            # If the file exists, use Update-cChocoExMaintenanceWindowFile to update or add the configuration
            if ($Force -or $PSCmdlet.ShouldProcess($Path, "Update Maintenance Window configuration")) {
                Update-cChocoExMaintenanceWindowFile -Path $Path -EffectiveDateTime $EffectiveDateTime -Start $Start -End $End -UTC $UTC
                
                # Output the maintenance window details
                Write-Output "Maintenance Window configuration updated:"
                Write-Output "  Path: $Path"
                Write-Output "  Start Time: $Start"
                Write-Output "  End Time: $End"
                Write-Output "  UTC: $UTC"
                Write-Output "  Effective Date: $EffectiveDateTime"
            }
        }
    }
}
