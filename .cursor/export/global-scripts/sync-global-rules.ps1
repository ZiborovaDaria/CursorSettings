#Requires -Version 5.1
<#
.SYNOPSIS
  Sync ~/.cursor/rules/*.mdc to projects as global-*.mdc

.EXAMPLE
  .\sync-global-rules.ps1
  .\sync-global-rules.ps1 -Projects C:\Cursor\UT25_85
  .\sync-global-rules.ps1 -WhatIf
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string[]]$Projects = @(
        'C:\Cursor\BP',
        'C:\Cursor\ESTI',
        'C:\Cursor\KA',
        'C:\Cursor\Obshep',
        'C:\Cursor\UNF12_261',
        'C:\Cursor\UPO',
        'C:\Cursor\UT22_92',
        'C:\Cursor\UT25_85'
    ),
    [string]$Source = (Join-Path $env:USERPROFILE '.cursor\rules'),
    [string]$GlobalPrefix = 'global-'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-SyncBanner {
    param([string]$SourceFileName)
    return "<!-- Source: ~/.cursor/rules/$SourceFileName | edit there, then run sync-global-rules.ps1 -->"
}

function Add-SyncBanner {
    param(
        [string]$Content,
        [string]$SourceFileName
    )

    $banner = Get-SyncBanner -SourceFileName $SourceFileName
    if ($Content -match [regex]::Escape($banner)) {
        return $Content
    }

    if ($Content -match '(?s)^---\r?\n.*?\r?\n---\r?\n') {
        return ($Matches[0] + "`n" + $banner + "`n" + $Content.Substring($Matches[0].Length).TrimStart("`r", "`n"))
    }

    return ($banner + "`n`n" + $Content)
}

if (-not (Test-Path -LiteralPath $Source)) {
    throw "Source folder not found: $Source"
}

$sourceFiles = Get-ChildItem -LiteralPath $Source -Filter '*.mdc' -File | Sort-Object Name
if ($sourceFiles.Count -eq 0) {
    Write-Warning "No *.mdc files in $Source"
    return
}

$expectedNames = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($file in $sourceFiles) {
    [void]$expectedNames.Add("$GlobalPrefix$($file.Name)")
}

$totalCopied = 0
$totalRemoved = 0
$totalSkipped = 0

foreach ($project in $Projects) {
    if (-not (Test-Path -LiteralPath $project)) {
        Write-Warning "Skip missing project: $project"
        continue
    }

    $targetDir = Join-Path $project '.cursor\rules'
    if (-not (Test-Path -LiteralPath $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    Write-Host ""
    Write-Host "=== $project ===" -ForegroundColor Cyan

    foreach ($file in $sourceFiles) {
        $targetName = "$GlobalPrefix$($file.Name)"
        $targetPath = Join-Path $targetDir $targetName
        $content = Add-SyncBanner -Content (Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8) -SourceFileName $file.Name

        $needsWrite = $true
        if (Test-Path -LiteralPath $targetPath) {
            $existing = Get-Content -LiteralPath $targetPath -Raw -Encoding UTF8
            if ($existing -eq $content) {
                $needsWrite = $false
                $totalSkipped++
            }
        }

        if ($needsWrite) {
            if ($PSCmdlet.ShouldProcess($targetPath, 'Write global rule')) {
                [System.IO.File]::WriteAllText($targetPath, $content, [System.Text.UTF8Encoding]::new($false))
                Write-Host "  + $targetName"
                $totalCopied++
            }
        }
    }

    $stale = Get-ChildItem -LiteralPath $targetDir -Filter "$GlobalPrefix*.mdc" -File |
        Where-Object { -not $expectedNames.Contains($_.Name) }

    foreach ($file in $stale) {
        if ($PSCmdlet.ShouldProcess($file.FullName, 'Remove stale global rule')) {
            Remove-Item -LiteralPath $file.FullName -Force
            Write-Host "  - $($file.Name) (stale)" -ForegroundColor Yellow
            $totalRemoved++
        }
    }
}

Write-Host ""
Write-Host "Done: written=$totalCopied unchanged=$totalSkipped removed=$totalRemoved" -ForegroundColor Green
