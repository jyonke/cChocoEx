#Requires -Version 5.1
#Requires -RunAsAdministrator

$NuGetRepositoryName = 'nuget.lvl12.com'
$NugetRepositoryURI = 'https://nuget.lvl12.com/repository/nuget-ps-group/'
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
    Install-PackageProvider -Name NuGet -Force -Verbose | Format-List
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