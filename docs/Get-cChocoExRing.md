# Get-cChocoExRing

## SYNOPSIS
Returns the current Chocolatey DSC Configuration Deployment Ring restriction in cChocoEx.

## DESCRIPTION
The `Get-cChocoExRing` function retrieves the current deployment ring setting from the registry. If a legacy registry path is found, it migrates the ring value to the new path. The function ensures that the ring value is valid and defaults to 'Broad' if no valid value is found.

## SYNTAX

```powershell
Get-cChocoExRing
```

## OUTPUTS

### String
Returns the current deployment ring as a string.

## EXAMPLES

### Example 1: Get the current deployment ring
```powershell
Get-cChocoExRing
```

Returns the current deployment ring value.

## NOTES
- The function checks for a legacy registry path and migrates the ring value if found.
- Valid ring values include: Preview, Canary, Pilot, Fast, Slow, Broad, Exclude.
- If no valid ring is found, the function defaults to 'Broad'.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx) 