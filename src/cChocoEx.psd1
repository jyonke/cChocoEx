#
# Module manifest for module 'cChocoEx'
#
# Generated by: Jonathan Yonke <jon.yonke@gmail.com>
#
# Generated on: 7/23/2022
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'cChocoEx.psm1'

# Version number of this module.
ModuleVersion = '22.7.23.7'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = 'fa3aecec-1a56-443c-8fb9-13ee275f1391'

# Author of this module
Author = 'Jonathan Yonke <jon.yonke@gmail.com>'

# Company or vendor of this module
CompanyName = 'Jonathan Yonke'

# Copyright statement for this module
Copyright = '2021'

# Description of the functionality provided by this module
Description = 'Adds some additional functionality to the PowerShell DSC module cChoco'

# Minimum version of the PowerShell engine required by this module
PowerShellVersion = '4.0'

# Name of the PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# ClrVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = '.\Formats\cChocoExConfig.Format.ps1xml', 
               '.\Formats\cChocoExMaintenanceWindow.Format.ps1xml', 
               '.\Formats\cChocoExPackageInstall.Format.ps1xml', 
               '.\Formats\cChocoExSource.Format.ps1xml', 
               '.\Formats\cChocoExSource.Format.ps1xml'

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'Start-cChocoEx', 'Get-cChocoExRing', 'Set-cChocoExRing', 
               'Update-cChocoEx', 'Get-cChocoExLog', 'Get-cChocoExConfig', 
               'Get-cChocoExFeature', 'Get-cChocoExMaintenanceWindow', 
               'Get-cChocoExPackageInstall', 'Get-cChocoExSource', 
               'New-cChocoExConfigFile', 'New-cChocoExFeatureFile', 
               'New-cChocoExPackageInstallFile', 'New-cChocoExSourceFile', 
               'New-EncryptedCredential', 'Update-cChocoExBootstrap', 
               'Test-cChocoExConfig', 'Test-cChocoExFeature', 
               'Test-cChocoExInstaller', 'Test-cChocoExPackageInstall', 
               'Test-cChocoExSource', 'Test-cChocoExMaintenanceWindow', 
               'Register-cChocoExBootStrapTask', 'Uninstall-cChocoEx', 
               'Test-ChocolateyConfig', 'Reset-ChocolateyConfig', 
               'Get-AutoPilotStatus', 'Get-cChocoExHistory', 
               'Get-cChocoExEnvironment', 'Set-cChocoExEnvironment'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
# VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'chocolatey','cChoco','cChocoEx'

        # A URL to the license for this module.
        LicenseUri = 'http://www.apache.org/licenses/LICENSE-2.0'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/jyonke/cChocoEx'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        # RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable

 } # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

