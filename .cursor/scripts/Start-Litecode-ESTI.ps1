#Requires -Version 5.1
<#
.SYNOPSIS
  Start litecode ESTI stack (port 6004).
#>
[CmdletBinding()]
param(
    [ValidateSet('fast', 'full')]
    [string]$Profile = 'fast',
    [switch]$Force
)

& (Join-Path $PSScriptRoot 'Start-Litecode-Project.ps1') -ProjectId ESTI -Profile $Profile -Force:$Force
