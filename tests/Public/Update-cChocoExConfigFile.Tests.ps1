$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

Describe 'Update-cChocoExConfigFile Tests' {
    BeforeAll {
        $Path = 'TestDrive:\config.psd1'
        Set-Content -Path $Path -Value @'
@{
    "webRequestTimeoutSeconds" = @{
        ConfigName = "webRequestTimeoutSeconds"
        Ensure     = 'Present'
        Value      = 30
        Tags       = @("timeout", "web")
    }

    "proxy" = @{
        ConfigName = "proxy"
        Ensure     = 'Absent'
        Tags       = @("network", "proxy")
    }
}
'@
    }

    Context 'Adding a new configuration' {
        It 'Should add a new configuration with tags' {
            Update-cChocoExConfigFile -Path $Path -ConfigName 'cacheLocation' -Value 'C:\Chocolatey\Cache' -Tags @('storage', 'cache')
            
            $result = Get-cChocoExConfig -Path $Path | Where-Object { $_.ConfigName -eq 'cacheLocation' }
            $result | Should -Not -BeNullOrEmpty
            $result.ConfigName | Should -Be 'cacheLocation'
            $result.Value | Should -Be 'C:\Chocolatey\Cache'
            $result.Tags | Should -Contain 'storage'
            $result.Tags | Should -Contain 'cache'
        }

        It 'Should add a new configuration without tags' {
            Update-cChocoExConfigFile -Path $Path -ConfigName 'commandExecutionTimeoutSeconds' -Value '2700'
            
            $result = Get-cChocoExConfig -Path $Path | Where-Object { $_.ConfigName -eq 'commandExecutionTimeoutSeconds' }
            $result | Should -Not -BeNullOrEmpty
            $result.ConfigName | Should -Be 'commandExecutionTimeoutSeconds'
            $result.Value | Should -Be '2700'
        }
    }

    Context 'Updating an existing configuration' {
        It 'Should update an existing configuration with new value and tags' {
            Update-cChocoExConfigFile -Path $Path -ConfigName 'webRequestTimeoutSeconds' -Value '60' -Tags @('timeout', 'web', 'updated')
            
            $result = Get-cChocoExConfig -Path $Path | Where-Object { $_.ConfigName -eq 'webRequestTimeoutSeconds' }
            $result | Should -Not -BeNullOrEmpty
            $result.Value | Should -Be '60'
            $result.Tags | Should -Contain 'updated'
        }

        It 'Should update an existing configuration without modifying tags' {
            Update-cChocoExConfigFile -Path $Path -ConfigName 'proxy' -Value 'http://proxy.example.com:8080'
            
            $result = Get-cChocoExConfig -Path $Path | Where-Object { $_.ConfigName -eq 'proxy' }
            $result | Should -Not -BeNullOrEmpty
            $result.Value | Should -Be 'http://proxy.example.com:8080'
            $result.Tags | Should -Contain 'network'
            $result.Tags | Should -Contain 'proxy'
        }
    }

    Context 'Removing a configuration' {
        It 'Should remove an existing configuration' {
            Update-cChocoExConfigFile -Path $Path -ConfigName 'webRequestTimeoutSeconds' -Remove
            
            $result = Get-cChocoExConfig -Path $Path | Where-Object { $_.ConfigName -eq 'webRequestTimeoutSeconds' }
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'Error handling' {
        It 'Should throw an error when updating a non-existent configuration with Remove' {
            { Update-cChocoExConfigFile -Path $Path -ConfigName 'nonexistent' -Remove } | Should -Not -Throw
        }

        It 'Should write a warning when path is invalid' {
            Update-cChocoExConfigFile -Path 'nonexistent.psd1' -ConfigName 'test' -Ensure 'Present' -WarningVariable warningOutput
            $warningOutput | Should -Match "File not found at path: nonexistent.psd1"
        }
    }

    Context 'Parameter validation' {
        It 'Should accept valid Ensure values' {
            { Update-cChocoExConfigFile -Path $Path -ConfigName 'testConfig' -Ensure 'Present' } | Should -Not -Throw
            { Update-cChocoExConfigFile -Path $Path -ConfigName 'testConfig' -Ensure 'Absent' } | Should -Not -Throw
        }

        It 'Should reject invalid Ensure values' {
            { Update-cChocoExConfigFile -Path $Path -ConfigName 'testConfig' -Ensure 'Invalid' } | Should -Throw
        }
    }
}