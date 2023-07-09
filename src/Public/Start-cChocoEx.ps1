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
        $EnableNotifications,
        # Set machine enviroment variables
        [Parameter()]
        [switch]
        $SetcChocoExEnvironment
    )

    #Ensure Running as Administrator
    if (-Not (Test-IsAdmin)) {
        Write-Warning "This function requires elevated access, please reopen PowerShell as an Administrator"
        Break
    }   
    
    #Enable TLS 1.2
    #https://docs.microsoft.com/en-us/dotnet/api/system.net.securityprotocoltype?view=net-5.0
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

    #Set Notifications Variable
    $Global:EnableNotifications = $EnableNotifications

    #Default Maintenance Windows Active and Enabled
    $Global:MaintenanceWindowEnabled = $true 
    $Global:MaintenanceWindowActive = $true


    #Validate Current Execution Policy
    $CurrentExecutionPolicy = Get-ExecutionPolicy
    try {
        $null = Set-ExecutionPolicy Bypass -Scope CurrentUser
    }
    catch {
        Write-Log -Severity 'Warning' -Message "Error Changing Execution Policy"
    }

    #Exclude Machines Set to Exclude Ring
    if ((Get-cChocoExRing) -eq 'Exclude') {  
        Write-Log -Severity 'Information' -Message 'This machine is set to the Exclude Ring. cChocoEx Stopped'
        Break
    }

    #Ensure cChocoExBootStrapTask is not running
    $PendingFile = Join-Path $env:cChocoExDataFolder '.cChocoExPending'
    if (Test-Path -Path $PendingFile) {
        #Autoremove is older than 24 hours
        if ((Get-Item -Path $PendingFile).CreationTime -lt (Get-Date).AddDays(-1)) {
            Write-Log -Severity 'Warning' -Message 'Stale cChocoEx pending file found, removing'
            Remove-Item -Path $PendingFile -Force
        }
    }
    if (Test-Path -Path $PendingFile) {
        Write-Log -Severity 'Warning' -Message 'cChocoEx pending completion, please wait until it finishes to invoke again'
        break
    }
    Set-Content -Path $PendingFile -Value '' -Force

    #Ensure choco.exe is not active
    $i = 0
    do {
        $IsChocoActive = Test-IsChocoActive
        if ($i -eq 1) {
            Write-Log -Severity 'Information' -Message 'Choco.exe is active, waiting up to 300 seconds'
        }
        if ($i -gt 0) {
            Start-Sleep -Seconds 1        
        }
        $i++
    } until (
        ($IsChocoActive -eq $False) -or ($i -gt 300)
    )
    if (Test-IsChocoActive) {
        Write-Log -Severity 'Information' -Message 'Choco.exe is active, cChocoEx Stopped'
        Break
    }

    #Log Start
    try {
        Write-Log -Severity 'Information' -Message 'cChocoEx Started'
        Write-EventLog -LogName 'Application' -Source 'cChocoEx' -EventId 4000 -EntryType Information -Message 'cChocoEx Started'
    }
    catch {
        Write-Warning "Error Starting Log, wiping and retrying"
        Write-Log -Severity 'Information' -Message 'cChoco Bootstrap Started' -New
        Write-EventLog -LogName 'Application' -Source 'cChocoEx' -EventId 4000 -EntryType Information -Message 'cChocoEx Started'
    }
    
    #Register and Start cChocoEx Task
    Register-cChocoExTask

    #Update Media Folder
    $null = Copy-Item -Path (Join-Path -Path ($PSScriptRoot | Split-Path) -ChildPath 'Media\*') -Destination $cChocoExMediaFolder -Recurse -Force

    #Ensure cChoco Module Is Present and Available
    if (-not($ModuleBase)) {
        Write-Log -Severity 'Error' -Message 'Required Module cChoco Not Found'
        Break
    }

    #Migrate Legacy Configuration Files
    if ($MigrateLegacyConfigurations) {
        Move-LegacyConfigurations
    }

    #Evaluate Mainteance Window Override
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
    
    #####################################
    #   Gather Environment Variables
    #####################################
        
    #ChocoInstallScriptUrl
    if ($env:ChocoInstallScriptUrl) {
        Write-Log -Severity 'Information' -Message "Environment Variable `$env:ChocoInstallScriptUrl: $env:ChocoInstallScriptUrl"
        $ChocoInstallScriptUrl = $env:ChocoInstallScriptUrl
    }
    #ChocoDownloadUrl
    if ($env:ChocoDownloadUrl -and ([string]::IsNullOrEmpty($ChocoDownloadUrl))) {
        Write-Log -Severity 'Information' -Message "Environment Variable `$env:ChocoDownloadUrl: $env:ChocoDownloadUrl"
        $ChocoDownloadUrl = $env:ChocoDownloadUrl
    }
    #cChocoExChocoConfig
    if ($env:cChocoExChocoConfig -and ([string]::IsNullOrEmpty($ChocoConfig))) {
        Write-Log -Severity 'Information' -Message "Environment Variable `$env:cChocoExChocoConfig: $env:cChocoExChocoConfig"
        $ChocoConfig = $env:cChocoExChocoConfig
    }
    #cChocoExSourcesConfig
    if ($env:cChocoExSourcesConfig -and ([string]::IsNullOrEmpty($SourcesConfig))) {
        Write-Log -Severity 'Information' -Message "Environment Variable `$env:cChocoExSourcesConfig: $env:cChocoExSourcesConfig"
        $SourcesConfig = $env:cChocoExSourcesConfig
    }
    #cChocoExPackageConfig
    if ($env:cChocoExPackageConfig -and ([string]::IsNullOrEmpty($PackageConfig))) {
        Write-Log -Severity 'Information' -Message "Environment Variable `$env:cChocoExPackageConfig: $env:cChocoExPackageConfig"
        $PackageConfig = $env:cChocoExPackageConfig -join ','
    }
    #cChocoExFeatureConfig
    if ($env:cChocoExFeatureConfig -and ([string]::IsNullOrEmpty($FeatureConfig))) {
        Write-Log -Severity 'Information' -Message "Environment Variable `$env:cChocoExFeatureConfig: $env:cChocoExFeatureConfig"
        $FeatureConfig = $env:cChocoExFeatureConfig
    }

    #####################################
    #   Set Environment Variables
    #####################################
    if ($SetcChocoExEnvironment) {
        #ChocoInstallScriptUrl
        if ($ChocoInstallScriptUrl) {
            Write-Log -Severity 'Information' -Message "Setting Environment Variable `$env:ChocoInstallScriptUrl: $ChocoInstallScriptUrl"
            [Environment]::SetEnvironmentVariable('ChocoInstallScriptUrl', $ChocoInstallScriptUrl, 'Machine')
            $env:ChocoInstallScriptUrl = $ChocoInstallScriptUrl  
        }
        #ChocoDownloadUrl
        if ($ChocoDownloadUrl) {
            Write-Log -Severity 'Information' -Message "Setting Environment Variable `$env:ChocoDownloadUrl: $ChocoDownloadUrl"
            [Environment]::SetEnvironmentVariable('ChocoDownloadUrl', $ChocoDownloadUrl, 'Machine')  
            $env:ChocoDownloadUrl = $ChocoDownloadUrl     
        }
        #cChocoExChocoConfig
        if ($ChocoConfig) {
            Write-Log -Severity 'Information' -Message "Setting Environment Variable `$env:ChocoConfig: $ChocoConfig"
            [Environment]::SetEnvironmentVariable('cChocoExChocoConfig', $ChocoConfig, 'Machine')
            $env:cChocoExChocoConfig = $ChocoConfig
        }
        #cChocoExSourcesConfig
        if ($SourcesConfig) {
            Write-Log -Severity 'Information' -Message "Setting Environment Variable `$env:SourcesConfig: $SourcesConfig"
            [Environment]::SetEnvironmentVariable('cChocoExSourcesConfig', $SourcesConfig, 'Machine')
            $env:cChocoExSourcesConfig = $SourcesConfig
        }
        #cChocoExPackageConfig
        if ($PackageConfig) {
            $PackageConfigString = $PackageConfig -join ','
            Write-Log -Severity 'Information' -Message "Setting Environment Variable `$env:cChocoExPackageConfig: $PackageConfigString"
            [Environment]::SetEnvironmentVariable('cChocoExPackageConfig', $PackageConfigString, 'Machine')
            $env:cChocoExPackageConfig = $PackageConfigString
        }
        #cChocoExFeatureConfig
        if ($FeatureConfig) {
            Write-Log -Severity 'Information' -Message "Setting Environment Variable `$env:FeatureConfig: $FeatureConfig"
            [Environment]::SetEnvironmentVariable('cChocoExFeatureConfig', $FeatureConfig, 'Machine')
            $env:cChocoExFeatureConfig = $FeatureConfig
        }
        #cChocoExBootStrapUri
        if ($env:cChocoExBootStrapUri) {
            Write-Log -Severity 'Information' -Message "Setting Environment Variable `$env:cChocoExBootStrapUri: $env:cChocoExBootStrapUri"
            [Environment]::SetEnvironmentVariable('cChocoExBootStrapUri', $env:cChocoExBootStrapUri, 'Machine')
        }
    }

    #####################################
    #   cChocoInstaller          
    #####################################
    $Configuration = @{
        InstallDir            = $InstallDir
        ChocoInstallScriptUrl = $ChocoInstallScriptUrl
    }

    #Set Enviromental Variable for chocolatey url to nupkg
    if ($ChocoDownloadUrl) {
        $env:chocolateyDownloadUrl = $ChocoDownloadUrl
    }
    Start-cChocoInstaller -Configuration $Configuration

    #Ensure Chocolatey Config is Valid
    #https://github.com/chocolatey/choco/issues/1047
    if (-not(Test-ChocolateyConfig)) {
        $Reset = Reset-ChocolateyConfig
        Write-Log -Severity 'Information' -Message $Reset.Config
        Write-Log -Severity 'Information' -Message "Chocolatey Config Reset: $($Reset.Reset)"
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

    #####################################
    #   cChocoConfig          
    #####################################
    if (Test-Path $ChocoConfigDestination ) {
        $ConfigImport = $null
        $ConfigImport = Import-PowerShellDataFile $ChocoConfigDestination
        Start-cChocoConfig -ConfigImport $ConfigImport
    }
    else {
        Write-Log -Severity 'Information' -Message "File not found, configuration will not be modified"
    }
    #####################################
    #   cChocoFeature          
    #####################################
    if (Test-Path $FeatureConfigDestination ) {
        $ConfigImport = $null
        $ConfigImport = Import-PowerShellDataFile $FeatureConfigDestination
        Start-cChocoFeature -ConfigImport $ConfigImport
    }
    else {
        Write-Log -Severity 'Information' -Message "File not found, features will not be modified"
    }
    #####################################
    #   cChocoSource          
    #####################################
    if (Test-Path $SourcesConfigDestination ) {
        $ConfigImport = $null
        $ConfigImport = Import-PowerShellDataFile $SourcesConfigDestination
        Start-cChocoSource -ConfigImport $ConfigImport
    }
    else {
        Write-Log -Severity 'Information' -Message "File not found, sources will not be modified"
    }
    #####################################
    #   cChocoPackageInstall          
    #####################################
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
    if ($Loop) {
        Write-Log -Severity "Information" -Message "Function Looping Enabled"
        Write-Log -Severity "Information" -Message "Looping Delay: $LoopDelay Minutes"
        Register-cChocoExBootStrapTask -LoopDelay $LoopDelay
    }
    #Clear Pending file
    if (Test-Path -Path $PendingFile) {
        Remove-Item -Path $PendingFile -Force    
    }
    $null = Set-ExecutionPolicy $CurrentExecutionPolicy -Scope CurrentUser -ErrorAction SilentlyContinue
    Write-EventLog -LogName 'Application' -Source 'cChocoEx' -EventId 4001 -EntryType Information -Message 'cChocoEx Finished'
    RotateLog
}