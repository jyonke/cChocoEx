function Test-IsChocoActive {
    param ()
    $Process = Get-Process -Name choco -ErrorAction SilentlyContinue

    if ($Process) {
        return $true    
    }
    else {
        return $false
    }
}