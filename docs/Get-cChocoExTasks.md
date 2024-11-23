# Get-cChocoExTasks

## SYNOPSIS
Retrieves information about cChocoEx scheduled tasks.

## DESCRIPTION
The `Get-cChocoExTasks` function retrieves detailed information about all scheduled tasks in the cChocoEx task path, including their state, last run time, and next scheduled run.

## SYNTAX

```powershell
Get-cChocoExTasks
```

## OUTPUTS

### PSCustomObject[]
Returns an array of task information objects with the following properties:
- Name: Task name
- State: Current state of the task
- Description: Task description
- LastRunTime: Last execution time
- LastTaskResult: Result of last execution
- NextRunTime: Next scheduled execution time

## EXAMPLES

### Example 1: Get all cChocoEx scheduled tasks
```powershell
Get-cChocoExTasks
```

Returns information about all cChocoEx scheduled tasks.

## NOTES
- If no tasks are found, a warning is displayed.
- The function retrieves tasks from the scheduled task path `\cChocoEx\`.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx) 