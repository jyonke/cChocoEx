function Test-SystemShuttingDown {
    <#
    .SYNOPSIS
    Checks if the system is currently in the process of shutting down or rebooting.

    .DESCRIPTION
    This function attempts to detect if the system is actively shutting down or rebooting
    by checking for specific system events and processes.

    .OUTPUTS
    [bool] Returns $true if the system is actively shutting down or rebooting, $false otherwise.

    .EXAMPLE
    $isShuttingDown = Test-SystemShuttingDown
    if ($isShuttingDown) {
        Write-Host "The system is actively shutting down or rebooting."
    } else {
        Write-Host "The system is not currently shutting down or rebooting."
    }
    #>

    [CmdletBinding()]
    [OutputType([bool])]
    param()

    try {
        # Check for active shutdown process
        $shutdownProcess = Get-Process -Name "shutdown" -ErrorAction SilentlyContinue
        if ($shutdownProcess) {
            return $true
        }

        # Check for recent shutdown events (within the last 10 seconds)
        $recentTime = (Get-Date).AddSeconds(-10)
        $shutdownEvent = Get-WinEvent -FilterHashtable @{
            LogName   = 'System'
            ID        = 1074, 6006, 6008  # Shutdown initiated, clean shutdown, unexpected shutdown
            StartTime = $recentTime
        } -MaxEvents 1 -ErrorAction SilentlyContinue

        if ($shutdownEvent) {
            return $true
        }

        # Check if critical system processes are stopping
        $criticalProcesses = @("csrss", "winlogon", "services")
        foreach ($process in $criticalProcesses) {
            if (-not (Get-Process -Name $process -ErrorAction SilentlyContinue)) {
                return $true
            }
        }

        return $false
    }
    catch {
        Write-Log -Severity 'Warning' -Message "Error checking shutdown status: $($_.Exception.Message)"
        return $false
    }
}
