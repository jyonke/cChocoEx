<#
.SYNOPSIS
    Updates cChocoEX bootstrap file
.DESCRIPTION
    Compares the provided remote Uri filehash to the local boostrap.ps1 at the well known location of $env:ProgramData\cChocoEx\bootstrap.ps1.
.EXAMPLE
    PS C:\> Update-cChocoExBootstrap -Uri https://contoso.com/bootstrap.ps1
.INPUTS
    Uri: URL of the bootstrap that should be present on the local machine.
.OUTPUTS
    PSCustomObject
#>
function Update-cChocoExBootstrap {
    param (
        # URI of the bootstrap powershell script
        [Parameter(Mandatory = $true)]
        [string]
        $Uri
    )

    #Ensure Running as Administrator
    if (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Warning "This function requires elevated access, please reopen PowerShell as an Administrator"
        Break
    }
        
    try {
        $wc = [System.Net.WebClient]::new()
        $FileHash = (Get-FileHash -Path "$env:ProgramData\cChocoEx\bootstrap.ps1" -ErrorAction SilentlyContinue).Hash
        $RemoteHash = (Get-FileHash -InputStream ($wc.OpenRead($Uri)) -ErrorAction SilentlyContinue).Hash  
    }
    catch {
        $Updated = $false
        $ErrorMessage = $_.Exception.Message
    }
    if ($FileHash -ne $RemoteHash) {
        try {
            Invoke-WebRequest -UseBasicParsing -Uri $Uri -OutFile "$env:ProgramData\cChocoEx\bootstrap.ps1"
            $Updated = $true
        }
        catch {
            $Updated = $false
            $ErrorMessage = $_.Exception.Message
        }
    }
    [PSCustomObject]@{
        Path       = "$env:ProgramData\cChocoEx\bootstrap.ps1"
        Uri        = $Uri
        FileHash   = $Filehash
        RemoteHash = $RemoteHash
        Updated    = $Updated
        Error      = $ErrorMessage

    }
}