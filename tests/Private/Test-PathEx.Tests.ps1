$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -split 'tests' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

InModuleScope 'cChocoEx' {
    Describe 'Test-PathEx' {
        BeforeEach {
            # Mock Test-Path to return $false by default
            Mock Test-Path { return $false }
        }

        It 'Should return "FileSystem" for a valid file system path' {
            Mock Test-Path -MockWith { param($Path, $IsValid) if ($IsValid) { return $true } }
            Test-PathEx -Path 'C:\temp' | Should -Be 'FileSystem'
        }

        It 'Should return "URL" for a valid URL' {
            Test-PathEx -Path 'https://chocolatey.org' | Should -Be 'URL'
        }

        It 'Should return "URL" for a valid URL without protocol' {
            Test-PathEx -Path 'chocolatey.org' | Should -Be 'URL'
        }

        It 'Should return $null for an invalid path' {
            Test-PathEx -Path 'not a valid path' | Should -BeNullOrEmpty
        }

        It 'Should return $null for a string that is neither a path nor a URL' {
            Test-PathEx -Path 'this is just a string' | Should -BeNullOrEmpty
        }
    }
}
