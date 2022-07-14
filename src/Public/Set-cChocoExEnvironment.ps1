function Set-cChocoExEnvironment {
    param (
        
    )
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