<#
.SYNOPSIS
Updates the cChocoEx PowerShell Module to the latest version

.DESCRIPTION
Updates the cChocoEx PowerShell Module to the latest version from the PowerShell Gallery
#>

function Update-cChocoEx {
    [CmdletBinding()]
    Param ()

    #Ensure Running as Administrator
    if (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Warning "This function requires elevated access, please reopen PowerShell as an Administrator"
        Break
    }
        
    try {
        Write-Warning "Uninstall-Module -Name cChocoEx -AllVersions -Force"
        Uninstall-Module -Name 'cChocoEx' -AllVersions -Force
    }
    catch {}

    try {
        Write-Warning "Find-Module cChocoEx | Sort-Object -Property Version -Descending | Install-Module -Force"
        Find-Module 'cChocoEx' | Sort-Object -Property 'Version' -Descending | Install-Module -Force
    }
    catch {}

    try {
        Write-Warning "Import-Module -Name cChocoEx -Force"
        Import-Module -Name 'cChocoEx' -Force
    }
    catch {}
}