#Requires -Modules Pester -Version 5
#Requires -RunAsAdministrator
Import-Module Pester -Force
Invoke-Pester -Path $PSScriptRoot\* -Output Detailed