function Start-cChocoExTask {
    [CmdletBinding()]
    param ()

    #Task Name
    $TaskName = 'cChocoExTask01'
    $TaskPath = '\cChocoEx\'
    #Scheduled Job Object
    $ScheduledTask = Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction SilentlyContinue

    #Confirm Job Object Exists
    if ($ScheduledTask) {
        Write-Log -Severity 'Information' -Message "Required Scheduled Task $TaskName Found"
        #Check If Running
        if ($($ScheduledTask.State) -ne 'Running') {
            Write-Log -Severity 'Warning' -Message "Required Scheduled Task $TaskName State - $($ScheduledTask.State)"
            Write-Log -Severity 'Warning' -Message "Required Scheduled Task $TaskName Starting...."
            #Restart if Not Running
            $null = $ScheduledTask | Start-ScheduledTask
        }
        else {
            #Job Is Already Running
        }
        #Log Current State
        $ScheduledTask = Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction SilentlyContinue
        Write-Log -Severity 'Information' -Message "Required Scheduled Task $TaskName State - $($ScheduledTask.State)"        
    }
    #Write Error if Job Object does not Exist
    else {
        Write-Log -Severity 'Error' -Message "Required Scheduled Task $TaskName Not Found"
    }
}