function Get-cChocoExTasks {
    <#
    .SYNOPSIS
        Retrieves information about cChocoEx scheduled tasks.

    .DESCRIPTION
        Gets detailed information about all scheduled tasks in the cChocoEx task path,
        including their state, last run time, and next scheduled run.

    .EXAMPLE
        Get-cChocoExTasks
        Returns information about all cChocoEx scheduled tasks.

    .OUTPUTS
        [PSCustomObject[]] Array of task information objects with properties:
        - Name: Task name
        - State: Current state of the task
        - Description: Task description
        - LastRunTime: Last execution time
        - LastTaskResult: Result of last execution
        - NextRunTime: Next scheduled execution time

    .NOTES
        Author: Jon Yonke
        Version: 1.2
        Created: 2024-11-02
    #>
    [CmdletBinding()]
    param()
    
    begin {
        $Tasks = Get-ScheduledTask -TaskPath \cChocoEx\ -ErrorAction SilentlyContinue
    }
    
    process {
        if (-not ($Tasks)) {
            Write-Warning 'No cChocoEx Tasks Found'
            return
        }
        $Tasks | ForEach-Object {
            $TaskInfo = $PSItem | Get-ScheduledTaskInfo
            [PSCustomObject]@{
                Name           = $PSItem.TaskName
                State          = $PSItem.State
                Description    = $PSItem.Description
                LastRunTime    = $TaskInfo.LastRunTime
                LastTaskResult = $TaskInfo.LastTaskResult
                NextRunTime    = $Taskinfo.NextRunTime

            }
        }
    }
    
    end {
        
    }
}