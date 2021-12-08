#Requires -Version 5.1
#Requires -RunAsAdministrator

#PowerShell NuGet Repository Details
$NuGetRepositoryName = 'PSGallery'
$NugetRepositoryURI = 'https://www.powershellgallery.com/api/v2'

#Optional NuGet Package Provider URI
$NuGetPackageProviderURI = 'https://onegetcdn.azureedge.net/providers/Microsoft.PackageManagement.NuGetProvider-2.8.5.208.dll'

#Optional URI to this script source to self update
$BootstrapUri = 'https://raw.githubusercontent.com/jyonke/cChocoEx/master/examples/cChocoExBootstrapExample.ps1'

#Start-cChocoEx Paramater Splat
$cChocoExParamters = @{
    ChocoConfig           = 'https://raw.githubusercontent.com/jyonke/cChocoEx/master/examples/cChocoExConfigExample.psd1'
    ChocoDownloadUrl      = 'https://packages.chocolatey.org/chocolatey.0.11.3.nupkg'
    ChocoInstallScriptUrl = 'https://community.chocolatey.org/install.ps1'
    FeatureConfig         = 'https://raw.githubusercontent.com/jyonke/cChocoEx/master/examples/cChocoExFeatureExample.psd1'
    #InstallDir           = ''
    Loop                  = $true
    LoopDelay             = 45
    #MigrateLegacyConfigurations = $null
    #NoCache                     = $null
    PackageConfig         = @('https://raw.githubusercontent.com/jyonke/cChocoEx/master/examples/cChocoExPackagesExample.psd1')
    #RandomDelay                 = $null
    #SettingsURI                 = ''
    SourcesConfig         = 'https://raw.githubusercontent.com/jyonke/cChocoEx/master/examples/cChocoExSourcesExample.psd1'
    #WipeCache                   = $null
    EnableNotifications   = $true
}

##########################################

#Check and Ensure NuGet Provider is Setup
$NuGetPackageProvider = Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue
if (-not($NugetPackageProvider)) {
    #Manual Deployment if URI defined
    if ($NuGetPackageProviderURI) {
        $Version = ($NuGetPackageProviderURI -Split '-' | Select-Object -Last 1) -replace '.dll', ''
        $OutputDirectory = (Join-Path -Path "$env:ProgramFiles\PackageManagement\ProviderAssemblies\nuget\" -ChildPath $Version)
    
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        $Null = New-Item -ItemType Directory -Path $OutputDirectory -ErrorAction SilentlyContinue
        Invoke-WebRequest -Uri $NuGetPackageProviderURI -UseBasicParsing -OutFile (Join-Path -Path $OutputDirectory -ChildPath 'Microsoft.PackageManagement.NuGetProvider.dll')
    }
    else {
        Find-PackageProvider -Name 'Nuget' -ForceBootstrap -IncludeDependencies
    }
}
else {
    $NuGetPackageProvider
}

#PSRepository Splat
$RepositoryData = @{
    Name                      = $NuGetRepositoryName
    SourceLocation            = $NugetRepositoryURI
    InstallationPolicy        = 'Trusted'
    PackageManagementProvider = 'nuget'
    ErrorAction               = 'SilentlyContinue'
}

#Register Custom PSRepository
if (($RepositoryData.SourceLocation -ne 'https://www.powershellgallery.com/api/v2') -or ($RepositoryData.Name -ne 'PSGallery')) {
    Register-PSRepository @RepositoryData
}
#Enable PSGallery and Set to Trusted if defined
else {
    if (-not(Get-PSRepository -Name 'PSGallery' -ErrorAction SilentlyContinue)) {
        Register-PSRepository -Default
    }
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
    $RepositoryData.Name = 'PSGallery'
}

#Install/Update/Import cChocoEx
if (Get-Module -Name 'cChocoEx' -ListAvailable) {
    Update-Module -Name 'cChocoEx' -Verbose
}
else { 
    Install-Module -Name 'cChocoEx' -Repository $RepositoryData.Name -Force -Verbose
}
Import-Module -Name 'cChocoEx' -Force -Verbose

#Update cChocoEx Bootstrap
if ($BootstrapUri) {
    Update-cChocoExBootstrap -Uri $BootstrapUri
}

#Start cChocoEx
Start-cChocoEx @cChocoExParamters 