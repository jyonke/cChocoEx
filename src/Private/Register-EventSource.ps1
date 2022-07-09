function Register-EventSource {
    [CmdletBinding()]
    param (
    )
    
    try {
        New-EventLog -LogName 'Application' -Source 'cChocoEx' -ErrorAction SilentlyContinue -ErrorVariable err
    }
    catch {}

    if ($err) {
        Write-Verbose $err.Exception.Message
    }
}