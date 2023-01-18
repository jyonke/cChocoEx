function Test-IsWinOS.OOBE {
    param (
    
    )
    try {
        $ExplorerProcesses = Get-Process explorer -IncludeUserName -ErrorAction SilentlyContinue 
    }
    catch {
        Write-Verbose $_.Exception.Message
    }
    
    if ($ExplorerProcesses | Where-Object { ($_.UserName -split '\\' | Select-Object -Last 1) -eq 'defaultuser0' }) {
        return $true    
    }
    else {
        return $false
    }
}