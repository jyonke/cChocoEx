#$LocalRepository = "$PSScriptRoot\builds"
#Register-PSRepository -Name Local_Nuget_Feed -SourceLocation $LocalRepository -PublishLocation $LocalRepository -InstallationPolicy Trusted
#Publish-Module -Path "$PSScriptRoot\src\" -Repository Local_Nuget_Feed -NuGetApiKey 'ABC123'
#Unregister-PSRepository -Name Local_Nuget_Feed

#Variables
$NuspecFile = (Get-ChildItem -Path $PSScriptRoot -Recurse -Filter *.nuspec).FullName
$BuildDirectory = "$PSScriptRoot\builds"

Write-Host "    NUSPEC FILE: $NuspecFile" -ForegroundColor Cyan
Write-Host "BUILD DIRECTORY: $BuildDirectory" -ForegroundColor Cyan

#Dependencies
New-Item -ItemType Directory -Path $BuildDirectory -Force -ErrorAction SilentlyContinue | Out-Null
if (-not(Test-Path "$PSScriptRoot\nuget.exe")) {
    Invoke-WebRequest -Uri 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe' -OutFile "$PSScriptRoot\nuget.exe"
}

#Nuget Argumenbts
$ArgumentList = @(
    'pack'
    $NuspecFile
    "-OutputDirectory $BuildDirectory"
)

#RUN
Start-Process -FilePath "$PSScriptRoot\nuget.exe" -ArgumentList $ArgumentList -NoNewWindow -Wait