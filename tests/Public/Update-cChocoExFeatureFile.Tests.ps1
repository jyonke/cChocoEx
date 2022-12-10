$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

InModuleScope 'cChocoEx' {
    BeforeDiscovery {
        
    }
    Describe 'Tests updating/adding/removing a config file' {
        BeforeAll {
            $Path = Join-Path $TestDrive 'feature.psd1'
            Set-Content -Path $Path -Value @'        
    @{
        "allowGlobalConfirmation" = @{
            FeatureName = 'allowGlobalConfirmation'
            Ensure      = 'Present'
        }
        "powershellHost"          = @{
            FeatureName = 'powershellHost'
            Ensure      = 'Absent'
        }
    }
'@
        }
        It 'Confirm Configuration Data File Exits' {
            $Path | Should -Exist
        }
        It "Returns <expected> (<name>)" -TestCases @(
            @{ FeatureName = "allowGlobalConfirmation"; Ensure = 'Present'; Expected = 1 }
            @{ FeatureName = "powershellHost"; Ensure = 'Present'; Expected = 1 }
            @{ FeatureName = "FakeFeature"; Ensure = 'Absent'; Expected = 1 }

        ) {
            Get-ChildItem -Path $Path | Update-cChocoExFeatureFile -FeatureName $FeatureName -Ensure $Ensure
        (Get-cChocoExFeature -Path $Path | Where-Object { $_.FeatureName -eq $FeatureName } | Measure-Object).Count | Should -Be $Expected
        }
        It "Removes a package - Returns <expected> (<name>)" -TestCases @(
            @{ FeatureName = "FakeFeature"; Expected = 0 }
            @{ FeatureName = "NonExistantFeature"; Expected = 0 }
        ) {
            Get-ChildItem -Path $Path | Update-cChocoExFeatureFile -FeatureName $FeatureName -Remove
        (Get-cChocoExFeature -Path $Path | Where-Object { $_.FeatureName -eq $FeatureName } | Measure-Object).Count | Should -Be $Expected
        }         
    }
}