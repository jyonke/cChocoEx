
$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force



Describe 'Get-cChocoExLog Tests' {
    BeforeAll {
        $Path = 'TestDrive:\cChoco.log'
        Set-Content -Path $Path -Value @'
"Time","Severity","Message"
"11/13/2021 9:24 PM","Information","Task Sequence Environemnt Detected: False"
"11/13/2021 9:24 PM","Information","cChocoInstaller:Validating Chocolatey is installed"
"11/13/2021 9:24 PM","Information","Starting cChocoInstaller"
"11/13/2021 9:24 PM","Information","Name: chocolatey"
"11/13/2021 9:24 PM","Information","DSC: True"
"11/13/2021 9:24 PM","Information","InstallDir: C:\ProgramData\chocolatey"
"11/13/2021 9:24 PM","Information","ChocoInstallScriptUrl: https://chocolatey.org/install.ps1"
"11/13/2021 9:24 PM","Information","cChocoEx Started"
"11/13/2021 9:24 PM","Information","cChocoEx Settings"
"11/13/2021 9:24 PM","Information","SettingsURI: "
"11/13/2021 9:24 PM","Information","InstallDir: C:\ProgramData\chocolatey"
"11/13/2021 9:24 PM","Information","ChocoInstallScriptUrl: https://chocolatey.org/install.ps1"
"11/13/2021 9:24 PM","Information","SourcesConfig: "
"11/13/2021 9:24 PM","Information","PackageConfig: "
"11/13/2021 9:24 PM","Information","ChocoConfig: "
"11/13/2021 9:24 PM","Information","FeatureConfig: "
"11/12/2021 9:24 PM","Warning","File not found, configuration will not be modified"
"11/12/2021 9:24 PM","Information","File not found, features will not be modified"
"11/12/2021 9:24 PM","Information","File not found, sources will not be modified"
"11/12/2021 9:24 PM","Warning","File not found, packages will not be modified"
'@

    }
    It 'Confirm Configuration Log File Exits' {
        $Path | Should -Exist
    }
    It 'Limit Filter - Returns 5 Log Events' {
        (Get-cChocoExLog -Path $Path -Last 5).Count | Should -Be 5
    }
    It 'Date Filter - Returns 16 Log Events' {
        (Get-cChocoExLog -Path $Path -Date '11/13/2021').Count | Should -Be 16
    }
    It 'LogType Validation' {
        (Get-cChocoExLog -Path $Path).Severity | Should -Match 'Warning|Error|Information'
    }
    It 'DateTime Validation' {
        (Get-cChocoExLog -Path $Path).Time | Should -Not -BeNullOrEmpty
    }
    It 'Message Validation' {
        (Get-cChocoExLog -Path $Path).Message | Should -Not -BeNullOrEmpty
    }
    It 'Verify Return Type' {
        (Get-cChocoExLog -Path $Path) | Should -BeOfType PSCustomObject
    }
}