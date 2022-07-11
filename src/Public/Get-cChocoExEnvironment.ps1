function Get-cChocoExEnvironment {
    [CmdletBinding()]
    param(

    )

    process {
        $Ring = Get-cChocoExRing

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

        $LastReboot = Get-CimInstance -ClassName win32_operatingsystem | Select-Object -ExpandProperty lastbootuptime
        $Uptime = "{0:dd}d:{0:hh}h:{0:mm}m:{0:ss}s" -f (New-TimeSpan -Start $LastReboot -End (Get-Date))

        $PSCustomObject = [PSCustomObject]@{
            OSEnvironment                  = $OSEnv
            ModuleBase                     = $Global:ModuleBase
            cChocoExDataFolder             = $Global:cChocoExDataFolder
            cChocoExConfigurationFolder    = $Global:cChocoExConfigurationFolder
            cChocoExTMPConfigurationFolder = $Global:cChocoExTMPConfigurationFolder
            LogPath                        = $Global:LogPath
            cChocoExMediaFolder            = $Global:cChocoExMediaFolder
            Ring                           = $Ring
            ChocolateyInstall              = $env:ChocolateyInstall
            LastReboot                     = $LastReboot
            Uptime                         = $Uptime
        }
        return $PSCustomObject
    }
}