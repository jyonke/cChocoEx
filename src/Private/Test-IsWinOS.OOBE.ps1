function Test-IsWinOS.OOBE {
    param (
    
    )
    $ExplorerProcesses = Get-Process explorer -IncludeUserName -ErrorAction SilentlyContinue
    
    if (    $ExplorerProcesses | Where-Object { ($_.UserName -split '\\' | Select-Object -Last 1) -eq 'defaultuser0' }) {
        return $true    
    }
    else {
        return $false
    }
}