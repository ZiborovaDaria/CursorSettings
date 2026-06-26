#Requires -Version 5.1
<#
.SYNOPSIS
  Генерирует .cursor/mcp.json для проектов 1С из шаблона.

.EXAMPLE
  .\sync-project-mcp.ps1
  .\sync-project-mcp.ps1 -Projects C:\Cursor\UT25_85
  .\sync-project-mcp.ps1 -WhatIf
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
    [string]$TemplatePath = (Join-Path $env:USERPROFILE '.cursor\templates\mcp.project.template.json')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ProjectMap = @{
    'C:\Cursor\BP'        = @{ Repo = 'BP';        McpPath = '/BP_199_13';        RestUrl = 'http://localhost/BP_199_13';        HasIb = $true }
    'C:\Cursor\ESTI'      = @{ Repo = 'ESTI';      McpPath = '/ESTI';           RestUrl = 'http://localhost/ESTI';           HasIb = $true }
    'C:\Cursor\KA'        = @{ Repo = 'KA';        McpPath = '/KA';             RestUrl = 'http://localhost/KA';             HasIb = $true }
    'C:\Cursor\Obshep'    = @{ Repo = 'Obshep';    McpPath = '';                RestUrl = '';                              HasIb = $false }
    'C:\Cursor\UNF12_261' = @{ Repo = 'UNF12_261'; McpPath = '';                RestUrl = '';                              HasIb = $false }
    'C:\Cursor\UPO'       = @{ Repo = 'UPO';       McpPath = '';                RestUrl = '';                              HasIb = $false }
    'C:\Cursor\UT22_92'   = @{ Repo = 'UT22_92';   McpPath = '/UT';             RestUrl = 'http://localhost/UT';             HasIb = $true }
    'C:\Cursor\UT25_85'   = @{ Repo = 'UT25_85';   McpPath = '/UT25_85';        RestUrl = 'http://localhost/UT25_85';        HasIb = $true }
}

if (-not (Test-Path -LiteralPath $TemplatePath)) {
    throw "Template not found: $TemplatePath"
}

$templateJson = Get-Content -LiteralPath $TemplatePath -Raw -Encoding UTF8 | ConvertFrom-Json

foreach ($project in $Projects) {
    if (-not (Test-Path -LiteralPath $project)) {
        Write-Warning "Skip missing: $project"
        continue
    }
    if (-not $ProjectMap.ContainsKey($project)) {
        Write-Warning "No map entry: $project"
        continue
    }

    $map = $ProjectMap[$project]
    $mcp = $templateJson | ConvertTo-Json -Depth 20 | ConvertFrom-Json

  # code-index repo
    $mcp.mcpServers.'code-index'.args = @(
        'serve',
        '--path',
        "$($map.Repo)=`${workspaceFolder}"
    )

    if ($map.HasIb) {
        $mcp.mcpServers.'mcp-1c'.args = @(
            '--base',
            "http://localhost$($map.McpPath)/hs/mcp-1c",
            '--user',
            '%MCP_1C_USER%',
            '--password',
            '%MCP_1C_PASSWORD%'
        )
        $mcp.mcpServers.'1c-rest-mcp'.env.ONEC_BASE_URL = $map.RestUrl
    } else {
        $mcp.mcpServers.PSObject.Properties.Remove('mcp-1c')
        $mcp.mcpServers.PSObject.Properties.Remove('1c-rest-mcp')
    }

    $target = Join-Path $project '.cursor\mcp.json'
    $json = $mcp | ConvertTo-Json -Depth 20
    if ($PSCmdlet.ShouldProcess($target, 'Write mcp.json')) {
        $dir = Split-Path $target -Parent
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        [System.IO.File]::WriteAllText($target, $json, [System.Text.UTF8Encoding]::new($false))
        Write-Host "OK $target"
    }
}
