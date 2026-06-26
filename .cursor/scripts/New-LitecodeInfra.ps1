#Requires -Version 5.1
<#
.SYNOPSIS
  Сгенерировать docker-compose.fast.yml для litecode проекта.

.PARAMETER ProjectId
  ID из projects.manifest.json.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectId,
    [string]$ManifestPath
)

$ErrorActionPreference = 'Stop'
$settingsRepo = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$manifestFile = if ($ManifestPath) { $ManifestPath } else { Join-Path $settingsRepo '.cursor\projects.manifest.json' }
$manifest = Get-Content $manifestFile -Raw -Encoding UTF8 | ConvertFrom-Json
$proj = $manifest.projects | Where-Object { $_.id -eq $ProjectId } | Select-Object -First 1
if (-not $proj) { throw "Project not found: $ProjectId" }

$idLower = $ProjectId.ToLower()
$port = $proj.litecodePort
$container = "1c-metacode-$idLower"
$volSuffix = ($ProjectId -replace '[^a-zA-Z0-9]', '_').ToLower()
$dataPath = "C:/bsl-litecode-data/$ProjectId"
$infraDir = Join-Path $proj.path ".cursor\infra\litecode-$idLower"
New-Item -ItemType Directory -Path $infraDir -Force | Out-Null

$compose = @"
# fast profile — без embedding. Project: $ProjectId, port $port
name: litecode-$idLower-fast

services:
  memgraph:
    image: memgraph/memgraph:latest
    restart: unless-stopped
    volumes:
      - memgraph_data_${volSuffix}:/var/lib/memgraph
    environment:
      - MEMGRAPH_ARGS=--memory-limit=256 --log-level=WARNING
    healthcheck:
      test: ["CMD-SHELL", "echo 'RETURN 1;' | mgconsole || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 5s

  ${container}:
    image: svhov/1c-litecode
    container_name: $container
    restart: unless-stopped
    ports:
      - "${port}:6001"
    volumes:
      - ${dataPath}:/app/data:ro
    environment:
      - PROJECT_NAME=$idLower
      - MEMGRAPH_URI=bolt://memgraph:7687
      - MCP_PORT=6001
      - INDEXING_MODE=fast
      - FULL_METADATA_RELOAD=false
      - LOAD_BSL_SIGNATURES=true
      - LOAD_FORMS_FROM_XML=true
      - LOAD_PREDEFINED_VALUES=true
      - LOAD_ROLE_RIGHTS=true
      - ENABLE_EMBEDDING=false
    depends_on:
      memgraph:
        condition: service_healthy

volumes:
  memgraph_data_${volSuffix}:
    driver: local
"@

$outFile = Join-Path $infraDir 'docker-compose.fast.yml'
[IO.File]::WriteAllText($outFile, $compose, [Text.UTF8Encoding]::new($false))
Write-Host "Wrote: $outFile (port $port)"

# Patch mcp.json litecode URL if present
$mcpFile = Join-Path $proj.path '.cursor\mcp.json'
if (Test-Path $mcpFile) {
    $json = Get-Content $mcpFile -Raw -Encoding UTF8
    $newUrl = "http://localhost:$port/sse"
    if ($json -match '"litecode"\s*:\s*\{') {
        $patched = $json -replace '("litecode"[\s\S]*?"url"\s*:\s*")[^"]+(")', "`${1}$newUrl`${2}"
        if ($patched -ne $json) {
            [IO.File]::WriteAllText($mcpFile, $patched, [Text.UTF8Encoding]::new($false))
            Write-Host "Updated mcp.json litecode -> $newUrl"
        }
    }
}
