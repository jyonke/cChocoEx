function Test-IsWinOS.OOBE {
    <#
    .SYNOPSIS
        Tests if Windows is currently in the Out-of-Box Experience (OOBE) state.

    .DESCRIPTION
        Uses the Windows kernel32.dll OOBEComplete API to determine if the system
        is currently in OOBE state. Returns $true if the system is in OOBE,
        $false otherwise.

    .EXAMPLE
        Test-IsWinOSOOBE
        Returns $true if the system is currently in OOBE state.

    .OUTPUTS
        [bool]
        Returns $true when system is in OOBE state, $false otherwise.

    .NOTES
        Based on code from: https://oofhours.com/2023/09/15/detecting-when-you-are-in-oobe/
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    try {
        $TypeDef = @"
 
using System;
using System.Text;
using System.Collections.Generic;
using System.Runtime.InteropServices;
 
namespace Api
{
 public class Kernel32
 {
   [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
   public static extern int OOBEComplete(ref int bIsOOBEComplete);
 }
}
"@
 
        Add-Type -TypeDefinition $TypeDef -Language CSharp
 
        $IsOOBEComplete = $false
        $hr = [Api.Kernel32]::OOBEComplete([ref] $IsOOBEComplete)
 
        return (-Not $IsOOBEComplete)
    }
    catch {
        Write-Error "An error occurred while checking if the system is in OOBE state: $_"
        return $false
    }
}