function Test-TSEnv {
    <#
    .SYNOPSIS
        Tests if the current session is running within a Task Sequence environment.

    .DESCRIPTION
        Checks for the presence of the Microsoft Task Sequence environment using multiple methods:
        1. Checks for TSProgressUI process
        2. Verifies _SMSTSEnv environment variable
        
        Any of these conditions indicate we're running in a Task Sequence.

    .EXAMPLE
        Test-TSEnv
        Returns $true if running within a Task Sequence, $false otherwise.

    .OUTPUTS
        [bool]
        Returns $true when running in a Task Sequence environment, $false otherwise.

    .NOTES
        Author: Jon Yonke
        Version: 1.2
        Created: 2024-11-02
        Modified: Current Date
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    try {
        Write-Verbose "Checking for Task Sequence environment"
        
        # Method 1: Check for TSProgressUI process
        if (Get-Process -Name "TSProgressUI" -ErrorAction SilentlyContinue) {
            Write-Verbose "Task Sequence detected via TSProgressUI process"
            return $true
        }

        # Method 2: Check for _SMSTSEnv variable
        if (Test-Path -Path 'env:_SMSTSEnv') {
            Write-Verbose "Task Sequence detected via environment variable"
            return $true
        }

        Write-Verbose "No Task Sequence environment detected"
        return $false
    }
    catch {
        Write-Warning "Error checking Task Sequence environment: $_"
        return $false
    }
}