#requires -Version 2
Set-StrictMode -Version 2

##############################
#.SYNOPSIS
# Gets an environment variable value.
#
#.DESCRIPTION
# Gets an environment variable value.
#
#.PARAMETER Name
# Name of the Environment variable
#
#.PARAMETER Scope
# The environment scope to change. By default only the current
# process is affected.
#
#.EXAMPLE
# PS> Set-EnvironmentVariable -Name MyVar -Value MyValue -Scope user
#
#.NOTES
# When the scope is set to "process" this command is equivalent to
# $env:<Name>
#
# By comparing process & user/machine scopes it's possible to see if
# the current process has changed a value from it's default.
##############################
function Get-EnvironmentVariable
{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true,ValueFromPipeline = $true)]
    [String]$Name,

    [Parameter(Mandatory = $false)]
    [ValidateSet('process','machine','user')]
    [String]$Scope = 'process'
  )

  [Environment]::GetEnvironmentVariable($Name, $Scope)
}

##############################
#.SYNOPSIS
# Sets an envrionment variable.
#
#.DESCRIPTION
# Allows setting an environment variable for any scope.
#
#.PARAMETER Name
# Name of the variable.
#
#.PARAMETER Value
# Value to be set
#
#.PARAMETER Scope
# The environment scope to change. By default only the current
# process is affected.
#
#.EXAMPLE
# PS> Set-EnvironmentVariable -Name MyVar -Value MyValue -Scope user
#
#.NOTES
# When the scope is set to "process" this command is equivalent to
# $env:<Name> = <Value>
##############################
function Set-EnvironmentVariable
{
  [CmdletBinding(SupportsShouldProcess = $true)]
  param(
    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$Name,

    [Parameter(Mandatory = $true,ValueFromPipelineByPropertyName = $true)]
    [String]$Value,

    [Parameter(Mandatory = $false)]
    [ValidateSet('process','machine','user')]
    [String]$Scope = 'process'
  )

  Write-Verbose -Message "Setting '$Name' to '$Value' on '$Scope'"
  if ($PSCmdlet.ShouldProcess("[$Scope]::$Name", $Value))
  {
    [Environment]::SetEnvironmentVariable($Name, $Value, $Scope)
  }
}

##############################
#.SYNOPSIS
# Get the current PATH environement value.
#
#.DESCRIPTION
# Get the current PATH environement value formatted as a PSCustomObject 
# with Path, Scope, and Exists.
#
#.PARAMETER Scope
# One or more scopes. By default all scopes are returned.
#
 #.EXAMPLE
# PS> Get-EnvironmentPath
# 
# Path                                                   Scope   Exists
# ----                                                   -----   ------
# C:\tools\go\bin                                        process   True
# ...
# C:\Program Files\Java\jdk1.8.0_74\bin                  machine   True
# C:\Go\bin                                              machine  False
# ...
# C:\Program Files\Git\cmd                               user      True
##############################
function Get-EnvironmentPath
{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('process','machine','user')]
    [String[]]$Scope
  )

  if (-not $Scope)
  {
    $Scope = @('process', 'machine', 'user')
  }

  foreach ($s in $Scope)
  {
    $pathss = (Get-EnvironmentVariable -Name 'PATH' -Scope $s) -split ';'
    foreach ($paths in $pathss)
    {
      if ([String]::IsNullOrWhiteSpace($paths)) { continue }
      [pscustomobject]@{
        Path   = $paths
        Scope  = $s
        Exists = Test-Path($paths)
      }
    }
  }
}

##############################
#.SYNOPSIS
# Tries to clean up the PATH environment variable.
#
#.DESCRIPTION
# Tries to clean up the PATH environment variable by looking
# for bad entries, e.g. empty entries, invalid paths, duplicates.
#
#.PARAMETER Scope
# The environment scope to change. By default only the current
# process is affected.
#
#.EXAMPLE
#  PS> Repair-EnvironmentPath -Scope process
#
##############################
function Repair-EnvironmentPath
{
  [CmdletBinding(SupportsShouldProcess = $true)]
  param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('process','machine','user')]
    [String]$Scope = 'process'
  )
  if ($Scope -eq 'process')
  {
    Write-Warning -Message 'This will change current-process value only. This may not be what you intended; see -Scope'
  }

  $verbose = ($PSCmdlet.MyInvocation.BoundParameters['Verbose'].IsPresent -eq $true)

  # Ensure unique paths only
  $paths = Get-EnvironmentPath -Scope $Scope
  $result = @()
  foreach ($path in ($paths | Select-Object -ExpandProperty Path))
  {
    if ([string]::IsNullOrWhiteSpace($path))
    {
      Write-Verbose -Message 'Found empty path. Removing.'
      continue
    }

    $path = $path.Trim()
    if ($path -in $result)
    {
      Write-Warning -Message "Found duplicate path [$path]. Removing."
      if ($PSCmdlet.ShouldProcess($path, 'Removing duplicate path entry?'))
      {
        continue
      }
    }

    if (-not (Test-Path $path -PathType Container))
    {
      Write-Warning -Message "Found invliad path [$path]. Removing."
      if ($PSCmdlet.ShouldProcess($path, 'Removing invalid path entry?'))
      {
        continue
      }
    }

    $result += $path
  }

  if ($PSCmdlet.ShouldProcess("`n$($result -join "`n")`n", 'Update environment with paths'))
  {
    Set-EnvironmentVariable -Scope $Scope -Name PATH -Value ($result -join ';')
  }
}

##############################
#.SYNOPSIS
# Test if the specified path is defined in the PATH
# Environment variable.
#
#.DESCRIPTION
# Test if the specified path is defined in the PATH
# Environment variable.
#
#.PARAMETER Path
# Path to a directory.
#
#.PARAMETER Scope
# The environment scope to change. By default only the current
# process is affected.
#
#.EXAMPLE
#  PS> Test-EnvironmentPath -Scope process -Path c:\windows\system32
#  True
#
##############################
function Test-EnvironmentPath
{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true,ValueFromPipeline = $true)]
    [String]$Path,

    [Parameter(Mandatory = $false)]
    [ValidateSet('process','machine','user')]
    [String]$Scope = 'process'
  )

  (Get-EnvironmentPath -Scope $Scope | Where-Object -FilterScript {
      $_.path -ieq $path
  }).Count -gt 0
}

##############################
#.SYNOPSIS
# Add the specified path to the PATH environment variable.
#
#.DESCRIPTION
# Add the specified path to the PATH environment variable.
#
#.PARAMETER Path
# Path to a directory
#
#.PARAMETER Scope
# The environment scope to change. By default only the current
# process is affected.
#
#.EXAMPLE
# PS> Add-EnvrionmentPath -Scope Process -Path c:\path\to\my\cool\tools
##############################
function Add-EnvironmentPath
{
  [CmdletBinding(SupportsShouldProcess = $true)]
  param(
    [Parameter(Mandatory = $true,ValueFromPipeline = $true)]
    [String]$Path,

    [Parameter(Mandatory = $false)]
    [ValidateSet('process','machine','user')]
    [String]$Scope = 'process'
  )

  $Path = $path.TrimEnd('\')
  if (!(Test-Path -Path $Path -PathType container))
  {
    throw 'Invalid Directory'
  }

  if (Test-EnvironmentPath -Scope $Scope -Path $Path)
  {
    throw 'Path already in PATH variable'
  }

  $envPath = Get-EnvironmentPath -Scope $Scope | Select-Object -ExpandProperty path
  $result = $envPath + $paths
  Write-Verbose -Message "New Path: $($result -join ';')"
  if ($PSCmdlet.ShouldProcess('PATH', 'Update Environment Variable'))
  {
    Set-EnvironmentVariable -Scope $Scope -Name PATH -Value ($result -join ';')
  }
}

##############################
#.SYNOPSIS
# Removes the specified path from the environmet PATH variable.
#
#.DESCRIPTION
# Removes the specified path from the environmet PATH variable.
#
#.PARAMETER path
# Path to be removed.
#
#.PARAMETER Scope
# The environment scope to change. By default only the current
# process is affected.
#
#.EXAMPLE
# PS> Remove-EnvironmentPath -Scope process -Path c:\a\misbehaving\tool
##############################
function Remove-EnvironmentPath
{
  [CmdletBinding(SupportsShouldProcess = $true)]
  param(
    [Parameter(Mandatory = $true,ValueFromPipeline = $true)]
    [String]$path,

    [Parameter(Mandatory = $false)]
    [ValidateSet('process','machine','user')]
    [String]$Scope = 'process'
  )

  $envPath = Get-EnvironmentPath -Scope $Scope
  if (!(Test-EnvironmentPath -Scope $Scope -Path ($Path | Select-Object -ExpandProperty Path)))
  {
    throw 'Path not in PATH variable'
  }

  $result = $envPath | Where-Object -FilterScript {
    $_ -ine $Path
  }
  if ($PSCmdlet.ShouldProcess('PATH', "remove: $Path"))
  {
    Set-EnvironmentVariable -Name PATH -Value ($result -join ';')
  }
}
