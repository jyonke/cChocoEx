function Get-cChocoExEnvironment {
    [CmdletBinding()]
    param(

    )

    process {
        $Ring = Get-cChocoExRing

        if (Test-isWinOS) {
            $OSEnv = 'WinOS'
        }
        if (Test-isWinOS.OOBE) {
            $OSEnv = 'OOBE'
        }
        if (Test-isWinPE) {
            $OSEnv = 'WinPE'
        }
        if (Test-IsWinSE) {
            $OSEnv = 'WinSE'
        }

        $LastReboot = Get-CimInstance -ClassName win32_operatingsystem | Select-Object -ExpandProperty lastbootuptime
        $Uptime = "{0:dd}d:{0:hh}h:{0:mm}m:{0:ss}s" -f (New-TimeSpan -Start $LastReboot -End (Get-Date))
        if ($env:ChocolateyInstall) {
            $ChocoVersion = Get-Item -Path (Join-Path $env:ChocolateyInstall 'choco.exe') -ErrorAction SilentlyContinue | Select-Object -ExpandProperty VersionInfo | Select-Object -ExpandProperty ProductVersion
        }
        $VPNActive = Get-VPN -Active
        $TSEnv = Test-TSEnv
        $OOBE = Test-IsWinOS.OOBE
        $Win32_OperatingSystem = Get-CimInstance Win32_OperatingSystem

        $PSCustomObject = [PSCustomObject]@{
            OS                             = $Win32_OperatingSystem.Caption
            OSVersion                      = $Win32_OperatingSystem.Version
            OSEnvironment                  = $OSEnv
            ModuleBase                     = $env:cChocoModuleBase
            cChocoExDataFolder             = $env:cChocoExDataFolder
            cChocoExConfigurationFolder    = $env:cChocoExConfigurationFolder
            cChocoExTMPConfigurationFolder = $env:cChocoExTMPConfigurationFolder
            cChocoExBootstrap              = $env:cChocoExBootstrap
            cChocoExBootstrapUri           = $env:cChocoExBootstrapUri
            cChocoExChocoConfig            = $env:cChocoExChocoConfig
            cChocoExSourcesConfig          = $env:cChocoExSourcesConfig
            cChocoExPackageConfig          = $env:cChocoExPackageConfig
            cChocoExFeatureConfig          = $env:cChocoExFeatureConfig
            cChocoExLogPath                = $env:cChocoExLogPath
            cChocoExMediaFolder            = $env:cChocoExMediaFolder
            ChocoDownloadUrl               = $env:ChocoDownloadUrl
            ChocoInstallScriptUrl          = $env:ChocoInstallScriptUrl
            Ring                           = $Ring
            TSEnv                          = $TSEnv
            OOBE                           = $OOBE
            VPNActive                      = $VPNActive
            ChocolateyInstall              = $env:ChocolateyInstall
            ChocolateyVersion              = $ChocoVersion
            LastReboot                     = $LastReboot
            Uptime                         = $Uptime
        }
        return $PSCustomObject
    }
}