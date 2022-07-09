function Test-IsWinPE {
    param (
        
    )
    if ($env:SystemDrive -eq 'X:') {
        return $true
    }
    else {
        return $false
    }
    
}