#Requires -Version 5.1
# Patch supercode memory-bank modes: memory-bank paths, broken rule refs.
param([string]$ModesDir)

$ErrorActionPreference = 'Stop'
$dir = if ($ModesDir) { $ModesDir } else {
    Join-Path (Resolve-Path (Join-Path $PSScriptRoot '..\..')) '.supercode\modes\memory-bank'
}
if (-not (Test-Path $dir)) { throw "Not found: $dir" }

function Patch-File {
    param([string]$Path, [hashtable]$Replacements)
    $c = [IO.File]::ReadAllText($Path, [Text.UTF8Encoding]::new($false))
    $orig = $c
    foreach ($k in $Replacements.Keys) {
        $c = $c -replace [regex]::Escape($k), $Replacements[$k]
    }
    if ($c -ne $orig) {
        [IO.File]::WriteAllText($Path, $c, [Text.UTF8Encoding]::new($false))
        Write-Host "  patched: $([IO.Path]::GetFileName($Path))"
    }
}

$common = @{
    'target_file: "tasks.md"' = 'target_file: "memory-bank/tasks.md"'
    'target_file: "progress.md"' = 'target_file: "memory-bank/progress.md"'
    'Phases/Implementation/implementation-phase-reference.mdc' = 'Level3/implementation-intermediate.mdc'
    'isolation_rules/visual-maps/van_mode_split/van-mode-map"' = 'isolation_rules/visual-maps/van_mode_split/van-mode-map.mdc"'
    'isolation_rules/visual-maps/plan-mode-map"' = 'isolation_rules/visual-maps/plan-mode-map.mdc"'
    'isolation_rules/visual-maps/creative-mode-map"' = 'isolation_rules/visual-maps/creative-mode-map.mdc"'
    'isolation_rules/visual-maps/implement-mode-map"' = 'isolation_rules/visual-maps/implement-mode-map.mdc"'
    'isolation_rules/visual-maps/qa-mode-map"' = 'isolation_rules/visual-maps/qa-mode-map.mdc"'
}

Get-ChildItem $dir -Filter '*.yml' | ForEach-Object { Patch-File $_.FullName $common }

Patch-File (Join-Path $dir 'creative.yml') @{
    'Read tasks.md &<br>implementation-plan.md<br>' = 'Read memory-bank/tasks.md &<br>memory-bank/activeContext.md<br>'
    @'
        read_file({
          target_file: "memory-bank/tasks.md",
          should_read_entire_file: true
        })

        read_file({
          target_file: "implementation-plan.md",
'@ = @'
        read_file({
          target_file: "memory-bank/tasks.md",
          should_read_entire_file: true
        })

        read_file({
          target_file: "memory-bank/activeContext.md",
'@
}

Patch-File (Join-Path $dir 'implement.yml') @{
    @'
        read_file({
          target_file: "memory-bank/tasks.md",
          should_read_entire_file: true
        })

        read_file({
          target_file: "implementation-plan.md",
'@ = @'
        read_file({
          target_file: "memory-bank/tasks.md",
          should_read_entire_file: true
        })

        read_file({
          target_file: "memory-bank/activeContext.md",
'@
}

$reflectArchive = @{
    'Create reflection.md' = 'Create memory-bank/reflection/reflection-YYYY-MM-DD-slug.md'
    'Create ReflectDoc["📄 Create reflection.md"]' = 'CreateReflectDoc["📄 Create memory-bank/reflection/reflection-YYYY-MM-DD-slug.md"]'
    'CreateDoc["📄 Create reflection.md"]' = 'CreateDoc["📄 Create memory-bank/reflection/reflection-YYYY-MM-DD-slug.md"]'
    'in docs/archive/' = 'in memory-bank/archive/'
    'Create Archive Document<br>in docs/archive/' = 'Create memory-bank/archive/archive-YYYY-MM-DD-slug.md'
    'CreateArchiveDoc["📄 Create Archive Document<br>in docs/archive/"]' = 'CreateArchiveDoc["📄 Create memory-bank/archive/archive-YYYY-MM-DD-slug.md"]'
    'reflection.md, and update tasks.md' = 'memory-bank/reflection/, and update memory-bank/tasks.md'
    'in docs/archive/, update all relevant Memory Bank' = 'in memory-bank/archive/, update Memory Bank'
    'Verify reflection.md<br>is Complete' = 'Verify reflection doc<br>in memory-bank/reflection/'
    'Verify["✅ Verify reflection.md<br>is Complete"]' = 'Verify["✅ Verify reflection doc<br>in memory-bank/reflection/"]'
    'reflection.md created? [YES/NO]' = 'reflection doc in memory-bank/reflection/? [YES/NO]'
    'tasks.md updated with reflection status? [YES/NO]' = 'memory-bank/tasks.md updated with reflection status? [YES/NO]'
    'Archive document placed in correct location (docs/archive/)? [YES/NO]' = 'Archive in memory-bank/archive/? [YES/NO]'
    'tasks.md marked as COMPLETED? [YES/NO]' = 'memory-bank/tasks.md marked COMPLETED? [YES/NO]'
    'progress.md updated with archive reference? [YES/NO]' = 'memory-bank/progress.md updated with archive link? [YES/NO]'
    'activeContext.md updated for next task? [YES/NO]' = 'memory-bank/activeContext.md reset for next task? [YES/NO]'
    'create the formal archive record in docs/archive/, update all relevant Memory Bank files to mark the task as fully complete, and prepare the context for the next task.' = 'create the formal archive in memory-bank/archive/, update Memory Bank files, reset activeContext.md for the next task.'
}

Patch-File (Join-Path $dir 'reflect.yml') $reflectArchive
Patch-File (Join-Path $dir 'archive.yml') $reflectArchive

# activeContext read step in reflect/archive
$ctxBlock = @'

        read_file({
          target_file: "memory-bank/activeContext.md",
          should_read_entire_file: true
        })
'@
foreach ($name in @('reflect.yml', 'archive.yml')) {
    $p = Join-Path $dir $name
    $c = [IO.File]::ReadAllText($p, [Text.UTF8Encoding]::new($false))
    if ($c -notmatch 'memory-bank/activeContext\.md') {
        $c = $c -replace '(target_file: "memory-bank/progress\.md",\s+should_read_entire_file: true\s+\})', "`$1$ctxBlock"
        [IO.File]::WriteAllText($p, $c, [Text.UTF8Encoding]::new($false))
        Write-Host "  patched: $name (+activeContext)"
    }
}

Write-Host "Done: $dir"
