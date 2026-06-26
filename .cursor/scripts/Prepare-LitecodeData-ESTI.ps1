#Requires -Version 5.1
<#
.SYNOPSIS
  Обёртка Prepare-LitecodeData для ЭСТИ.
#>
[CmdletBinding()]
param(
    [string]$TargetPath = 'C:\bsl-litecode-data\ESTI',
    [string]$SourcePath = 'C:\Cursor\ESTI'
)

& (Join-Path $PSScriptRoot 'Prepare-LitecodeData.ps1') -ProjectId ESTI -SourcePath $SourcePath -TargetPath $TargetPath
