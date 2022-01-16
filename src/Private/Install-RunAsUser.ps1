function Install-RunAsUser {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        #Variables
        $Name = 'RunAsUser'
        $MinimumVersion = '2.2'
    }
    
    process {
        #Check Module
        $Test = Get-Module -Name $Name -ListAvailable | Where-Object { [version]$_.Version -ge [version]$MinimumVersion }
        if (-Not($Test)) {
            #Install Module
            Find-Module -Name $Name -MinimumVersion $MinimumVersion | Install-Module -Force
        }
    }
    
    end {
        #Confirm Module if needed
        try {
            Import-Module -Name $Name -MinimumVersion $MinimumVersion -Force
        }
        catch {
            Write-Log -Severity 'Error' -Message "Failed to Import Module $Name - $MinimumVersion"
            Write-Log -Severity 'Error' -Message "$($_.Exception.Message)"
        }
    }
}