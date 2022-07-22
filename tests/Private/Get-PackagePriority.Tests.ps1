$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

InModuleScope 'cChocoEx' {
    BeforeAll {
        $Path = 'TestDrive:\test01-packages.psd1'
        Set-Content -Path $Path -Value @'        
@{
    "jre8"                               = @{
        Name                      = "jre8"
        Ensure                    = 'Present'
        AutoUpgrade               = $True
        OverrideMaintenanceWindow = $False
        Priority = 0
    }
    'microsoft-edge'                     = @{
        Name        = 'microsoft-edge'
        Ensure      = 'Present'
        AutoUpgrade = $True
        Priority = 1
    }
    'winscp'                             = @{
        Name        = 'winscp'
        Ensure      = 'Present'
        AutoUpgrade = $True
        Priority = 2
    }
}
'@
        $Path = 'TestDrive:\test02-packages.psd1'
        Set-Content -Path $Path -Value @'        
@{
    "vlc-broad"                          = @{
        Name                      = "vlc"
        MinimumVersion            = "2.0.1"
        Ensure                    = 'Present'
        OverrideMaintenanceWindow = $True
        Ring                      = 'Broad'
        Priority = 3
    }
    "vlc-slow"                           = @{
        Name           = "vlc"
        Ensure         = 'Present'
        MinimumVersion = "3.0.0"
        Ring           = 'Slow'
    }
    "vlc-fast"                           = @{
        Name                      = "vlc"
        Ensure                    = 'Present'
        MinimumVersion            = "3.0.15"
        OverrideMaintenanceWindow = $True
        Ring                      = 'Fast'
    }
    "vlc-preview"                        = @{
        Name        = "vlc"
        Ensure      = 'Present'
        AutoUpgrade = $True
        Ring        = 'Preview'
    }
    'firefox-broad'                            = @{
        Name    = 'firefox'
        Version = "87.0"
        Ensure  = 'Present'
        Ring    = 'Broad'
        Priority = 4
    }
    'firefox-slow'                            = @{
        Name    = 'firefox'
        Version = "87.0"
        Ensure  = 'Present'
        Ring    = 'Slow'
    }
    'firefox-fast'                            = @{
        Name    = 'firefox'
        Version = "87.0"
        Ensure  = 'Present'
        Ring    = 'Fast'
    }
    'firefox-pilot'                     = @{
        Name        = 'firefox'
        Ensure      = 'Present'
        AutoUpgrade = $True
        Ring        = 'Pilot'
    }
    'firefox-preview'                            = @{
        Name    = 'firefox'
        Version = "87.0"
        Ensure  = 'Present'
        Ring    = 'Preview'
    }
}
'@
        $Configurations = $null
        Get-ChildItem -Path TestDrive:\ -Filter *.psd1 | Where-Object { $_.Name -notmatch "sources.psd1|config.psd1|features.psd1" } | ForEach-Object {
            $ConfigImport = $null
            $ConfigImport = Import-PowerShellDataFile $_.FullName 
            $Configurations += $ConfigImport | ForEach-Object { $_.Keys | ForEach-Object { $ConfigImport.$_ } }
        }
        $Configurations | Get-Member

    }
    Describe 'Test Package Broad Priority Success Scenarios' {
        
        BeforeEach {
            Mock Get-cChocoExRing { Return 'Broad' }
        }
        It 'Validate Configurations Exists' {
            $configurations | Should -Not -BeNullOrEmpty
        }
        It 'Validate Return Type' {
            Get-PackagePriority -Configurations $Configurations | Should -BeOfType 'HashTable'
        }
        It 'Validate Broad Ring Count' {
            (Get-PackagePriority -Configurations $Configurations).Count | Should -Be 5
        }
        It 'Validate Broad Ring' {
            Get-PackagePriority -Configurations $Configurations | Where-Object { $_.Name -eq 'vlc' } | Select-Object -ExpandProperty Ring | Should -Be 'Broad'
        }
    }
    Describe 'Test Package Fast Priority Success Scenarios' {
        
        BeforeEach {
            Mock Get-cChocoExRing { Return 'Fast' }
        }
        It 'Validate Configurations Exists' {
            $configurations | Should -Not -BeNullOrEmpty
        }
        It 'Validate Return Type' {
            Get-PackagePriority -Configurations $Configurations | Should -BeOfType 'HashTable'
        }
        It 'Validate Fast Ring Count' {
            (Get-PackagePriority -Configurations $Configurations).Count | Should -Be 5
        }
        It 'Validate Fast Ring' {
            Get-PackagePriority -Configurations $Configurations | Where-Object { $_.Name -eq 'vlc' } | Select-Object -ExpandProperty Ring | Should -Be 'Fast'
        }
    }
    Describe 'Test Package Slow Priority Success Scenarios' {
        
        BeforeEach {
            Mock Get-cChocoExRing { Return 'Slow' }
        }
        It 'Validate Configurations Exists' {
            $configurations | Should -Not -BeNullOrEmpty
        }
        It 'Validate Return Type' {
            Get-PackagePriority -Configurations $Configurations | Should -BeOfType 'HashTable'
        }
        It 'Validate Slow Ring Count' {
            (Get-PackagePriority -Configurations $Configurations).Count | Should -Be 5
        }
        It 'Validate Slow Ring' {
            Get-PackagePriority -Configurations $Configurations | Where-Object { $_.Name -eq 'vlc' } | Select-Object -ExpandProperty Ring | Should -Be 'Slow'
        }
    }
    Describe 'Test Package Pilot Priority Success Scenarios' {
        
        BeforeEach {
            Mock Get-cChocoExRing { Return 'Pilot' }
        }
        It 'Validate Configurations Exists' {
            $configurations | Should -Not -BeNullOrEmpty
        }
        It 'Validate Return Type' {
            Get-PackagePriority -Configurations $Configurations | Should -BeOfType 'HashTable'
        }
        It 'Validate Pilot Ring Count' {
            (Get-PackagePriority -Configurations $Configurations).Count | Should -Be 5
        }
        It 'Validate Pilot Ring' {
            #Return Fast Ring as no Pilot Ring Exists
            Get-PackagePriority -Configurations $Configurations | Where-Object { $_.Name -eq 'vlc' } | Select-Object -ExpandProperty Ring | Should -Be 'Fast'
        }
    }
    Describe 'Test Package Canary Priority Success Scenarios' {
        
        BeforeEach {
            Mock Get-cChocoExRing { Return 'Canary' }
        }
        It 'Validate Configurations Exists' {
            $configurations | Should -Not -BeNullOrEmpty
        }
        It 'Validate Return Type' {
            Get-PackagePriority -Configurations $Configurations | Should -BeOfType 'HashTable'
        }
        It 'Validate Canary Ring Count' {
            (Get-PackagePriority -Configurations $Configurations).Count | Should -Be 5
        }
        It 'Validate Canary Ring' {
            Get-PackagePriority -Configurations $Configurations | Where-Object { $_.Name -eq 'vlc' } | Select-Object -ExpandProperty Ring | Should -Be 'Preview'
        }
    }
    Describe 'Test Package Preview Priority Success Scenarios' {
        
        BeforeEach {
            Mock Get-cChocoExRing { Return 'Preview' }
        }
        It 'Validate Configurations Exists' {
            $configurations | Should -Not -BeNullOrEmpty
        }
        It 'Validate Return Type' {
            Get-PackagePriority -Configurations $Configurations | Should -BeOfType 'HashTable'
        }
        It 'Validate Preview Ring Count' {
            (Get-PackagePriority -Configurations $Configurations).Count | Should -Be 5
        }
        It 'Validate Preview Ring' {
            Get-PackagePriority -Configurations $Configurations | Where-Object { $_.Name -eq 'vlc' } | Select-Object -ExpandProperty Ring | Should -Be 'Preview'
        }
    }
    Describe 'Test Package Priorty Order' {
        BeforeEach {
            Mock Get-cChocoExRing { Return 'Broad' }
        }
        It 'Returns jre8 from Priorty 0' {
            Get-PackagePriority -Configurations $Configurations | Select-Object -First 1 -ExpandProperty Name | Should -Be 'jre8'
        }
        It 'Returns firefox from Priority 4' {
            Get-PackagePriority -Configurations $Configurations | Select-Object -Last 1 -ExpandProperty Name | Should -Be 'firefox'
        }
    }
}