#Requires -Version 5.1
#Requires -RunAsAdministrator
#Requires -Modules PowerShellGet
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#TranscriptLogging
$null = Start-Transcript -Path (Join-Path -Path $Env:TEMP -ChildPath 'cChocoExBootStrap.log') -Force

#Required cChocoEx Version
$Name = 'cChocoEx'
$MinimumVersion = '22.1.16.5'

#PowerShell NuGet Repository Details
$NuGetRepositoryName = 'MyCustomRepository'
$NugetRepositoryURI = 'https://www.contoso.com/api/v2'

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
    Loop                  = $true
    LoopDelay             = 90
    PackageConfig         = @('https://raw.githubusercontent.com/jyonke/cChocoEx/master/examples/cChocoExPackagesExample.psd1')
    SourcesConfig         = 'https://raw.githubusercontent.com/jyonke/cChocoEx/master/examples/cChocoExSourcesExample.psd1'
    EnableNotifications   = $true
}

##########################################

#Check and Ensure NuGet Provider is Setup
Write-Host 'Checking NuGet Package Provider' -ForegroundColor Cyan
$NuGetPackageProvider = Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue
if (-not($NugetPackageProvider)) {
    Write-Host 'Installing NuGet Package Provider' -ForegroundColor Cyan
    #Manual Deployment if URI defined
    if ($NuGetPackageProviderURI) {
        $Version = ($NuGetPackageProviderURI -Split '-' | Select-Object -Last 1) -replace '.dll', ''
        $OutputDirectory = (Join-Path -Path "$env:ProgramFiles\PackageManagement\ProviderAssemblies\nuget\" -ChildPath $Version)    
        $Null = New-Item -ItemType Directory -Path $OutputDirectory -ErrorAction SilentlyContinue
        Invoke-WebRequest -Uri $NuGetPackageProviderURI -UseBasicParsing -OutFile (Join-Path -Path $OutputDirectory -ChildPath 'Microsoft.PackageManagement.NuGetProvider.dll')
    }
    else {
        $null = Find-PackageProvider -Name 'Nuget' -ForceBootstrap -IncludeDependencies
    }
}
Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue | Select-Object Name, Version, ProviderPath | Format-List

#Register Custom PSRepository
if ($NugetRepositoryURI) {
    #PSRepository Splat
    $RepositoryData = @{
        Name                      = $NuGetRepositoryName
        SourceLocation            = $NugetRepositoryURI
        InstallationPolicy        = 'Trusted'
        PackageManagementProvider = 'nuget'
        ErrorAction               = 'SilentlyContinue'
        Verbose                   = $true
    }
    Write-Host 'Register PowerShell Repository' -ForegroundColor Cyan
    Register-PSRepository @RepositoryData
}

#Install/Update/Import cChocoEx
if (-Not(Get-Module -Name $Name -ListAvailable | Where-Object { [version]$_.Version -ge [version]$MinimumVersion })) {
    #Install Module
    Write-Host 'Installing/Updating cChocoEx' -ForegroundColor Cyan
    Find-Module -Name $Name -MinimumVersion $MinimumVersion | Sort-Object -Property 'Version' -Descending | Install-Module -Force
}

Write-Host 'Import cChocoEx Module' -ForegroundColor Cyan
Import-Module -Name 'cChocoEx' -Force -Verbose

#Update cChocoEx Bootstrap
if ($BootstrapUri) {
    Update-cChocoExBootstrap -Uri $BootstrapUri
}

#Start cChocoEx
Start-cChocoEx @cChocoExParamters 

#Stop Logging
$null = Stop-Transcript