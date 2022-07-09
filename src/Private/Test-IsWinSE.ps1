function Test-IsWinSE {
    param (
        
    )
    if ((Test-IsWinPE) -and (Test-Path 'X:\Setup.exe')) {
        return $true
    }
    else {
        return $false
    }
}