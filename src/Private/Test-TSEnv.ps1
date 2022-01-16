function Test-TSEnv {
    try {
        if (New-Object -ComObject Microsoft.SMS.TSEnvironment -ErrorAction Ignore) {
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