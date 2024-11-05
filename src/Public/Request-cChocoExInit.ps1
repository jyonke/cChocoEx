function Request-cChocoExInit {
    <#
    .SYNOPSIS
        Initializes the cChocoEx bootstrap task scheduler configuration.

    .DESCRIPTION
        This function manages the cChocoEx bootstrap task scheduler configuration by:
        1. Checking for incompatible environments (Task Sequence, WinPE, etc.)
        2. Managing existing bootstrap tasks
        3. Registering and starting new bootstrap tasks

        The function includes several safety checks to prevent execution in inappropriate environments:
        - Task Sequence environments
        - Windows PE environments
        - Windows OOBE state
        - Windows SE environments

    .EXAMPLE
        Request-cChocoExInit
        Attempts to initialize the cChocoEx bootstrap task scheduler configuration.

    .OUTPUTS
        None. This function does not generate any output.
        Warnings are displayed if:
        - Task already exists
        - Execution fails
        - Running in incompatible environment

    .NOTES
        Author: Jon Yonke
        Version: 1.0
        Created: 2024-02-11
        
        Required Functions:
        - Test-TSEnv
        - Test-IsWinPE
        - Test-IsWinOs.OOBE
        - Test-IsWinSE
        - Register-cChocoExBootStrapTask

        Task Information:
        - Task Name: cChocoExBootstrapTask
        - Task Path: \cChocoEx\

        Administrative Rights:
        - Required for creating and managing scheduled tasks
    #>
    [CmdletBinding()]
    param()

    $TaskName = 'cChocoExInit'
    $TaskPath = '\cChocoEx\'

    #Restrictions
    if ((Test-TSEnv) -eq $true) {
        return
    }
    #if ((Test-AutopilotESP) -eq $true) {
    #    return
    #}
    if ((Test-IsWinPe) -eq $true) {
        return
    }
    if ((Test-IsWinOs.OOBE) -eq $true) {
        return
    }
    if ((Test-IsWinSE) -eq $true) {
        return
    }

    #Removal
    if (Get-ScheduledTask -TaskName 'cChocoExBootstrapTask' -ErrorAction SilentlyContinue) {
        Write-Warning 'cChocoExBootstrapTask already setup'
        Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$false
        return
    }

    try {
        #Register cChocoEx DSC Task
        Register-cChocoExBootStrapTask

        #Kick off first run
        Get-ScheduledTask -TaskName 'cChocoExBootstrapTask' | Start-ScheduledTask    
    }
    catch {
        Write-Warning $_.Exception.Message
    }
}