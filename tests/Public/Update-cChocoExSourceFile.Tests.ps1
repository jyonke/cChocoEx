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
        "contoso"    = @{
            Name     = "contoso.com"
            Priority = 0
            Source   = "https://contoso.com/repository/nuget-hosted/"
            Ensure   = "Present"
            User     = 'svc_nuget'
            Password = '76492d1116743f0423413b16050a5345MgB8ADkAdwBKAHkASgA5AFAAOAB1AEIAZAB5AEkAeAAwAEQAegBaAFgASQAxAFEAPQA9AHwAOQA0ADkANwBlADUAOABkADIAZQBlAGMANgA4AGMAZQBjAGEAMwA3AGIANgA3ADAAMgA0ADAAMgAzADcAMQA1AA=='
            KeyFile  = 'C:\ProgramData\cChocoEx\config\sources.key'
        }
        "chocolatey" = @{
            Name     = "chocolatey"
            Priority = 10
            Source   = 'https://chocolatey.org/api/v2/'
            Ensure   = 'Present'
            VPN      = $false
        }
    }
'@
        }
        It 'Confirm Configuration Data File Exits' {
            $Path | Should -Exist
        }
        It "Returns <expected> (<name>)" -TestCases @(
            @{ Name = "contoso.com"; Ensure = 'Present'; Source = 'http://fakeurl.com'; Expected = 1 }
            @{ Name = "new source"; Ensure = 'Present'; Source = 'http://fakeurl.com'; Expected = 1 }
        ) {
            Get-ChildItem -Path $Path | Update-cChocoExSourceFile -Name $Name -Ensure $Ensure -Source $Source
        (Get-cChocoExSource -Path $Path | Where-Object { $_.Name -eq $Name } | Measure-Object).Count | Should -Be $Expected
        }
        It "Removes a package - Returns <expected> (<name>)" -TestCases @(
            @{ Name = "contoso.com"; Expected = 0 }
            @{ Name = "source2"; Expected = 0 }
        ) {
            Get-ChildItem -Path $Path | Update-cChocoExSourceFile -Name $Name -Remove
            (Get-cChocoExSource -Path $Path | Where-Object { $_.Name -eq $Name } | Measure-Object).Count | Should -Be $Expected
        } 
        It "Test optional parameter (<Parameter> - <Value>)" -TestCases @(
            @{Name = 'contoso.com'; Ensure = 'Present'; Parameter = 'VPN'; Value = $false }
            @{Name = 'contoso.com2'; Ensure = 'Present'; Parameter = 'Priority'; Value = 2 }
            @{Name = 'contoso.com2'; Ensure = 'Present'; Parameter = 'User'; Value = 'user' }
            @{Name = 'contoso.com2'; Ensure = 'Present'; Parameter = 'Password'; Value = 'password123' }
            @{Name = 'contoso.com2'; Ensure = 'Present'; Parameter = 'Keyfile'; Value = 'c:\fakepath\file.key' }

        ) {
            $Parameters = @{
                Name       = $Name
                Ensure     = $Ensure
                Source     = 'https://community.chocolatey.org/api/v2/'
                $Parameter = $Value
            }
            Get-ChildItem -Path $Path | Update-cChocoExSourceFile @Parameters
            (Get-cChocoExSource -Path $Path | Where-Object { $_.Name -eq $Name }).$Parameter | Should -Be $Value

        }
        
    }
}