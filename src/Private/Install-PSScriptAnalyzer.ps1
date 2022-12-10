function Install-PSScriptAnalyzer {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        #Variables
        $Name = 'PSScriptAnalyzer'
        $MinimumVersion = '1.21.0'
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
            Write-Error "Failed to Import Module $Name - $MinimumVersion"
            Write-Error "$($_.Exception.Message)"
        }
    }
}