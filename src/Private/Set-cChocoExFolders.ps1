function Set-cChocoExFolders {
    [CmdletBinding()]
    param ()
    
    $null = New-Item -ItemType Directory -Path $cChocoExDataFolder -Force -ErrorAction SilentlyContinue
    $null = New-Item -ItemType Directory -Path $cChocoExConfigurationFolder -Force -ErrorAction SilentlyContinue
    $null = New-Item -ItemType Directory -Path $cChocoExTMPConfigurationFolder -Force -ErrorAction SilentlyContinue
    $null = New-Item -ItemType Directory -Path $LogPath -Force -ErrorAction SilentlyContinue
    $null = New-Item -ItemType Directory -Path $cChocoExMediaFolder -Force -ErrorAction SilentlyContinue
    
}