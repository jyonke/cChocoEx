$PublicFunctions = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$PrivateFunctions = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Recurse -ErrorAction SilentlyContinue )

foreach ($Import in @($PublicFunctions + $PrivateFunctions)) {
    $Import
    Try { . $Import.FullName -Verbose }
    Catch { Write-Error -Message "Failed to import function $($Import.FullName): $_" }
}

Export-ModuleMember -Function $PublicFunctions.BaseName

Export-ModuleMember -Function $Public.BaseName

#=================================================
#WinPE
#https://github.com/OSDeploy/OSD
if ($env:SystemDrive -eq 'X:') {
    [System.Environment]::SetEnvironmentVariable('APPDATA', (Join-Path $env:USERPROFILE 'AppData\Roaming'), [System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable('HOMEDRIVE', $env:SystemDrive, [System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable('HOMEPATH', (($env:USERPROFILE) -split ":")[1], [System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable('LOCALAPPDATA', (Join-Path $env:USERPROFILE 'AppData\Local'), [System.EnvironmentVariableTarget]::Machine)

    $VolatileEnvironment = "HKCU:\Volatile Environment"
    if (-NOT (Test-Path -Path $VolatileEnvironment)) {
        New-Item -Path $VolatileEnvironment -Force
        New-ItemProperty -Path $VolatileEnvironment -Name "APPDATA" -Value (Join-Path $env:USERPROFILE 'AppData\Roaming') -Force
        New-ItemProperty -Path $VolatileEnvironment -Name "HOMEDRIVE" -Value $env:SystemDrive -Force
        New-ItemProperty -Path $VolatileEnvironment -Name "HOMEPATH" -Value (($env:USERPROFILE) -split ":")[1] -Force
        New-ItemProperty -Path $VolatileEnvironment -Name "LOCALAPPDATA" -Value (Join-Path $env:USERPROFILE 'AppData\Local') -Force
    }
}

#Ensure cChocoEx Data Folder Structure is Created
Set-GlobalVariables
Set-cChocoExFolders

#Ensure Registry Is Setup
Set-RegistryConfiguration

#Ensure EventLog Sources are Setup
Register-EventSource