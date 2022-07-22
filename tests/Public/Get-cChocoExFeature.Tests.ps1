
$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force



Describe 'Get-cChocoExFeature Tests' {
    BeforeAll {
        $Path = 'TestDrive:\feature.psd1'
        Set-Content -Path $Path -Value @'
        @{
            "allowGlobalConfirmation" = @{
                FeatureName = "allowGlobalConfirmation"
                Ensure      = 'Present'    
            }    
            "powershellHost"          = @{        
                FeatureName = "powershellHost"
                Ensure      = 'Absent'
            }
        }
'@

    }
    It 'Confirm Configuration Data File Exits' {
        $Path | Should -Exist
    }
    It 'Returns 2 Feature Names' {
        (Get-cChocoExFeature -Path $Path | Select-Object -ExpandProperty FeatureName).Count | Should -Be 2 
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
}