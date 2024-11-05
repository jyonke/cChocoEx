function Get-LoggedInUser {
    <#
    .SYNOPSIS
        Gets information about currently logged-in users on the local system.
    
    .DESCRIPTION
        Retrieves information about logged-in users by enumerating explorer.exe processes
        and identifying their owners. This function only works on the local system.
    
    .EXAMPLE
        Get-LoggedInUser
        Returns all logged-in users on the local system with their login time.
    
    .OUTPUTS
        [PSCustomObject] with properties:
        - UserName: The domain and username in "Domain\User" format
        - CreationDate: The date and time when the user's session started
    
    .NOTES
        Author: Your Name
        Version: 2.0
        Updated: Current Date
    #>
    
    [CmdletBinding()]
    param()
    
    Write-Verbose "Getting explorer.exe processes for logged-in users"
    
    try {
        $processList = Get-CimInstance Win32_Process -Filter 'Name="explorer.exe"'
        
        foreach ($process in $processList) {
            $owner = Invoke-CimMethod -InputObject $process -MethodName GetOwner
            
            [PSCustomObject][ordered]@{
                UserName     = '{0}\{1}' -f $owner.Domain, $owner.User
                CreationDate = $process.CreationDate
            }
        }
    }
    catch {
        Write-Warning "Failed to get logged-in user information: $_"
    }
}