#Requires -Version 5.1
#Requires -RunAsAdministrator

$NuGetRepositoryName = 'nuget.lvl12.com'
$NugetRepositoryURI = 'https://nuget.lvl12.com/repository/nuget-ps-group/'
$NugetPPDLL = 'https://onegetcdn.azureedge.net/providers/Microsoft.PackageManagement.NuGetProvider-2.8.5.208.dll'
$cChocoExParamters = @{
    SettingsURI = 'https://raw.githubusercontent.com/jyonke/chocolatey/Module/DSC/configurations/examples/cChocoBootstrapExample.psd1' 
    Loop        = $true
    LoopDelay   = 15
}

##########################################

#Register PSRepository
$RepositoryData = @{
    Name                      = $NuGetRepositoryName
    SourceLocation            = $NugetRepositoryURI
    InstallationPolicy        = 'Trusted'
    PackageManagementProvider = 'nuget'
    ErrorAction               = 'SilentlyContinue'
    Verbose                   = $true
}
Register-PSRepository @RepositoryData

#NuGet Provider Setup
$NuGetPackageProvider = Find-PackageProvider -Name NuGet -ErrorAction SilentlyContinue
if ($NuGetPackageProvider) {
    $NuGetPackageProvider | Format-List
}
else {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    $OutFile = Join-Path -Path $env:Temp -ChildPath ($NugetPPDLL -Split '/' | Select-Object -Last 1)
    $Version = (Get-Item -Path $OutFile).BaseName -Split '-' | Select-Object -Last 1
    $OutputDirectory = (Join-Path -Path "$env:ProgramFiles\PackageManagement\ProviderAssemblies\nuget\" -ChildPath $Version)
    Invoke-WebRequest -Uri $NugetPPDLL -UseBasicParsing | Out-File -FilePath $OutFile
    $Null = New-Item -ItemType Directory -Path $OutputDirectory -ErrorAction SilentlyContinue
    Copy-Item -Path $OutFile -Destination (Join-Path -Path $OutputDirectory -ChildPath 'Microsoft.PackageManagement.NuGetProvider.dll') -Force
}

#Install and Update cChocoEx
if (Get-Module -Name 'cChocoEx') {
     Update-Module -Name 'cChocoEx' -Verbose
}
else { 
    Install-Module -Name 'cChocoEx' -Repository $RepositoryData.Name -Force -Verbose
}
Import-Module -Name 'cChocoEx' -Force -Verbose

#Run cChocoEx
Start-cChocoEx @cChocoExParamters 