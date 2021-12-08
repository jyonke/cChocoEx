function Start-cChocoExJob {
    [CmdletBinding()]
    param ()

    #Job Name
    $Name = 'cChocoExJob01'
    #Scheduled Job Object
    $ScheduledJob = Get-ScheduledJob -Name $Name -ErrorAction SilentlyContinue
    $ScheduledTask = Get-ScheduledTask -TaskName $Name -ErrorAction SilentlyContinue
    $Job = Get-Job -Name $Name -ErrorAction SilentlyContinue

    #Confirm Job Object Exists
    if ($ScheduledJob) {
        Write-Log -Severity 'Information' -Message "Required Scheduled Job $Name Found"
        #Check If Running
        if ($($ScheduledTask.State) -ne 'Running') {
            Write-Log -Severity 'Warning' -Message "Required Scheduled Job $Name State - $($ScheduledTask.State)"
            Write-Log -Severity 'Warning' -Message "Required Scheduled Job $Name Starting...."
            #Restart if Not Running
            $null = $Job | Remove-Job -Force
            $null = $ScheduledTask | Start-ScheduledTask
        }
        else {
            #Job Is Already Running
        }
        #Log Current State
        $ScheduledTask = Get-ScheduledTask -TaskName $Name -ErrorAction SilentlyContinue
        Write-Log -Severity 'Information' -Message "Required Scheduled Job $Name State - $($ScheduledTask.State)"        
    }
    #Write Error if Job Object does not Exist
    else {
        Write-Log -Severity 'Error' -Message "Required Scheduled Job $Name Not Found"
    }
}