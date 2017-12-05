#
# Module manifest for module 'NewManifest'
#
# Generated by: Martin Gill
#
# Generated on: 23/07/2016
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'PSEnvironment.psm1'

# Version number of this module.
ModuleVersion = '1.1.2'

# ID used to uniquely identify this module
GUID = '4944c1c9-2e68-4253-8254-1d30a72ab9a7'

# Author of this module
Author = 'Martin Gill'

# Company or vendor of this module
CompanyName = ''

# Copyright statement for this module
Copyright = '(c) 2015-2017 Martin Gill. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Module to make working with environment variables easier.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '2.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
ProcessorArchitecture = 'None'

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module
FunctionsToExport =
               @('Get-EnvironmentVariable',
                'Set-EnvironmentVariable',
                'Get-EnvironmentPath',
                'Repair-EnvironmentPath',
                'Test-EnvironmentPath',
                'Add-EnvironmentPath',
                'Remove-EnvironmentPath')

# Cmdlets to export from this module
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module
AliasesToExport = @()

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'Environment'

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/MartinSGill/PSEnvironment'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/MartinSGill/PSEnvironment'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # External dependent modules of this module
        # ExternalModuleDependencies = ''

    } # End of PSData hashtable

 } # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}
