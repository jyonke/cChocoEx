$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

InModuleScope 'cChocoEx' {
    Describe 'Test Logged In User Success Scenarios' {
        It 'Validate Return Type' {
            Get-LoggedInUser | Should -BeOfType 'PSCustomObject'
        }
        It 'Validates Value Population' -ForEach (Get-LoggedInUser | Get-Member | Where-Object { $_.MemberType -eq 'NoteProperty' } | Select-Object -ExpandProperty Name) {
            (Get-LoggedInUser).$_ | Should -Not -BeNullOrEmpty
        }
    }
    
}