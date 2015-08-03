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
        [String]$Scope = 'process'
    )
    
    (Get-EnvironmentVariable -Name 'PATH' -Scope $Scope) -split ';' 
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

    # Ensure unique paths only
    $path = Get-EnvironmentPath
    $newPath = $path | Select-Object -Unique
    $msg = "Remove $($path.count - $newPath.count) duplicate path(s)"
    Write-Verbose -Message $msg
    $null = $PSCmdlet.ShouldProcess($msg)
    $path = $newPath

    #remove empty paths
    $newPath = $path |  Where-Object -FilterScript {
        $_.Trim -ne '' 
    } 
    $msg = "Remove $($path.count - $newPath.count) empty path(s)"
    Write-Verbose -Message $msg
    $null = $PSCmdlet.ShouldProcess($msg)
    $path = $newPath

    # Remove invalid paths
    $result = New-Object -TypeName System.Collections.ArrayList
    $result.AddRange(($path | Where-Object -FilterScript {
                Test-Path $_ 
    }))
    $path |
    Where-Object -FilterScript {
        ! $result.Contains($_) 
    } |
    ForEach-Object -Process {
        Write-Verbose -Message "Found Invalid Path $_"
        $null = $PSCmdlet.ShouldProcess($_, 'Remove invalid path')
    }

    if ($PSCmdlet.ShouldProcess('PATH', 'Write Environment Variable'))
    {
        Set-EnvironmentVariable -Scope $Scope -Name PATH -Value ($result -join ';')
    }
}

function Test-EnvironmentPath
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,ValueFromPipeline = $true)]
        [String]$path,

        [Parameter(Mandatory = $false)]
        [ValidateSet('process','machine','user')]
        [String]$Scope = 'process'
    )

    (Get-EnvironmentPath -Scope $Scope | Where-Object -FilterScript {
            $_ -ieq $path 
    }).Count -gt 0
}

function Add-EnvironmentPath
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true,ValueFromPipeline = $true)]
        [String]$path,

        [Parameter(Mandatory = $false)]
        [ValidateSet('process','machine','user')]
        [String]$Scope = 'process'
    )
    

    $path = $path.TrimEnd('\')
    if (!(Test-Path -Path $path -PathType container))
    {
        throw 'Invalid Path'
    }

    $envPath = Get-EnvironmentPath -Scope $Scope
    if (Test-EnvironmentPath -Scope $Scope -Path $path)
    {
        throw 'Path already in PATH variable'
    }
    
    $result = $envPath + $path
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
    if (!(Test-EnvironmentPath -Scope $Scope -Path $path))
    {
        throw 'Path not in PATH variable'
    }

    $result = $envPath | Where-Object -FilterScript {
        $_ -ine $path 
    }
    if ($PSCmdlet.ShouldProcess('PATH', "remove: $path"))
    {
        Set-EnvironmentVariable -Name PATH -Value ($result -join ';')
    }
}
