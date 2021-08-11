function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Information', 'Warning', 'Error')]
        [string]$Severity = 'Information',
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path = (Join-Path $LogPath "cChoco.log"),
        [Parameter()]
        [Switch]
        $New
    )
 
    $LegacyPath = (Join-Path -Path $env:ChocolateyInstall -ChildPath 'logs')
    $cChocoExLogFilesLegacy = Get-ChildItem -Path $LegacyPath -Filter 'cChoco*.log' -ErrorAction SilentlyContinue

    #Wipe if New Log needs to be started
    if ($New) {
        Remove-Item -Path $Path -Force
    }

    #Wipe Legacy Logs
    if ($cChocoExLogFilesLegacy) {
        $cChocoExLogFilesLegacy | Remove-Item -Force
    }
    
    switch ($Severity) {
        Information { $Color = "White" }
        Warning { $Color = "Yellow" }
        Error { $Color = "Red" }
        Default { $Color = "White" }
    }
    $Object = [pscustomobject]@{
        Time     = (Get-Date -f g)
        Severity = $Severity
        Message  = $Message
    }
    try {
        $Object | Export-Csv -Path $Path -Append -NoTypeInformation
    }
    catch {
        Write-Warning $_.Exception.Message
    }
    Write-Host "$($Object.Time) - $($Object.Severity) - $($Object.Message)" -ForegroundColor $Color
}