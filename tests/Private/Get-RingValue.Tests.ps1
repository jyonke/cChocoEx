$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

InModuleScope 'cChocoEx' {
    Describe 'Return Ring Values Based on Strings' {
        It "Returns <expected> (<name>)" -ForEach @(
            @{ Name = "preview"; Expected = 5 }
            @{ Name = "canary"; Expected = 5 }
            @{ Name = "pilot"; Expected = 4 }
            @{ Name = "fast"; Expected = 3 }
            @{ Name = "slow"; Expected = 2 }
            @{ Name = "broad"; Expected = 1 }
            @{ Name = "InvalidName"; Expected = 0 }
        ) {
            Get-ringValue -Name $Name | Should -Be $Expected
        }
    }
    
}