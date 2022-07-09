function Test-IsWinOS {
    param (
    )

    if (Test-IsWinPE) {
        return $false    
    }
    else {
        return $true
    }
}
