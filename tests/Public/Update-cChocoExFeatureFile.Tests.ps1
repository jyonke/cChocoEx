$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

Describe 'Update-cChocoExFeatureFile Tests' {
    BeforeAll {
        $Path = 'TestDrive:\feature.psd1'
        Set-Content -Path $Path -Value @'
@{
    "useFipsCompliantChecksums" = @{
        FeatureName = "useFipsCompliantChecksums"
        Ensure      = 'Present'
        Tags        = @("security", "compliance")
    }

    "powershellHost" = @{
        FeatureName = "powershellHost"
        Ensure      = 'Present'
        Tags        = @("powershell", "host")
    }
}
'@
    }

    Context 'Adding a new feature' {
        It 'Should add a new feature with tags' {
            Update-cChocoExFeatureFile -Path $Path -FeatureName 'allowGlobalConfirmation' -Ensure 'Present' -Tags @('global', 'confirmation')
            
            $result = Get-cChocoExFeature -Path $Path | Where-Object { $_.FeatureName -eq 'allowGlobalConfirmation' }
            $result | Should -Not -BeNullOrEmpty
            $result.FeatureName | Should -Be 'allowGlobalConfirmation'
            $result.Ensure | Should -Be 'Present'
            $result.Tags | Should -Contain 'global'
            $result.Tags | Should -Contain 'confirmation'
        }

        It 'Should add a new feature without tags' {
            Update-cChocoExFeatureFile -Path $Path -FeatureName 'useRememberedArgumentsForUpgrades' -Ensure 'Present'
            
            $result = Get-cChocoExFeature -Path $Path | Where-Object { $_.FeatureName -eq 'useRememberedArgumentsForUpgrades' }
            $result | Should -Not -BeNullOrEmpty
            $result.FeatureName | Should -Be 'useRememberedArgumentsForUpgrades'
            $result.Ensure | Should -Be 'Present'
        }
    }

    Context 'Updating an existing feature' {
        It 'Should update an existing feature with new tags' {
            Update-cChocoExFeatureFile -Path $Path -FeatureName 'useFipsCompliantChecksums' -Ensure 'Present' -Tags @('security', 'compliance', 'updated')
            
            $result = Get-cChocoExFeature -Path $Path | Where-Object { $_.FeatureName -eq 'useFipsCompliantChecksums' }
            $result | Should -Not -BeNullOrEmpty
            $result.Ensure | Should -Be 'Present'
            $result.Tags | Should -Contain 'updated'
        }

        It 'Should update an existing feature without modifying tags' {
            Update-cChocoExFeatureFile -Path $Path -FeatureName 'powershellHost' -Ensure 'Absent'
            
            $result = Get-cChocoExFeature -Path $Path | Where-Object { $_.FeatureName -eq 'powershellHost' }
            $result | Should -Not -BeNullOrEmpty
            $result.Ensure | Should -Be 'Absent'
            $result.Tags | Should -Contain 'powershell'
            $result.Tags | Should -Contain 'host'
        }
    }

    Context 'Removing a feature' {
        It 'Should remove an existing feature' {
            Update-cChocoExFeatureFile -Path $Path -FeatureName 'useFipsCompliantChecksums' -Remove
            
            $result = Get-cChocoExFeature -Path $Path | Where-Object { $_.FeatureName -eq 'useFipsCompliantChecksums' }
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'Error handling' {
        It 'Should not throw an error when removing a non-existent feature' {
            { Update-cChocoExFeatureFile -Path $Path -FeatureName 'nonexistent' -Remove } | Should -Not -Throw
        }

        It 'Should write a warning when path is invalid' {
            Update-cChocoExFeatureFile -Path 'nonexistent.psd1' -FeatureName 'test' -Ensure 'Present' -WarningVariable warningOutput
            $warningOutput | Should -Match "File not found at path: nonexistent.psd1"
        }
    }

    Context 'Parameter validation' {
        It 'Should accept valid Ensure values' {
            { Update-cChocoExFeatureFile -Path $Path -FeatureName 'testFeature' -Ensure 'Present' } | Should -Not -Throw
            { Update-cChocoExFeatureFile -Path $Path -FeatureName 'testFeature' -Ensure 'Absent' } | Should -Not -Throw
        }

        It 'Should reject invalid Ensure values' {
            { Update-cChocoExFeatureFile -Path $Path -FeatureName 'testFeature' -Ensure 'Invalid' } | Should -Throw
        }
    }
}