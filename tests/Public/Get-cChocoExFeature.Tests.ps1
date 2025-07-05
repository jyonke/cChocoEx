$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

InModuleScope 'cChocoEx' {
    Describe 'Get-cChocoExFeature Tests' {
        BeforeAll {
            $Path = 'TestDrive:\feature.psd1'
            Set-Content -Path $Path -Value @'
        @{
            "allowGlobalConfirmation" = @{
                FeatureName = "allowGlobalConfirmation"
                Ensure      = 'Present'
                Tags        = @("confirmation", "global")
            }    
            "powershellHost"          = @{        
                FeatureName = "powershellHost"
                Ensure      = 'Absent'
                Tags        = @("powershell", "host")
            }
            "useFipsCompliantChecksums" = @{
                FeatureName = "useFipsCompliantChecksums"
                Ensure      = 'Present'
                Tags        = @("security", "fips")
            }
        }
'@

        }
        It 'Confirm Configuration Data File Exits' {
            $Path | Should -Exist
        }
        It 'Returns 3 Feature Names' {
            (Get-cChocoExFeature -Path $Path | Select-Object -ExpandProperty FeatureName).Count | Should -Be 3 
        }
        It 'Verify Ensure Values' {
            (Get-cChocoExFeature -Path $Path | Select-Object -ExpandProperty Ensure) | Should -Match 'Absent|Present'
        }
        It 'Verify FeatureName' {
            (Get-cChocoExFeature -Path $Path | Select-Object -ExpandProperty FeatureName) | Should -Not -BeNullOrEmpty
        }
        It 'Verify Return Type' {
            (Get-cChocoExFeature -Path $Path) | Should -BeOfType PSCustomObject
        }
        It 'Filters by Tag' {
            $result = Get-cChocoExFeature -Path $Path -Tag "security"
            $result.Count | Should -Be 1
            $result.FeatureName | Should -Be "useFipsCompliantChecksums"
        }
        It 'Filters by Multiple Tags' {
            $result = Get-cChocoExFeature -Path $Path -Tag @("powershell", "host")
            $result.Count | Should -Be 1
            $result.FeatureName | Should -Be "powershellHost"
        }
        It 'Returns Empty When No Tags Match' {
            $result = Get-cChocoExFeature -Path $Path -Tag "nonexistent"
            $result.Count | Should -Be 0
        }
    }
}