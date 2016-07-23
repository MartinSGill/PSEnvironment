#requires -Version 2

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

function Set-EnvironmentVariable
{
  [CmdletBinding(SupportsShouldProcess = $true)]
  param(
    [Parameter(Mandatory = $true,ValueFromPipeline = $true)]
    [String]$Name,

    [Parameter(Mandatory = $true,ValueFromPipeline = $true)]
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
      [pscustomobject]@{
        Path   = $paths
        Scope  = $s
        Exists = Test-Path($paths)
      }
    }
  }
}

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
      Write-Verbose -Message 'Found empty path, skipping'
      if ($PSCmdlet.ShouldProcess($path, 'Skip empty path entry')) 
      {
        continue
      }
    }
      
    $path = $path.Trim()
    if ($path -in $result) 
    {
      Write-Verbose -Message 'Found duplicate path, skipping'
      if ($PSCmdlet.ShouldProcess($path, 'Skip duplicate path entry')) 
      {
        continue
      }
    }

    if (-not (Test-Path $path -PathType Container)) 
    {
      Write-Verbose -Message 'Found invliad path, skipping'
      if ($PSCmdlet.ShouldProcess($path, 'Skip invalid path entry')) 
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
    

  $paths = $paths.TrimEnd('\')
  if (!(Test-Path -Path $path -PathType container))
  {
    throw 'Invalid Path'
  }

  if (Test-EnvironmentPath -Scope $Scope -Path $paths)
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
  if (!(Test-EnvironmentPath -Scope $Scope -Path ($paths | Select-Object -ExpandProperty Path)))
  {
    throw 'Path not in PATH variable'
  }

  $result = $envPath | Where-Object -FilterScript {
    $_ -ine $paths
  }
  if ($PSCmdlet.ShouldProcess('PATH', "remove: $paths"))
  {
    Set-EnvironmentVariable -Name PATH -Value ($result -join ';')
  }
}

