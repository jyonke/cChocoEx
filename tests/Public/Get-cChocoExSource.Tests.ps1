$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

Describe 'Get-cChocoExSource Tests' {
    BeforeAll {
        $Path = 'TestDrive:\sources.psd1'
        Set-Content -Path $Path -Value @'
@{
    "chocolatey" = @{
        Name     = "chocolatey"
        Ensure   = 'Present'
        Priority = 1
        Source   = "https://chocolatey.org/api/v2/"
        Tags     = @("default", "public")
    }
    "internal"   = @{
        Name     = "internal"
        Ensure   = 'Present'
        Priority = 0
        Source   = "https://internal-feed/nuget/odata"
        User     = "user"
        Password = "pass"
        Tags     = @("internal", "private")
    }
    "test"       = @{
        Name     = "test"
        Ensure   = 'Present'
        Priority = 2
        Source   = "https://test-feed/nuget/odata"
        Tags     = @("test", "private")
    }
}
'@
    }

    It 'Confirm Configuration Data File Exists' {
        $Path | Should -Exist
    }

    It 'Returns 3 Sources' {
        (Get-cChocoExSource -Path $Path | Select-Object -ExpandProperty Name).Count | Should -Be 3
    }

    It 'Verify Name' {
        (Get-cChocoExSource -Path $Path | Select-Object -ExpandProperty Name) | Should -Not -BeNullOrEmpty
    }

    It 'Verify Ensure' {
        (Get-cChocoExSource -Path $Path | Select-Object -ExpandProperty Ensure) | Should -Match 'Absent|Present'
    }

    It 'Verify Return Type' {
        (Get-cChocoExSource -Path $Path) | Should -BeOfType PSCustomObject
    }

    It 'Filters by Tag' {
        $result = Get-cChocoExSource -Path $Path -Tag "private"
        $result.Count | Should -Be 2
        $result.Name | Should -Contain "internal"
        $result.Name | Should -Contain "test"
    }

    It 'Filters by Multiple Tags' {
        $result = Get-cChocoExSource -Path $Path -Tag @("default", "public")
        $result.Count | Should -Be 1
        $result.Name | Should -Be "chocolatey"
    }

    It 'Returns Empty When No Tags Match' {
        $result = Get-cChocoExSource -Path $Path -Tag "nonexistent"
        $result.Count | Should -Be 0
    }
} 