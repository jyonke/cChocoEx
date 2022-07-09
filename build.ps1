#$LocalRepository = "$PSScriptRoot\builds"
#Register-PSRepository -Name Local_Nuget_Feed -SourceLocation $LocalRepository -PublishLocation $LocalRepository -InstallationPolicy Trusted
#Publish-Module -Path "$PSScriptRoot\src\" -Repository Local_Nuget_Feed -NuGetApiKey 'ABC123'
#Unregister-PSRepository -Name Local_Nuget_Feed

#Variables
$NuspecFile = (Get-ChildItem -Path $PSScriptRoot -Recurse -Filter cChocoEx.nuspec).FullName
$ModuleManifestFile = (Get-ChildItem -Path $PSScriptRoot -Recurse -Filter 'cChocoEx.psd1').FullName
$BuildDirectory = "$PSScriptRoot\builds"
$APIKey = Get-Content -Path "$PSScriptRoot\api.key"
$Branch = git rev-parse --abbrev-ref HEAD

Write-Host "    NUSPEC FILE: $NuspecFile" -ForegroundColor Cyan
Write-Host "BUILD DIRECTORY: $BuildDirectory" -ForegroundColor Cyan

#Dependencies
New-Item -ItemType Directory -Path $BuildDirectory -Force -ErrorAction SilentlyContinue | Out-Null
if (-not(Test-Path "$PSScriptRoot\nuget.exe")) {
    Invoke-WebRequest -Uri 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe' -OutFile "$PSScriptRoot\nuget.exe"
}

#Version Update
[version]$CurrentVersion = (Import-PowerShellDataFile -Path $ModuleManifestFile).ModuleVersion
[version]$DateVersion = Get-Date -f yy.MM.dd
if ($CurrentVersion -ge $DateVersion) {
    $BuildVersion = ([string]$DateVersion.Major + '.' + [string]$DateVersion.Minor + '.' + [string]$DateVersion.Build + '.' + [string]($CurrentVersion.Revision + 1))
}
else {
    $BuildVersion = ([string]$DateVersion + '.1')
}

try {
    #Update Module Manifest
    Update-ModuleManifest -Path $ModuleManifestFile -ModuleVersion $BuildVersion

    #Update Version in Nuspec
    [xml]$xml = Get-Content -Path $NuSpecFile -Raw
    $xml.package.metadata.version = $BuildVersion
    #$xml.SelectSingleNode('/nuspec:package/nuspec:metadata/nuspec:description', $ns).InnerText = Get-Content -Raw (Join-Path $Directory 'ReadMe.md')
    $xml.Save($NuSpecFile)
    Write-Host "$NuSpecFile -- Original Version: $CurrentVersion -- Updated to $BuildVersion"
}
catch {
    throw $_.Exception.Message
}

#Pack
try {
    #Argumenbts
    $ArgumentList = @(
        'pack'
        $NuspecFile
        '-exclude "*.exe"'
        "-OutputDirectory $BuildDirectory"
    )
    Start-Process -FilePath "$PSScriptRoot\nuget.exe" -ArgumentList $ArgumentList -NoNewWindow -Wait
}
catch {
    throw $_.Exception.Message
}

#Push
try {
    $NupkgFile = (Get-ChildItem -Path $BuildDirectory -Filter *.nupkg | Where-Object { $_.Name -Match $BuildVersion }).FullName
    #Argumenbts
    $ArgumentList = @(
        'push'
        $NupkgFile
        "-ApiKey $APIKey"
        '-Source https://nuget.lvl12.com/repository/nuget-ps/'
    )
    Start-Process -FilePath "$PSScriptRoot\nuget.exe" -ArgumentList $ArgumentList -NoNewWindow -Wait
}
catch {
    throw $_.Exception.Message
}