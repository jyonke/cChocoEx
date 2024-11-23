# Register-cChocoExBootStrapTask

## SYNOPSIS
Creates a PowerShell Task that runs as SYSTEM to automatically run cChocoEx bootstrap continuously.

## DESCRIPTION
If no `bootstrap.ps1` script is present at `$env:ProgramData\cChocoEx\bootstrap.ps1`, a minimal one will be copied to use.

## SYNTAX

```powershell
Register-cChocoExBootStrapTask -LoopDelay <Int>
```

## PARAMETERS

### -LoopDelay
Specifies the delay in minutes between task executions.

```powershell
Type: Int
Parameter Sets: (All)
Required: False
Default value: 90
```

## EXAMPLES

### Example 1: Register the bootstrap task with a loop delay
```powershell
Register-cChocoExBootStrapTask -LoopDelay 180
```

Creates a PowerShell task that will execute `$env:ProgramData\cChocoEx\bootstrap.ps1` every 180 minutes and at startup.

## OUTPUTS
None.

## NOTES
- The function checks for incompatible environments (e.g., Task Sequence, WinPE) before registering the task.
- If the `bootstrap.ps1` file does not exist, a minimal version will be copied from the scripts directory.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx) 