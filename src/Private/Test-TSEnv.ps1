function Test-TSEnv {
    try {
        if (New-Object -ComObject Microsoft.SMS.TSEnvironment) {
            return $true
        }
        else {
            return $false
        }
    }
    catch {
        return $false
    }
}