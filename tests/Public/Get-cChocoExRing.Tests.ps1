$root = Split-Path (Split-Path (Split-Path -Parent (Get-Item $MyInvocation.MyCommand.Path).FullName) -Parent) -Parent
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

Describe 'Get-cChocoExRing Tests' {
    BeforeAll {
        $testRegistryPath = "HKLM:\Software\cChocoEx"
        $testLegacyPath = "HKLM:\Software\Chocolatey\cChoco"
        
        # Create test registry paths if they don't exist
        if (-not (Test-Path $testRegistryPath)) {
            New-Item -Path $testRegistryPath -Force | Out-Null
        }
        if (-not (Test-Path $testLegacyPath)) {
            New-Item -Path $testLegacyPath -Force | Out-Null
        }
    }

    AfterAll {
        # Clean up test registry paths
        if (Test-Path $testRegistryPath) {
            Remove-Item -Path $testRegistryPath -Recurse -Force
        }
        if (Test-Path $testLegacyPath) {
            Remove-Item -Path $testLegacyPath -Recurse -Force
        }
    }

    Context 'When registry is empty' {
        BeforeEach {
            # Ensure registry is clean
            if (Test-Path $testRegistryPath) {
                Remove-Item -Path $testRegistryPath -Recurse -Force
            }
            if (Test-Path $testLegacyPath) {
                Remove-Item -Path $testLegacyPath -Recurse -Force
            }
            New-Item -Path $testRegistryPath -Force | Out-Null
        }

        It 'Should return Broad as default ring' {
            $result = Get-cChocoExRing
            $result | Should -Be 'Broad'
        }
    }

    Context 'When legacy registry path exists' {
        BeforeEach {
            # Ensure registry is clean
            if (Test-Path $testRegistryPath) {
                Remove-Item -Path $testRegistryPath -Recurse -Force
            }
            if (Test-Path $testLegacyPath) {
                Remove-Item -Path $testLegacyPath -Recurse -Force
            }
            New-Item -Path $testLegacyPath -Force | Out-Null
        }

        It 'Should migrate valid ring from legacy path' {
            Set-ItemProperty -Path $testLegacyPath -Name 'Ring' -Value 'Fast'
            $result = Get-cChocoExRing
            $result | Should -Be 'Fast'
            
            # Verify legacy path was removed
            Test-Path $testLegacyPath | Should -Be $false
        }

        It 'Should not migrate invalid ring from legacy path' {
            Set-ItemProperty -Path $testLegacyPath -Name 'Ring' -Value 'InvalidRing'
            $result = Get-cChocoExRing
            $result | Should -Be 'Broad'
            
            # Verify legacy path was removed
            Test-Path $testLegacyPath | Should -Be $false
        }
    }

    Context 'When current registry has valid ring values' {
        BeforeEach {
            # Ensure registry is clean
            if (Test-Path $testRegistryPath) {
                Remove-Item -Path $testRegistryPath -Recurse -Force
            }
            New-Item -Path $testRegistryPath -Force | Out-Null
        }

        It 'Should return Preview ring' {
            Set-ItemProperty -Path $testRegistryPath -Name 'Ring' -Value 'Preview'
            $result = Get-cChocoExRing
            $result | Should -Be 'Preview'
        }

        It 'Should return Canary ring' {
            Set-ItemProperty -Path $testRegistryPath -Name 'Ring' -Value 'Canary'
            $result = Get-cChocoExRing
            $result | Should -Be 'Canary'
        }

        It 'Should return Pilot ring' {
            Set-ItemProperty -Path $testRegistryPath -Name 'Ring' -Value 'Pilot'
            $result = Get-cChocoExRing
            $result | Should -Be 'Pilot'
        }

        It 'Should return Fast ring' {
            Set-ItemProperty -Path $testRegistryPath -Name 'Ring' -Value 'Fast'
            $result = Get-cChocoExRing
            $result | Should -Be 'Fast'
        }

        It 'Should return Slow ring' {
            Set-ItemProperty -Path $testRegistryPath -Name 'Ring' -Value 'Slow'
            $result = Get-cChocoExRing
            $result | Should -Be 'Slow'
        }

        It 'Should return Broad ring' {
            Set-ItemProperty -Path $testRegistryPath -Name 'Ring' -Value 'Broad'
            $result = Get-cChocoExRing
            $result | Should -Be 'Broad'
        }

        It 'Should return Exclude ring' {
            Set-ItemProperty -Path $testRegistryPath -Name 'Ring' -Value 'Exclude'
            $result = Get-cChocoExRing
            $result | Should -Be 'Exclude'
        }
    }

    Context 'When current registry has invalid ring values' {
        BeforeEach {
            # Ensure registry is clean
            if (Test-Path $testRegistryPath) {
                Remove-Item -Path $testRegistryPath -Recurse -Force
            }
            New-Item -Path $testRegistryPath -Force | Out-Null
        }

        It 'Should default to Broad for invalid ring value' {
            Set-ItemProperty -Path $testRegistryPath -Name 'Ring' -Value 'InvalidRing'
            $result = Get-cChocoExRing
            $result | Should -Be 'Broad'
        }

        It 'Should default to Broad for empty ring value' {
            Set-ItemProperty -Path $testRegistryPath -Name 'Ring' -Value ''
            $result = Get-cChocoExRing
            $result | Should -Be 'Broad'
        }
    }

    Context 'When registry access fails' {
        BeforeEach {
            # Ensure registry is clean
            if (Test-Path $testRegistryPath) {
                Remove-Item -Path $testRegistryPath -Recurse -Force
            }
            New-Item -Path $testRegistryPath -Force | Out-Null
        }

        It 'Should default to Broad when registry access fails' {
            # Simulate registry access failure by removing the key
            Remove-Item -Path $testRegistryPath -Recurse -Force
            $result = Get-cChocoExRing
            $result | Should -Be 'Broad'
        }
    }
}
