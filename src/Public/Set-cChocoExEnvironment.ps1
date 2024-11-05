function Set-cChocoExEnvironment {
    <#
    .SYNOPSIS
        Initializes and configures the cChocoEx environment.

    .DESCRIPTION
        Sets up the required environment for cChocoEx by performing the following tasks:
        - Sets global variables
        - Sets environmental variables
        - Creates necessary folder structure (requires admin)
        - Configures registry settings (requires admin)
        - Sets up event log sources (requires admin)

        If not running with administrative privileges, the function will warn
        the user about incomplete initialization.

    .EXAMPLE
        Set-cChocoExEnvironment
        Initializes the cChocoEx environment. Must be run as administrator for full functionality.

    .OUTPUTS
        None. This function does not generate any output.

    .NOTES
        Author: Jon Yonke
        Version: 1.0
        Created: 2024-02-11
        
        Required Functions:
        - Set-GlobalVariables
        - Set-EnvironmentalVariables
        - Test-IsAdmin
        - Set-cChocoExFolders
        - Set-RegistryConfiguration
        - Register-EventSource

        Required Permissions:
        - Administrative rights required for full initialization
        - Limited functionality available without admin rights

        Environment Variables:
        - Global:cChocoExDataFolder
    #>
    [CmdletBinding()]
    param()

    #Ensure cChocoEx Variables are Created
    Set-GlobalVariables
    Set-EnvironmentalVariables

    if ((Test-IsAdmin) -eq $true) {
        #Ensure cChocoEx Data Folder Structure is Created
        Set-cChocoExFolders

        #Ensure Registry Is Setup
        Set-RegistryConfiguration

        #Ensure EventLog Sources are Setup
        Register-EventSource
    }
    if ((Test-IsAdmin) -eq $false) {
        if ((-not(Test-Path -Path $Global:cChocoExDataFolder)) -or (-not(Test-Path -Path "HKLM:\Software\cChocoEx\"))) {
            Write-Warning "cChocoEx requires elevated access, please reopen PowerShell as an Administrator to finalize initialization"
        }
    }
}