
function Get-EnvironmentVariable
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String]$Name,

        [Parameter(Mandatory=$false)]
        [ValidateSet('process','machine','user')]
        [String]$Scope = 'process'
    )
    
    [Environment]::GetEnvironmentVariable($Name, $Scope)
}

function Set-EnvironmentVariable
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String]$Name,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String]$Value,

        [Parameter(Mandatory=$false)]
        [ValidateSet('process','machine','user')]
        [String]$Scope = 'process'
    )
    
    Write-Verbose "Setting '$Name' to '$Value' on '$Scope'"
    if ($PSCmdlet.ShouldProcess("[$Scope]::$Name", $Value))
    {
        [Environment]::SetEnvironmentVariable($Name, $Value, $Scope)
    }
}

function Get-EnvironmentPath
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [ValidateSet('process','machine','user')]
        [String]$Scope = 'process'
    )
    
    (Get-EnvironmentVariable -Name 'PATH' -Scope $Scope) -split ';' 
}

function Repair-EnvironmentPath
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$false)]
        [ValidateSet('process','machine','user')]
        [String]$Scope = 'process'
    )
    if ($Scope -eq 'process')
    {
        Write-Warning 'This will change current-process value only. This may not be what you intended; see -Scope'
    }

    # Ensure unique paths only
    $path = Get-EnvironmentPath
    $newPath = $path | Select-Object -Unique
    $msg = "Remove $($path.count - $newPath.count) duplicate path(s)"
    Write-Verbose $msg
    $PSCmdlet.ShouldProcess($msg) | Out-Null
    $path = $newPath

    #remove empty paths
    $newPath = $path |  Where-Object { $_.Trim -ne '' } 
    $msg = "Remove $($path.count - $newPath.count) empty path(s)"
    Write-Verbose $msg
    $PSCmdlet.ShouldProcess($msg) | Out-Null
    $path = $newPath

    # Remove invalid paths
    $result = New-Object System.Collections.ArrayList
    $result.AddRange(($path | Where-Object { Test-Path $_ }))
    $path |  Where-Object { ! $result.Contains($_) } |  ForEach-Object { Write-Verbose "Found Invalid Path $_"; $PSCmdlet.ShouldProcess($_, 'Remove invalid path') | Out-Null }

    if ($PSCmdlet.ShouldProcess('PATH', 'Write Environment Variable'))
    {
        Set-EnvironmentVariable -Scope $Scope -Name PATH -Value ($result -join ';')
    }
}

function Test-EnvironmentPath
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String]$Path,

        [Parameter(Mandatory=$false)]
        [ValidateSet('process','machine','user')]
        [String]$Scope = 'process'
    )

    (Get-EnvironmentPath -Scope $Scope | Where-Object { $_ -ieq $Path }).Count -gt 0
}

function Add-EnvironmentPath
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String]$Path,

        [Parameter(Mandatory=$false)]
        [ValidateSet('process','machine','user')]
        [String]$Scope = 'process'
    )
    

    $Path = $Path.TrimEnd('\')
    if (!(Test-Path -Path $Path -PathType container))
    {
        throw 'Invalid Path'
    }

    $envPath = Get-EnvironmentPath -Scope $Scope
    if (Test-EnvironmentPath -Scope $Scope -Path $Path)
    {
        throw 'Path already in PATH variable'
    }
    
    $result = $envPath + $Path
    Write-Verbose "New Path: $($result -join ';')"
    if ($PSCmdlet.ShouldProcess('PATH', 'Update Environment Variable'))
    {
        Set-EnvironmentVariable -Scope $Scope -Name PATH -Value ($result -join ';')   
    }
}

function Remove-EnvironmentPath
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String]$Path,

        [Parameter(Mandatory=$false)]
        [ValidateSet('process','machine','user')]
        [String]$Scope = 'process'
    )
    
    $envPath = Get-EnvironmentPath -Scope $Scope
    if (!(Test-EnvironmentPath -Scope $Scope -Path $Path))
    {
        throw 'Path not in PATH variable'
    }

    $result = $envPath | Where-Object { $_ -ine $Path }
    if ($PSCmdlet.ShouldProcess('PATH', "remove: $Path"))
    {
        Set-EnvironmentVariable -Name PATH -Value ($result -join ';')
    }
}