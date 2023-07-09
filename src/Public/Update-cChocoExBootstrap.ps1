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
        [Parameter()]
        [string]
        $Uri = $env:cChocoExBootstrapUri
    )

    #Ensure Running as Administrator
    if ((Test-IsAdmin) -eq $false) {
        Write-Warning "This function requires elevated access, please reopen PowerShell as an Administrator"
        Break
    }

    #Ensure Uri is defined
    if ([String]::IsNullOrEmpty($Uri)) {
        Write-Warning "Uri Value not found, please pass as a parameter or set cChocoExBootstrapUri environment variable"
        Break
    }

    Write-Log -Severity 'Information' -Message "Checking for Bootstrap Updates" -NoOutput

    $Path = $env:cChocoExBootstrap
    $Updated = $false
    try {
        $wc = [System.Net.WebClient]::new()
        $FileHash = (Get-FileHash -Path $Path -ErrorAction SilentlyContinue).Hash
        $RemoteHash = (Get-FileHash -InputStream ($wc.OpenRead($Uri)) -ErrorAction SilentlyContinue).Hash  
    }
    catch {
        $Updated = $false
        $ErrorMessage = $_.Exception.Message
        Write-Log -Severity 'Warning' -Message $ErrorMessage
    }
    
    if ($FileHash -ne $RemoteHash) {
        try {
            Invoke-WebRequest -UseBasicParsing -Uri $Uri -OutFile $Path
            $Updated = $true
        }
        catch {
            $Updated = $false
            $ErrorMessage = $_.Exception.Message
            Write-Log -Severity 'Warning' -Message $ErrorMessage
        }
    }

    $object = [PSCustomObject]@{
        "Path"        = $Path
        "Uri"         = $Uri
        "File Hash"   = $FileHash
        "Remote Hash" = $RemoteHash
        "Updated"     = $Updated
    }

    Write-Log -Severity 'Information' -Message "Local Path: $Path" -NoOutput
    Write-Log -Severity 'Information' -Message "Uri: $Uri" -NoOutput
    Write-Log -Severity 'Information' -Message "File Hash: $FileHash" -NoOutput
    Write-Log -Severity 'Information' -Message "Remote Hash: $RemoteHash" -NoOutput
    Write-Log -Severity 'Information' -Message "Updated: $Updated" -NoOutput

    return $object

}