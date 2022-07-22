$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force

InModuleScope 'cChocoEx' {
    Describe 'Test Time Conversion Success Scenarios' {
        It 'Validate Return Type' {
            ConvertTo-LocalTime "7/2/2021 2:00PM" -TimeZone 'Central Europe Standard Time' | Should -BeOfType 'System.DateTime'
        }
    }
    
}