$root = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -split '\\tests\\' | Select-Object -First 1
$Module = Join-Path $root 'src\cChocoEx.psm1'

Import-Module -Name $Module -Force
InModuleScope 'cChocoEx' {
    Describe 'Get-cChocoExHistory Tests' {
        BeforeAll {
            Mock Get-WinEvent { @([PSCustomObject]@{ TimeCreated = (Get-Date); Id = 1; LevelDisplayName = 'Information'; Message = 'Test event' }) }
            Mock Get-PowerHistory { @([PSCustomObject]@{ TimeCreated = (Get-Date).AddMinutes(-5); Id = 2; LevelDisplayName = 'Power'; Message = 'Power event' }) }
        }
        It 'Returns combined event and power history' {
            $result = Get-cChocoExHistory
            $result | Should -Not -BeNullOrEmpty
            foreach ($item in @($result)) {
                $item.TimeCreated | Should -Not -BeNullOrEmpty
                $item.Id | Should -Not -BeNullOrEmpty
                $item.LevelDisplayName | Should -Not -BeNullOrEmpty
                $item.Message | Should -Not -BeNullOrEmpty
            }
        }
        It 'Filters by days if parameter is provided' {
            $result = Get-cChocoExHistory -Days 1
            Assert-MockCalled Get-PowerHistory -ParameterFilter { $Days -eq 1 } -Scope It
        }
        It 'Handles no event logs gracefully' {
            Mock Get-WinEvent { @() }
            $result = Get-cChocoExHistory
            $result | Should -Not -BeNull
            if ($result) {
                foreach ($item in @($result)) {
                    $item.TimeCreated | Should -Not -BeNullOrEmpty
                    $item.Id | Should -Not -BeNullOrEmpty
                    $item.LevelDisplayName | Should -Not -BeNullOrEmpty
                    $item.Message | Should -Not -BeNullOrEmpty
                }
            }
            else {
                $result.Count | Should -Be 0
            }
        }
    }
} 