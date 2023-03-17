<#
.SYNOPSIS
    Creates a PowerShell Task that runs as SYSTEM to automatically run cChocoEx init at startup to ensure looping is enabled post environment restrictions are gone.
.INPUTS
    None
.OUTPUTS
    None
#>
function Register-cChocoExInitTask {
    [CmdletBinding()]
    param (

    )

    $TaskName = 'cChocoExInit'
    $TaskPath = '\cChocoEx\'
    $UserID = "NT AUTHORITY\SYSTEM"
    $FilePath = (Join-Path -Path ($PSScriptRoot | Split-Path) -ChildPath 'scripts\init.ps1')
    $Description = "This task is part of the loop functionality in cChocoEx. It runs Request-cChocoExInit at startup with a 5 minute delay and will be removed once environment restrictions are gone."

    $ScheduledTaskSettingsSet = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -MultipleInstances 'IgnoreNew'
    $ScheduledTaskPrincipal = New-ScheduledTaskPrincipal -UserId $UserID -LogonType ServiceAccount -RunLevel Highest
    $TaskTrigger01 = New-ScheduledTaskTrigger -AtStartup
    $TaskTrigger01.Delay = 'PT5M' #Wait 300s to run
    $TaskTrigger02 = New-ScheduledTaskTrigger -AtLogOn
    $TaskTrigger02.Delay = 'PT5M' #Wait 300s to run
    $ScheduledTaskAction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-Executionpolicy Bypass -NoLogo -NonInteractive -WindowStyle Hidden -Command Request-cChocoExInit"
        
    #ScheduledTaskSplat
    $ScheduledTaskParams = @{
        TaskName    = $TaskName
        TaskPath    = $TaskPath
        Settings    = $ScheduledTaskSettingsSet 
        Trigger     = @($TaskTrigger01, $TaskTrigger02)
        Description = $Description
        Principal   = $ScheduledTaskPrincipal
        Action      = $ScheduledTaskAction
        Force       = $true
    }
        
    #Register Task
    Write-Log -Severity 'Information' -Message "Registering Scheduled Task $TaskName"
    try {
        $null = Register-ScheduledTask @ScheduledTaskParams
        Write-Log -Severity 'Information' -Message "Registering Scheduled Task $TaskName - Success"
    }
    catch {
        Write-Log -Severity 'Error' -Message "Registering Scheduled Task $TaskName - Failure"
        Write-Log -Severity 'Error' -Message "$($_.Exception.Message)"
    }
    
    #Validate Task Exists
    try {
        $null = Get-ScheduledTask -TaskName $TaskName
    }
    catch {
        Write-Log -Severity 'Error' -Message "Required Scheduled Task $TaskName Not Found"
        Write-Log -Severity 'Error' -Message "$($_.Exception.Message)"
    }
}