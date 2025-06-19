$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

Describe 'Update-cChocoExSourceFile Tests' {
    BeforeAll {
        $Path = 'TestDrive:\sources.psd1'
        Set-Content -Path $Path -Value @'
@{
    "chocolatey" = @{
        Name     = "chocolatey"
        Ensure   = 'Present'
        Source   = "https://chocolatey.org/api/v2/"
        Priority = 0
        Tags     = @("public", "default")
    }

    "internal" = @{
        Name     = "internal"
        Ensure   = 'Present'
        Source   = "https://internal-feed.company.com/api/v2/"
        Priority = 1
        VPN      = $true
        Tags     = @("private", "internal")
    }
}
'@
    }

    Context 'Adding a new source' {
        It 'Should add a new source with tags' {
            Update-cChocoExSourceFile -Path $Path -Name 'artifactory' -Source 'https://artifactory.company.com/api/v2/' -Priority 2 -Tags @('private', 'artifactory')
            
            $result = Get-cChocoExSource -Path $Path | Where-Object { $_.Name -eq 'artifactory' }
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be 'artifactory'
            $result.Source | Should -Be 'https://artifactory.company.com/api/v2/'
            $result.Priority | Should -Be 2
            $result.Tags | Should -Contain 'private'
            $result.Tags | Should -Contain 'artifactory'
        }

        It 'Should add a new source without tags' {
            Update-cChocoExSourceFile -Path $Path -Name 'nuget' -Source 'https://nuget.org/api/v2/' -Priority 3
            
            $result = Get-cChocoExSource -Path $Path | Where-Object { $_.Name -eq 'nuget' }
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be 'nuget'
            $result.Source | Should -Be 'https://nuget.org/api/v2/'
            $result.Priority | Should -Be 3
        }

        It 'Should add a new source with authentication' {
            Update-cChocoExSourceFile -Path $Path -Name 'secure' -Source 'https://secure.company.com/api/v2/' -Priority 4 -User 'admin' -Password 'secret' -Keyfile 'C:\keys\key.pem'
            
            $result = Get-cChocoExSource -Path $Path | Where-Object { $_.Name -eq 'secure' }
            $result | Should -Not -BeNullOrEmpty
            $result.User | Should -Be 'admin'
            $result.Password | Should -Be 'secret'
            $result.Keyfile | Should -Be 'C:\keys\key.pem'
        }
    }

    Context 'Updating an existing source' {
        It 'Should update an existing source with new tags' {
            Update-cChocoExSourceFile -Path $Path -Name 'chocolatey' -Source 'https://chocolatey.org/api/v2/' -Priority 0 -Tags @('public', 'default', 'updated')
            
            $result = Get-cChocoExSource -Path $Path | Where-Object { $_.Name -eq 'chocolatey' }
            $result | Should -Not -BeNullOrEmpty
            $result.Tags | Should -Contain 'updated'
        }

        It 'Should update an existing source without modifying tags' {
            Update-cChocoExSourceFile -Path $Path -Name 'internal' -Source 'https://internal-feed.company.com/api/v2/' -Priority 1 -VPN $true
            
            $result = Get-cChocoExSource -Path $Path | Where-Object { $_.Name -eq 'internal' }
            $result | Should -Not -BeNullOrEmpty
            $result.VPN | Should -Be $true
            $result.Tags | Should -Contain 'private'
            $result.Tags | Should -Contain 'internal'
        }
    }

    Context 'Removing a source' {
        It 'Should remove an existing source' {
            Update-cChocoExSourceFile -Path $Path -Name 'chocolatey' -Remove
            
            $result = Get-cChocoExSource -Path $Path | Where-Object { $_.Name -eq 'chocolatey' }
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'Error handling' {
        It 'Should not throw an error when removing a non-existent source' {
            { Update-cChocoExSourceFile -Path $Path -Name 'nonexistent' -Remove } | Should -Not -Throw
        }

        It 'Should write a warning when path is invalid' {
            Update-cChocoExSourceFile -Path 'nonexistent.psd1' -Name 'test' -Source 'https://test.com' -WarningVariable warningOutput
            $warningOutput | Should -Match "File not found at path: nonexistent.psd1"
        }
    }

    Context 'Parameter validation' {
        It 'Should accept valid Ensure values' {
            { Update-cChocoExSourceFile -Path $Path -Name 'testSource' -Source 'https://test.com' -Ensure 'Present' } | Should -Not -Throw
            { Update-cChocoExSourceFile -Path $Path -Name 'testSource' -Source 'https://test.com' -Ensure 'Absent' } | Should -Not -Throw
        }

        It 'Should reject invalid Ensure values' {
            { Update-cChocoExSourceFile -Path $Path -Name 'testSource' -Source 'https://test.com' -Ensure 'Invalid' } | Should -Throw
        }
    }
}