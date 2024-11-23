# Request-cChocoExInit

## SYNOPSIS
Initializes the cChocoEx bootstrap task scheduler configuration.

## DESCRIPTION
This function manages the cChocoEx bootstrap task scheduler configuration by:
1. Checking for incompatible environments (Task Sequence, WinPE, etc.)
2. Managing existing bootstrap tasks
3. Registering and starting new bootstrap tasks

## SYNTAX

```powershell
Request-cChocoExInit
```

## EXAMPLES

### Example 1: Initialize the cChocoEx bootstrap task
```powershell
Request-cChocoExInit
```

Attempts to initialize the cChocoEx bootstrap task scheduler configuration.

## OUTPUTS
None. This function does not generate any output.

## NOTES
- The function includes several safety checks to prevent execution in inappropriate environments.
- Administrative rights are required for creating and managing scheduled tasks.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx) 