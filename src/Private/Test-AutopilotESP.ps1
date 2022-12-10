function Test-AutopilotESP {
    try {
        $Status = Get-AutoPilotStatus
    }
    catch {
        Write-Warning $_.Exception.Message
        continue
    }

    if ($Status.Complete -eq $true) {
        return $false
    }
    if ($Status.Complete -ne $true) {
        return $true
    }
}