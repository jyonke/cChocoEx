function Test-IsAdmin {
    param (
        
    )
    #Ensure Running as Administrator
    if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        return $true
    }
    else {
        return $false
    }
}