$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force
InModuleScope 'cChocoEx' {
    Describe 'Tests Updating Bootstrap' {
        BeforeEach {
            Mock Write-Log { return $null }
        }
        It 'Tests Admin Restriction' {
            Mock Test-IsAdmin { Return $false }
            Update-cChocoExBootstrap -Uri 'https://contoso.com/bootstrap.ps1' | Should -Throw
        }
    }
}
