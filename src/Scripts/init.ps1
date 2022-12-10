#requires -Modules cChocoEx

$TaskName = 'cChocoExInit'
$TaskPath = '\cChocoEx\'

#Restrictions
if ((Test-TSEnv) -eq $true) {
    return
}
if ((Test-AutopilotESP) -eq $true) {
    return
}
if ((Test-IsWinPe) -eq $true) {
    return
}
if ((Test-IsWinOs.OOBE) -eq $true) {
    return
}
if ((Test-IsWinSE) -eq $true) {
    return
}

#Removal
if (Get-ScheduledTask -TaskName 'cChocoExBootstrapTask') {
    Write-Warning 'cChocoExBootstrapTask already setup'
    Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$false
    exit 0
}

#Register cChocoEx DSC Task
Register-cChocoExBootStrapTask