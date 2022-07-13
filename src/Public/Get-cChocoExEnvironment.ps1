function Get-cChocoExEnvironment {
    [CmdletBinding()]
    param(

    )

    process {
        $Ring = Get-cChocoExRing
        $TSEnv = $null

        if (Test-isWinOS) {
            $OSEnv = 'Windows Operating System'
        }
        if (Test-isWinOS.OOBE) {
            $OSEnv = 'Windows Operating System Out of Box Experiance'
        }
        if (Test-isWinPE) {
            $OSEnv = 'Windows Preinstallation Environment'
        }
        if (Test-IsWinSE) {
            $OSEnv = 'Windows Setup Environment'
        }
        if (Test-TSEnv) {
            $TSEnv = $true
        }

        $LastReboot = Get-CimInstance -ClassName win32_operatingsystem | Select-Object -ExpandProperty lastbootuptime
        $Uptime = "{0:dd}d:{0:hh}h:{0:mm}m:{0:ss}s" -f (New-TimeSpan -Start $LastReboot -End (Get-Date))
        $ChocoVersion = Get-Item -Path (Join-Path $env:ChocolateyInstall 'choco.exe') -ErrorAction SilentlyContinue | Select-Object -ExpandProperty VersionInfo | Select-Object -ExpandProperty ProductVersion

        $PSCustomObject = [PSCustomObject]@{
            OSEnvironment                  = $OSEnv
            ModuleBase                     = $Global:ModuleBase
            cChocoExDataFolder             = $Global:cChocoExDataFolder
            cChocoExConfigurationFolder    = $Global:cChocoExConfigurationFolder
            cChocoExTMPConfigurationFolder = $Global:cChocoExTMPConfigurationFolder
            LogPath                        = $Global:LogPath
            cChocoExMediaFolder            = $Global:cChocoExMediaFolder
            Ring                           = $Ring
            TSEnv                          = $TSEnv
            ChocolateyInstall              = $env:ChocolateyInstall
            ChocolateyVersion              = $ChocoVersion
            LastReboot                     = $LastReboot
            Uptime                         = $Uptime
        }
        return $PSCustomObject
    }
}