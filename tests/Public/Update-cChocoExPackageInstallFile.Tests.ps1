$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

InModuleScope 'cChocoEx' {
    BeforeDiscovery {
        
    }
    Describe 'Tests updating/adding/removing a package file' {
        BeforeAll {
            $Path = Join-Path $TestDrive 'packages.psd1'
            Set-Content -Path $Path -Value @'        
    @{
        "adobereader"                        = @{
            Name        = "adobereader"
            Ensure      = 'Present'
            AutoUpgrade = $True
            Priority    = 10
        }
        "7zip.install"                       = @{
            Name        = "7zip.install"
            Ensure      = 'Present'
            AutoUpgrade = $True
            Priority    = 0
        }
        "notepadplusplus.install"            = @{
            Name        = "notepadplusplus.install"
            Ensure      = 'Present'
            AutoUpgrade = $True
            Priority    = 0
        }
        "vlc-broad"                          = @{
            Name                      = "vlc"
            MinimumVersion            = "2.0.1"
            Ensure                    = 'Present'
            OverrideMaintenanceWindow = $True
            Ring                      = 'Broad'
        }
        "vlc-preview"                        = @{
            Name        = "vlc"
            Ensure      = 'Present'
            AutoUpgrade = $True
            Ring        = 'Preview'
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
        "jre8"                               = @{
            Name                      = "jre8"
            Ensure                    = 'Present'
            AutoUpgrade               = $True
            OverrideMaintenanceWindow = $False
        }
        "git.install"                        = @{
            Name        = "git.install"
            Ensure      = 'Present'
            AutoUpgrade = $True
            chocoParams = '--execution-timeout 0'
            Source      = 'https://chocolatey.org/api/v2/'
        }
        "adobeair"                           = @{
            Name        = "adobeair"
            Ensure      = 'Present'
            AutoUpgrade = $True
            VPN         = $True
        }
        "chocolatey-windowsupdate.extension" = @{
            Name        = "chocolatey-windowsupdate.extension"
            Ensure      = 'Present'
            AutoUpgrade = $True
            VPN         = $False
        }
        'firefox'                            = @{
            Name    = 'firefox'
            Version = "87.0"
            Ensure  = 'Present'
            Ring    = 'broad'
        }
        'firefox-latest'                     = @{
            Name        = 'firefox'
            Ensure      = 'Present'
            AutoUpgrade = $True
            Ring        = 'Pilot'
        }
        'microsoft-edge'                     = @{
            Name        = 'microsoft-edge'
            Ensure      = 'Present'
            AutoUpgrade = $True
            Ring        = 'Broad'
        }
        'winscp'                             = @{
            Name        = 'winscp'
            Ensure      = 'Present'
            AutoUpgrade = $True
            Ring        = 'Broad'
        }
    }
'@
        }
        It 'Confirm Configuration Data File Exits' {
            $Path | Should -Exist
        }
        It "Returns <expected> (<name>)" -TestCases @(
            @{ Name = "winscp"; Ring = 'Broad'; Ensure = 'Present'; Expected = 1 }
            @{ Name = "newpackage"; Ring = 'Broad'; Ensure = 'Present'; Expected = 1 }
            @{ Name = "firefox"; Ring = 'Pilot'; Ensure = 'Present'; Expected = 1 }
            @{ Name = "pilotpackage"; Ring = 'Pilot'; Ensure = 'Present'; Expected = 1 }
            @{ Name = "winscp"; Ring = 'Fast'; Ensure = 'Absent'; Expected = 1 }
        ) {
            Get-ChildItem -Path $Path | Update-cChocoExPackageInstallFile -Name $Name -Ring $Ring -Ensure $Ensure -AutoUpgrade $true
        (Get-cChocoExPackageInstall -Path $Path | Where-Object { $_.Name -eq $Name -and $_.Ring -eq $Ring } | Measure-Object).Count | Should -Be $Expected
        }
        It "Removes a package - Returns <expected> (<name>)" -TestCases @(
            @{ Name = "winscp"; Ring = 'Broad'; Expected = 0 }
            @{ Name = "FakePackage"; Ring = 'Broad'; Expected = 0 }
        ) {
            Get-ChildItem -Path $Path | Update-cChocoExPackageInstallFile -Name $Name -Ring $Ring -Remove
            (Get-cChocoExPackageInstall -Path $Path | Where-Object { $_.Name -eq $Name -and $_.Ring -eq $Ring } | Measure-Object).Count | Should -Be $Expected
        } 
        It "Test optional parameter (<Parameter> - <Value>)" -TestCases @(
            @{Name = 'adobereader'; Ring = 'Fast'; Ensure = 'Present'; Parameter = 'Source'; Value = 'https://community.chocolatey.org/api/v2/' }
            @{Name = 'adobereader'; Ring = 'Fast'; Ensure = 'Present'; Parameter = 'MinimumVersion'; Value = '1.0.0' }
            @{Name = 'adobereader'; Ring = 'Fast'; Ensure = 'Present'; Parameter = 'Version'; Value = '1.0.0' }
            @{Name = 'adobereader'; Ring = 'Fast'; Ensure = 'Present'; Parameter = 'OverRideMaintenanceWindow'; Value = $true }
            @{Name = 'adobereader'; Ring = 'Fast'; Ensure = 'Present'; Parameter = 'OverRideMaintenanceWindow'; Value = $false }
            @{Name = 'adobereader'; Ring = 'Fast'; Ensure = 'Present'; Parameter = 'AutoUpgrade'; Value = $true }
            @{Name = 'adobereader'; Ring = 'Fast'; Ensure = 'Present'; Parameter = 'AutoUpgrade'; Value = $false }
            @{Name = 'adobereader'; Ring = 'Fast'; Ensure = 'Present'; Parameter = 'VPN'; Value = $true }
            @{Name = 'adobereader'; Ring = 'Fast'; Ensure = 'Present'; Parameter = 'VPN'; Value = $false }
            @{Name = 'adobereader'; Ring = 'Fast'; Ensure = 'Present'; Parameter = 'Params'; Value = '/MODE:Reload' }
            @{Name = 'adobereader'; Ring = 'Fast'; Ensure = 'Present'; Parameter = 'Params'; Value = '"/MODE:Reload"' }
            @{Name = 'adobereader'; Ring = 'Fast'; Ensure = 'Present'; Parameter = 'ChocoParams'; Value = '--use-system-powershell' }
            @{Name = 'adobereader'; Ring = 'Fast'; Ensure = 'Present'; Parameter = 'Priority'; Value = 10 }

        ) {
            $Parameters = @{
                Name       = $Name
                Ring       = $Ring
                Ensure     = $Ensure
                $Parameter = $Value
            }
            Get-ChildItem -Path $Path | Update-cChocoExPackageInstallFile @Parameters
            (Get-cChocoExPackageInstall -Path $Path | Where-Object { $_.Name -eq $Name -and $_.Ring -eq $Ring }).$Parameter | Should -Be $Value

        }
        
    }
}