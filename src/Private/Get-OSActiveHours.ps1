function Get-OSActiveHours {
    <#
    .SYNOPSIS
    Retrieves the current Active Hours set for the operating system.

    .DESCRIPTION
    This function queries the Windows registry to get the Active Hours settings
    used by Windows Update. It returns a custom object with the start and end times.

    .OUTPUTS
    [PSCustomObject] with properties:
    - Start: The start time of Active Hours as a DateTime object
    - Stop: The end time of Active Hours as a DateTime object

    .EXAMPLE
    $activeHours = Get-OSActiveHours
    Write-Host "Active Hours start at $($activeHours.Start) and end at $($activeHours.Stop)"
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    try {
        # Registry path for Active Hours settings
        $registryPath = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"

        # Get Active Hours Start and End values from registry
        $activeHoursStart = Get-ItemPropertyValue -Path $registryPath -Name "ActiveHoursStart" -ErrorAction Stop
        $activeHoursEnd = Get-ItemPropertyValue -Path $registryPath -Name "ActiveHoursEnd" -ErrorAction Stop

        # Create DateTime objects for today with the specified hours
        $startTime = (Get-Date).Date.AddHours($activeHoursStart)
        $endTime = (Get-Date).Date.AddHours($activeHoursEnd)

        # If end time is before start time, it means it spans midnight, so add a day to end time
        if ($endTime -lt $startTime) {
            $endTime = $endTime.AddDays(1)
        }

        # Return custom object with Start and Stop times
        return [PSCustomObject]@{
            Start = $startTime
            Stop  = $endTime
        }
    }
    catch {
        Write-Log -Severity 'Warning' -Message "Error retrieving Active Hours: $($_.Exception.Message)"
    }
}
