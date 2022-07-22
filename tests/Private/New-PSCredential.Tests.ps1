$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

InModuleScope 'cChocoEx' {
    Describe 'Valid PSCredentials' {
        BeforeAll {
            $KeyFile = "TestDrive:\aes.key"
            Set-Content -Path $KeyFile -Value @'
            107
            72
            119
            225
            42
            228
            108
            213
            194
            151
            51
            239
            250
            115
            113
            210
'@
        }
        BeforeEach {
            $User = 'User'
            $Password = '76492d1116743f0423413b16050a5345MgB8AEcATwAvAFQAWQA5AFYAYwA1AEwANgBrAG0ASABiADMAYQAvAE4ANwBzAEEAPQA9AHwAMgAwAGIAMQA0AGIANwAxADgAOQAyADUAMgA0AGYAMgA1AGIAZQBlAGEAMwA0AGUAYwBhADcAZAA0ADgAMwA0AGIANwA0ADQAYwBhADMANQA5ADcAMwA5ADQAYwAwADUAOQAyADYAYQA5AGQAMwBhAGYAYQBmAGYAYgAwAGEAZQA='
        }
        It "Validate KeyFile Exists" {
            Get-Content $KeyFile | Should -Not -BeNullOrEmpty
        }
        It 'Test Output Type' {
            New-PSCredential -User $User -Password $Password -KeyFile $KeyFile | Should -BeOfType 'System.Management.Automation.PSCredential'
        }
        It "Test UserName" {
            (New-PSCredential -User $User -Password $Password -KeyFile $KeyFile).UserName | Should -Be $User
        }
        It "Test SecureString" {
            (New-PSCredential -User $User -Password $Password -KeyFile $KeyFile).Password | Should -Be 'System.Security.SecureString'
        }
    }
    
}