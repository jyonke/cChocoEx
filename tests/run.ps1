#Requires -RunAsAdministrator
Install-Module Pester -Force -AllowClobber
Import-Module Pester -Force
Import-Module .\..\src\cChocoEx.psm1 -Force
Invoke-Pester -Path $PSScriptRoot\* -Output Detailed