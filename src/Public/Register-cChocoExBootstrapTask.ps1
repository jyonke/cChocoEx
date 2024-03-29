<#
.SYNOPSIS
    Creates a PowerShell Task that runs as SYSTEM to automatically runs cChocoEx bootstrap continuously
.DESCRIPTION
    If no boostrap.ps1 script is present at "$env:ProgramData\cChocoEx\bootstrap.ps1" a miniminal one will be copied to use. 
.EXAMPLE
    PS C:\> Register-cChocoExBootStrapTask -LoopDelay 180
    Creates a Powershell task that will execute "$env:ProgramData\cChocoEx\bootstrap.ps1" every 180 minutes and at startup.
.INPUTS
    None
.OUTPUTS
    None
#>
function Register-cChocoExBootStrapTask {
    [CmdletBinding()]
    param (
        [Parameter()]
        [int]
        $LoopDelay = 90
    )

    $TaskName = 'cChocoExBootstrapTask'
    $TaskPath = '\cChocoEx\'
    $UserID = "NT AUTHORITY\SYSTEM"
    $FilePath = "$env:ProgramData\cChocoEx\bootstrap.ps1"
    $Description = "This task is part of the loop functionality in cChocoEx. It runs $FilePath at startup and upon a defined interval"

    $ScheduledTaskSettingsSet = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -MultipleInstances 'IgnoreNew'
    $ScheduledTaskPrincipal = New-ScheduledTaskPrincipal -UserId $UserID -LogonType ServiceAccount -RunLevel Highest
    $TaskTrigger01 = New-ScheduledTaskTrigger -AtStartup
    $TaskTrigger01.Delay = 'PT5M' #Wait 300s to run
    $TaskTrigger02 = New-ScheduledTaskTrigger -Once -At ((Get-Date).AddMinutes($LoopDelay)) -RepetitionInterval (New-TimeSpan -Minutes $LoopDelay) -RepetitionDuration (New-TimeSpan -Days 1024)
    $ScheduledTaskAction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-Executionpolicy Bypass -NoLogo -NonInteractive -WindowStyle Hidden -File `"$FilePath`""
        
    #Restrictions
    if (Test-TSEnv) {
        Write-Log -Severity "Information" -Message "Task Sequence Environment Detected, Registration of $TaskName Restricted"
        Register-cChocoExInitTask
        return
    }
    #if ((Test-AutopilotESP) -eq $true) {
    #    Write-Log -Severity "Information" -Message "Autopilot Enrollment Status Page Environment Detected, Registration of $TaskName Restricted"
    #    Register-cChocoExInitTask
    #    return
    #}
    if (Test-IsWinPe) {
        Write-Log -Severity "Information" -Message "WinPE Environment Detected, Registration of $TaskName Restricted"
        Register-cChocoExInitTask
        return
    }
    if (Test-IsWinOs.OOBE) {
        Write-Log -Severity "Information" -Message "WinOS OOBE Environment Detected, Registration of $TaskName Restricted"
        Register-cChocoExInitTask
        return
    }
    if (Test-IsWinSE) {
        Write-Log -Severity "Information" -Message "WinSE Environment Detected, Registration of $TaskName Restricted"
        Register-cChocoExInitTask
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
        
    #Check for existing bootstrap.ps1
    Write-Log -Severity 'Information' -Message "Checking for File - $FilePath"
    if (-Not(Test-Path -Path $FilePath)) {
        #Copy Minimal Bootstrap
        Write-Log -Severity 'Information' -Message "$FilePath Not Found - Copying minimal boostrap.ps1"
        try {
            $null = Copy-Item -Path (Join-Path -Path ($PSScriptRoot | Split-Path) -ChildPath 'scripts\bootstrap.min.ps1') -Destination $FilePath -Force
            Write-Log -Severity 'Information' -Message "Success"
        }
        catch {
            Write-Log -Severity 'Error' -Message "Failure"
            Write-Log -Severity 'Error' -Message "$($_.Exception.Message)"
        }
    }
    else {
        Write-Log -Severity 'Information' -Message "$FilePath Already Exists"
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