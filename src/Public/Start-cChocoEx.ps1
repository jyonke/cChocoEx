<#
.SYNOPSIS
Bootstraps the cChoco PowerShell DSC Module

.DESCRIPTION
Bootstraps the cChoco PowerShell DSC Module
#>
function Start-cChocoEx {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $SettingsURI,
        # Chocolatey Installation Directory
        [Parameter()]
        [string]
        $InstallDir = "$env:ProgramData\chocolatey",
        # Chocolatey Installation Script URL
        [Parameter()]
        [string]
        $ChocoInstallScriptUrl = 'https://chocolatey.org/install.ps1',
        # URL to chocolatey nupkg
        [Parameter()]
        [string]
        $ChocoDownloadUrl,
        # URL to cChoco sources configuration file
        [Parameter()]
        [string]
        $SourcesConfig,
        # URL to cCHoco packages
        [Parameter()]
        [array]
        $PackageConfig,
        # URL to cChoco Chocolatey configuration file
        [Parameter()]
        [string]
        $ChocoConfig,
        # URL to cChoco Chocolatey features configuration file
        [Parameter()]
        [string]
        $FeatureConfig,
        # Do not cache configuration files
        [Parameter()]
        [switch]
        $NoCache,
        # Wipe locally cached psd1 configurations
        [Parameter()]
        [switch]
        $WipeCache,
        # RandomDelay
        [Parameter()]
        [switch]
        $RandomDelay,
        # Loop the Function
        [Parameter()]
        [Switch]
        $Loop,
        # Loop Delay in Minutes
        [Parameter()]
        [int]
        $LoopDelay = 60,
        # Legacy Migration Automation
        [Parameter()]
        [Switch]
        $MigrateLegacyConfigurations,
        # OverrideMaintenanceWindow
        [Parameter()]
        [switch]
        $OverrideMaintenanceWindow,
        # Enable Desktop Notifications
        [Parameter()]
        [Switch]
        $EnableNotifications
    )

    #Ensure Running as Administrator
    if (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Warning "This function requires elevated access, please reopen PowerShell as an Administrator"
        Break
    }   

    #Enable TLS 1.2
    #https://docs.microsoft.com/en-us/dotnet/api/system.net.securityprotocoltype?view=net-5.0
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

    #Set Global Variables
    Set-GlobalVariables
    $Global:MaintenanceWindowEnabled = $True
    $Global:MaintenanceWindowActive = $True
    $Global:TSEnv = Test-TSEnv
    $Global:EnableNotifications = $EnableNotifications

    #Ensure cChocoEx Data Folder Structure is Created
    Set-cChocoExFolders
    
    Write-Log -Severity 'Information' -Message "Starting cChocoEx"
    
    #Register cChocoEx Task
    Register-cChocoExTask

    #Ensure Registry Is Setup
    Set-RegistryConfiguration

    #Ensure cChocoEx Tasks are Running
    Start-cChocoExTask

    #Update Media Folder
    $null = Copy-Item -Path (Join-path -Path ($PSScriptRoot | Split-Path) -ChildPath 'Media\*') -Destination $cChocoExMediaFolder -Recurse -Force

    #Ensure cChoco Module Is Present and Available
    if (-not($ModuleBase)) {
        Write-Log -Severity 'Error' -Message 'Required Module cChoco Not Found'
        Break
    }

    if ($MigrateLegacyConfigurations) {
        Move-LegacyConfigurations
    }

    if ($OverrideMaintenanceWindow) {
        $Global:OverrideMaintenanceWindow = $True
        Write-Log -Severity 'Information' -Message 'Global OverrideMaintenanceWindow Enabled'
    }
    else {
        $Global:OverrideMaintenanceWindow = $False
    }

    #Ensure Notification Prerequisites are Installed and Imported
    if ($Global:EnableNotifications) {
        $OSMajorVersion = (Get-CimInstance -ClassName Win32_OperatingSystem -Property Version).Version.Split('.')[0]
        if ([int]$OSMajorVersion -lt 10) {
            Write-Log -Severity 'Warning' -Message 'Notifications Require Windows 10 or Server 2016 and Greater'
            $Global:EnableNotifications = $false
        }
        else {
            Install-BurntToast
            Install-RunAsUser    
        }
    }
    
    #Log Task Sequence Detection
    Write-Log -Severity 'Information' -Message "Task Sequence Environemnt Detected: $TSEnv"

    #cChocoInstaller
    $Configuration = @{
        InstallDir            = $InstallDir
        ChocoInstallScriptUrl = $ChocoInstallScriptUrl
    }
            
    Start-cChocoInstaller -Configuration $Configuration

    $CurrentExecutionPolicy = Get-ExecutionPolicy
    try {
        $null = Set-ExecutionPolicy Bypass -Scope CurrentUser
    }
    catch {
        Write-Log -Severity 'Warning' -Message "Error Changing Execution Policy"
    }

    try {
        Write-Log -Severity 'Information' -Message 'cChocoEx Started'
    }
    catch {
        Write-Warning "Error Starting Log, wiping and retrying"
        Write-Log -Severity 'Information' -Message 'cChoco Bootstrap Started' -New

    }

    #Evaluate Random Delay Switch
    if ($RandomDelay) {
        $RandomSeconds = Get-Random -Minimum 0 -Maximum 1800
        Write-Log -Severity 'Information' -Message "Random Delay Enabled"
        Write-Log -Severity 'Information' -Message "Delay: $RandomSeconds`s"
        Start-Sleep -Seconds $RandomSeconds
    }

    #Settings
    if ($SettingsURI) {
        $Destination = (Join-Path $cChocoExTMPConfigurationFolder "bootstrap-cchoco.psd1")

        try {
            Write-Log -Severity 'Information' -Message "Downloading SettingsURI File"
            Write-Log -Severity 'Information' -Message "Source: $SettingsURI"
            Write-Log -Severity 'Information' -Message "Destination: $Destination"

            switch (Test-PathEx -Path $SettingsURI) {
                'URL' { Invoke-WebRequest -Uri $SettingsURI -UseBasicParsing -OutFile $Destination }
                'FileSystem' { Copy-Item -Path $SettingsURI -Destination $Destination -Force }
            }        
        }
        catch {
            Write-Log -Severity 'Warning' -Message $_.Exception.Message
        }
        $SettingsFile = Import-PowerShellDataFile -Path $Destination
        $Settings = $SettingsFile | ForEach-Object { $_.Keys | ForEach-Object { $SettingsFile.$_ } } 
    
        #Variables
        $InstallDir = $Settings.InstallDir
        $ChocoInstallScriptUrl = $Settings.ChocoInstallScriptUrl
        $SourcesConfig = $Settings.SourcesConfig
        $PackageConfig = $Settings.PackageConfig
        $ChocoConfig = $Settings.ChocoConfig
        $FeatureConfig = $Settings.FeatureConfig
    }

    Write-Log -Severity 'Information' -Message "cChocoEx Settings"
    Write-Log -Severity 'Information' -Message "SettingsURI: $SettingsURI"
    Write-Log -Severity 'Information' -Message "InstallDir: $InstallDir"
    Write-Log -Severity 'Information' -Message "ChocoInstallScriptUrl: $ChocoInstallScriptUrl"
    Write-Log -Severity 'Information' -Message "SourcesConfig: $SourcesConfig"
    Write-Log -Severity 'Information' -Message "PackageConfig: $PackageConfig"
    Write-Log -Severity 'Information' -Message "ChocoConfig: $ChocoConfig"
    Write-Log -Severity 'Information' -Message "FeatureConfig: $FeatureConfig"

    #Set Enviromental Variable for chocolatey url to nupkg
    $env:chocolateyDownloadUrl = $ChocoDownloadUrl

    if ($WipeCache) {
        Write-Log -Severity 'Information' -Message 'WipeCache Enabled. Wiping any previously downloaded psd1 configuration files'
        Get-ChildItem -Path $cChocoExConfigurationFolder -Filter *.psd1 | Remove-Item -Recurse -Force
    }
    #Preclear any previously downloaded NoCache configuration files
    if ($NoCache) {
        Write-Log -Severity 'Information' -Message 'NoCache Enabled. Wiping any previously downloaded NoCache configuration files from temp'
        Get-ChildItem -Path $cChocoExTMPConfigurationFolder -Filter *.psd1 | Remove-Item -Recurse -Force
    }

    #Copy Config Config?
    $Global:ChocoConfigDestination = (Join-Path $cChocoExConfigurationFolder "config.psd1")
    if ($ChocoConfig) {
        if ($NoCache) {
            $Global:ChocoConfigDestination = (Join-Path $cChocoExTMPConfigurationFolder "config.psd1")
        }

        try {
            Write-Log -Severity 'Information' -Message "Downloading Choco Config File"
            Write-Log -Severity 'Information' -Message "Source: $ChocoConfig"
            Write-Log -Severity 'Information' -Message "Destination: $ChocoConfigDestination"

            switch (Test-PathEx -Path $ChocoConfig) {
                'URL' { Invoke-WebRequest -Uri $ChocoConfig -UseBasicParsing -OutFile $ChocoConfigDestination }
                'FileSystem' { Copy-Item -Path $ChocoConfig -Destination $ChocoConfigDestination -Force }
            } 
            Write-Log -Severity 'Information' -Message 'Chocolatey Config File Set.'   
        }
        catch {
            Write-Log -Severity 'Warning' -Message $_.Exception.Message
        }
    }

    #Copy Sources Config
    $Global:SourcesConfigDestination = (Join-Path $cChocoExConfigurationFolder "sources.psd1")
    if ($SourcesConfig) {
        if ($NoCache) {
            $Global:SourcesConfigDestination = (Join-Path $cChocoExTMPConfigurationFolder "sources.psd1")
        }

        try {
            Write-Log -Severity 'Information' -Message "Downloading Source Config File"
            Write-Log -Severity 'Information' -Message "Source: $SourcesConfig"
            Write-Log -Severity 'Information' -Message "Destination: $SourcesConfigDestination"

            switch (Test-PathEx -Path $SourcesConfig) {
                'URL' { Invoke-WebRequest -Uri $SourcesConfig -UseBasicParsing -OutFile $SourcesConfigDestination }
                'FileSystem' { Copy-Item -Path $SourcesConfig -Destination $SourcesConfigDestination -Force }
            }
            Write-Log -Severity 'Information' -Message 'Chocolatey Sources File Set.'
        }
        catch {
            Write-Log -Severity 'Warning' -Message $_.Exception.Message
        }
    }

    #Copy Features Config
    $Global:FeatureConfigDestination = (Join-Path $cChocoExConfigurationFolder "features.psd1")
    if ($FeatureConfig) {
        if ($NoCache) {
            $Global:FeatureConfigDestination = (Join-Path $cChocoExTMPConfigurationFolder "features.psd1")
        }
        try {
            Write-Log -Severity 'Information' -Message "Downloading Feature Config File"
            Write-Log -Severity 'Information' -Message "Source: $FeatureConfig"
            Write-Log -Severity 'Information' -Message "Destination: $FeatureConfigDestination"

            switch (Test-PathEx -Path $FeatureConfig) {
                'URL' { Invoke-WebRequest -Uri $FeatureConfig -UseBasicParsing -OutFile $FeatureConfigDestination }
                'FileSystem' { Copy-Item -Path $FeatureConfig -Destination $FeatureConfigDestination -Force }
            }
            Write-Log -Severity 'Information' -Message 'Chocolatey Feature File Set.'
        }
        catch {
            Write-Log -Severity 'Warning' -Message $_.Exception.Message
        }
    }

    #Copy Package Config
    $Global:PackageConfigDestination = $cChocoExConfigurationFolder
    if ($PackageConfig) {
        if ($NoCache) {
            $Global:PackageConfigDestination = $cChocoExTMPConfigurationFolder
        }
        $PackageConfig | ForEach-Object {
            $Path = $_
            $Destination = (Join-Path $PackageConfigDestination ($_ | Split-Path -Leaf))

            try {
                Write-Log -Severity 'Information' -Message "Downloading Package Config File"
                Write-Log -Severity 'Information' -Message "Source: $Path"
                Write-Log -Severity 'Information' -Message "Destination: $Destination"

                switch (Test-PathEx -Path $_) {
                    'URL' { Invoke-WebRequest -Uri $Path -UseBasicParsing -OutFile $Destination }
                    'FileSystem' { Copy-Item -Path $Path -Destination $Destination -Force }
                }
                Write-Log -Severity 'Information' -Message 'Chocolatey Package File Set.'
            }
            catch {
                Write-Log -Severity 'Warning' -Message $_.Exception.Message
            }
        }
    }

    #cChocoConfig
    if (Test-Path $ChocoConfigDestination ) {
        $ConfigImport = $null
        $ConfigImport = Import-PowerShellDataFile $ChocoConfigDestination
        Start-cChocoConfig -ConfigImport $ConfigImport
    }
    else {
        Write-Log -Severity 'Information'  -Message "File not found, configuration will not be modified"
    }

    #cChocoFeature
    if (Test-Path $FeatureConfigDestination ) {
        $ConfigImport = $null
        $ConfigImport = Import-PowerShellDataFile $FeatureConfigDestination
        Start-cChocoFeature -ConfigImport $ConfigImport
    }
    else {
        Write-Log -Severity 'Information' -Message "File not found, features will not be modified"
    }

    #cChocoSource
    if (Test-Path $SourcesConfigDestination ) {
        $ConfigImport = $null
        $ConfigImport = Import-PowerShellDataFile $SourcesConfigDestination
        Start-cChocoSource -ConfigImport $ConfigImport
    }
    else {
        Write-Log -Severity 'Information' -Message "File not found, sources will not be modified"
    }

    #cChocoPackageInstall
    [array]$Configurations = $null
    Get-ChildItem -Path $PackageConfigDestination -Filter *.psd1 | Where-Object { $_.Name -notmatch "sources.psd1|config.psd1|features.psd1" } | ForEach-Object {
        $ConfigImport = $null
        $ConfigImport = Import-PowerShellDataFile $_.FullName 
        $Configurations += $ConfigImport | ForEach-Object { $_.Keys | ForEach-Object { $ConfigImport.$_ } }
    }

    if ($Configurations ) {
        Start-cChocoPackageInstall -Configurations $Configurations
    }
    else {
        Write-Log -Severity 'Information' -Message "File not found, packages will not be modified"
    }
    
    #Cleanup
    #Preclear any previously downloaded NoCache configuration files
    if ($NoCache) {
        Write-Log -Severity "Information" -Message "Preclear any previously downloaded NoCache configuration files"
        Get-ChildItem -Path $cChocoExTMPConfigurationFolder -Filter *.psd1 | Remove-Item -Recurse -Force
    }

    #Register cChocoEx BootStrap Task if Enabled
    if ($Loop -and (-not($TSEnv))) {
        Write-Log -Severity "Information" -Message "Function Looping Enabled"
        Write-Log -Severity "Information" -Message "Looping Delay: $LoopDelay Minutes"
        Register-cChocoExBootStrapTask -LoopDelay $LoopDelay
    }

    $null = Set-ExecutionPolicy $CurrentExecutionPolicy -Scope CurrentUser -ErrorAction SilentlyContinue
    RotateLog
}