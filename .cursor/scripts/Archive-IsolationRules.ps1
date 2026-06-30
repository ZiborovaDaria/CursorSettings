#Requires -Version 5.1
<#
.SYNOPSIS
  OBSOLETE — _archive/isolation_rules removed (was duplicate of isolation_rules/).

  Supercode memory-bank modes use .cursor/rules/isolation_rules/ only.
  Do not re-archive; use Setup-MemoryBank-AllProjects.ps1 to sync other projects.
#>
Write-Warning 'Archive-IsolationRules.ps1 is obsolete. isolation_rules/ is the single source; _archive removed.'
exit 0
