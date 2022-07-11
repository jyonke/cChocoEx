function Register-cChocoExTask {
    [CmdletBinding()]
    param ()
    
    #Gather Variables
    $TaskName = 'cChocoExTask01'
    $TaskPath = '\cChocoEx\'
    $Description = 'This Task waits for the toast notification application installation activation in cChocoEx'
    $UserID = "NT AUTHORITY\SYSTEM"
    $FilePath = (Join-Path -Path ($PSScriptRoot | Split-Path) -ChildPath 'scripts\loop.ps1')
    
    $ScheduledTaskSettingsSet = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -MultipleInstances 'IgnoreNew'
    $ScheduledTaskPrincipal = New-ScheduledTaskPrincipal -UserId $UserID -LogonType ServiceAccount -RunLevel Highest
    $TaskTrigger01 = New-ScheduledTaskTrigger -AtLogOn
    $TaskTrigger02 = New-ScheduledTaskTrigger -AtStartup
    $ScriptBlock = { do { $ItemProperty = Get-ItemProperty -Path "HKLM:\Software\cChocoEx\" -Name 'OverRideMaintenanceWindow' -ErrorAction SilentlyContinue; Start-Sleep -Seconds 5 } until ($ItemProperty.OverRideMaintenanceWindow -eq 1); Start-cChocoEx -OverrideMaintenanceWindow -EnableNotifications }
    $ScheduledTaskAction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-Executionpolicy Bypass -NoLogo -NonInteractive -WindowStyle Hidden -File `"$FilePath`""
    
    #Restrictions
    if (Test-TSEnv) {
        Write-Log -Severity "Information" -Message "Task Sequence Environment Detected, Registration of $TaskName Restricted"
        return
    }
    if (Test-IsWinPe) {
        Write-Log -Severity "Information" -Message "WinPE Environment Detected, Registration of $TaskName Restricted"
        return
    }
    if (Test-IsWinOs.OOBE) {
        Write-Log -Severity "Information" -Message "WinOS OOBE Environment Detected, Registration of $TaskName Restricted"
        return
    }
    if (Test-IsWinSE) {
        Write-Log -Severity "Information" -Message "WinSE Environment Detected, Registration of $TaskName Restricted"
        return
    }

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

    #Start Task
    Start-cChocoExTask
}