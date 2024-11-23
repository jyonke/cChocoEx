# Set-cChocoExRing

## SYNOPSIS
Sets Chocolatey DSC Configuration Deployment Ring Restriction in cChocoEx.

## DESCRIPTION
Sets Chocolatey DSC Configuration Deployment Ring Restriction in cChocoEx as a Registry Key.

## SYNTAX

```powershell
Set-cChocoExRing -Ring <String>
```

## PARAMETERS

### -Ring
Specifies the deployment ring to set. Valid values are:
- Preview
- Canary
- Pilot
- Fast
- Slow
- Broad
- Exclude

```powershell
Type: String
Parameter Sets: (All)
Required: True
```

## EXAMPLES

### Example 1: Set the deployment ring
```powershell
Set-cChocoExRing -Ring 'Broad'
```

Sets the Chocolatey deployment ring to 'Broad'.

## OUTPUTS
None.

## NOTES
- Administrative rights are required to modify the registry.
- The function checks if the script is running with elevated privileges.

## RELATED LINKS
- [cChocoEx Documentation](https://github.com/jyonke/cChocoEx) 