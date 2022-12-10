function Get-cChocoExTasks {
    [CmdletBinding()]
    param (
        
    )
    
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