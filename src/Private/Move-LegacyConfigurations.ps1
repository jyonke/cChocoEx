function Move-LegacyConfigurations {
    param (

    )
    
    #Ensure Folder Structure is Setup
    Set-cChocoExFolders

    $cChocoExDataFolder = (Join-Path -Path $env:ProgramData -ChildPath 'cChocoEx')
    $cChocoExConfigurationFolder = (Join-Path -Path $cChocoExDataFolder -ChildPath 'config')
    $cChocoExConfigurationFolderLegacy = (Join-Path -p $env:ChocolateyInstall -ChildPath 'config')
    $LegacyFiles = Get-ChildItem -Path $cChocoExConfigurationFolderLegacy -Filter *.psd1 -ErrorAction SilentlyContinue 
    $LegacyFiles += Get-ChildItem -Path $cChocoExConfigurationFolderLegacy -Filter *.key -ErrorAction SilentlyContinue 

    if ($LegacyFiles) {
        Write-Log -Severity 'Information' -Message "cChocoEx Legacy Configuration Migration"
        Write-Log -Severity 'Information' -Message "cChocoEx Configuration File Path $cChocoExConfigurationFolder"
        Write-Log -Severity 'Information' -Message "Migrating Configuration Files from $cChocoExConfigurationFolderLegacy"
        $LegacyFiles | ForEach-Object {
            Write-Log -Severity 'Information' -Message "Moving $($_.Fullname)"
            try {
                Move-Item -Path $_.FullName -Destination $cChocoExConfigurationFolder -Force
            }
            catch {
                $_.Exception.Message
            }
        }
    }
}