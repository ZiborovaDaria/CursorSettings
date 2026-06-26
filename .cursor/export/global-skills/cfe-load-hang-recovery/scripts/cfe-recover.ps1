# cfe-recover - diagnose / delete / load extension when LoadConfigFromFiles hangs
# UTF-8 with BOM. Project SB defaults; override via parameters.
param(
	[Parameter(Mandatory)]
	[string]$ExtensionPath,
	[Parameter(Mandatory)]
	[string]$ExtensionName,
	[string]$InfoBasePath = "C:\Users\Daria\Documents\InfoBase11",
	[string]$V8Path,
	[ValidateSet("Diagnose", "Delete", "Load", "Recover")]
	[string]$Action = "Diagnose",
	[int]$LoadTimeoutSec = 90
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Resolve-V8Path {
	param([string]$Path)
	if ($Path -and (Test-Path $Path)) {
		if ((Get-Item $Path).PSIsContainer) { return (Join-Path $Path "1cv8.exe") }
		return $Path
	}
	$found = Get-ChildItem "C:\Program Files\1cv8\*\bin\1cv8.exe" -ErrorAction SilentlyContinue |
		Sort-Object FullName -Descending | Select-Object -First 1
	if (-not $found) { throw "1cv8.exe not found. Specify -V8Path." }
	return $found.FullName
}

function Resolve-ExtensionDir {
	param([string]$Path)
	if (Test-Path $Path -PathType Container) {
		$candidate = Join-Path $Path "Configuration.xml"
		if (Test-Path $candidate) { return (Resolve-Path $Path).Path }
		throw "No Configuration.xml in: $Path"
	}
	if (-not (Test-Path $Path)) { throw "Path not found: $Path" }
	return (Resolve-Path (Split-Path $Path -Parent)).Path
}

function Invoke-Designer {
	param([string[]]$DesignerArgs, [int]$TimeoutSec = 120)
	$argList = @("DESIGNER", "/F", $InfoBasePath, "/DisableStartupMessages", "/DisableStartupDialogs") + $DesignerArgs
	Write-Host "[RUN] 1cv8.exe $($argList -join ' ')"
	$proc = Start-Process -FilePath $script:V8 -ArgumentList $argList -PassThru
	if (-not $proc.WaitForExit($TimeoutSec * 1000)) {
		Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
		return @{ ExitCode = -1; TimedOut = $true }
	}
	return @{ ExitCode = $proc.ExitCode; TimedOut = $false }
}

function Test-ExtensionDump {
	param([string]$DumpDir)
	$cfgFile = Join-Path $DumpDir "Configuration.xml"
	if (-not (Test-Path $cfgFile)) {
		return @{ Exists = $false; ShellOnly = $false; NamePrefix = ""; ChildSummary = "" }
	}
	[xml]$xml = Get-Content $cfgFile -Encoding UTF8
	$ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
	$ns.AddNamespace("md", "http://v8.1c.ru/8.3/MDClasses")
	$childNodes = $xml.SelectNodes("//md:Configuration/md:ChildObjects/md:*", $ns)
	$names = @($childNodes | ForEach-Object { $_.LocalName + ":" + $_.InnerText.Trim() })
	$prefixNode = $xml.SelectSingleNode("//md:Configuration/md:Properties/md:NamePrefix", $ns)
	$prefix = if ($prefixNode) { $prefixNode.InnerText.Trim() } else { "" }
	$shellOnly = ($names.Count -le 1) -and ($names -match "^Language:")
	return @{
		Exists = $true
		ShellOnly = $shellOnly
		NamePrefix = $prefix
		ChildSummary = ($names -join ", ")
	}
}

function Test-ExtensionBsl {
	param([string]$Dir)
	$issues = [System.Collections.Generic.List[string]]::new()
	$patternFile = Join-Path $PSScriptRoot "cfe-risk-patterns.txt"
	if (-not (Test-Path $patternFile)) {
		Write-Host "[WARN] cfe-risk-patterns.txt not found"
		return $issues
	}
	$patterns = Get-Content $patternFile -Encoding UTF8 | Where-Object { $_.Trim() -ne "" }
	$rg = Get-Command rg -ErrorAction SilentlyContinue
	if ($rg) {
		foreach ($pat in $patterns) {
			$hits = & rg -l $pat $Dir -g "*.bsl" 2>$null
			foreach ($h in $hits) {
				$issues.Add("${h}: risky pattern [$pat]")
			}
		}
		return $issues
	}
	$bslFiles = Get-ChildItem -Path $Dir -Filter "*.bsl" -Recurse -ErrorAction SilentlyContinue
	foreach ($file in $bslFiles) {
		$text = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
		foreach ($pat in $patterns) {
			if ($text.Contains($pat)) {
				$issues.Add("$($file.FullName): risky pattern [$pat]")
			}
		}
	}
	return $issues
}

$script:V8 = Resolve-V8Path $V8Path
$extDir = Resolve-ExtensionDir $ExtensionPath
$logsDir = Join-Path $env:TEMP "cfe-recover-logs"
New-Item -ItemType Directory -Path $logsDir -Force | Out-Null

Write-Host "=== cfe-recover: $Action ==="
Write-Host "  Extension: $ExtensionName"
Write-Host "  Path:      $extDir"
Write-Host "  IB:        $InfoBasePath"
Write-Host "  V8:        $script:V8"
Write-Host ""

Get-Process 1cv8 -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

if ($Action -eq "Diagnose" -or $Action -eq "Recover") {
	Write-Host "--- Diagnose IB ---"
	$dumpDir = Join-Path $env:TEMP ("cfe-dump-" + [guid]::NewGuid().ToString("N").Substring(0, 8))
	New-Item -ItemType Directory -Path $dumpDir -Force | Out-Null
	$r = Invoke-Designer @("/DumpConfigToFiles", $dumpDir, "-Extension", $ExtensionName) 120
	if ($r.TimedOut) {
		Write-Host "[WARN] Dump timed out"
	}
	elseif ($r.ExitCode -ne 0) {
		Write-Host "[OK] Extension not in IB (dump exit $($r.ExitCode))"
	}
	else {
		$info = Test-ExtensionDump $dumpDir
		if ($info.Exists) {
			Write-Host "[INFO] Extension in IB. ChildObjects: $($info.ChildSummary)"
			Write-Host "[INFO] NamePrefix: '$($info.NamePrefix)'"
			if ($info.ShellOnly) {
				Write-Host "[ERROR] BROKEN SHELL in IB (only Language). Run -Action Delete or Recover"
			}
			else {
				Write-Host "[OK] Extension in IB looks populated"
			}
		}
	}
	Remove-Item $dumpDir -Recurse -Force -ErrorAction SilentlyContinue

	Write-Host ""
	Write-Host "--- Diagnose files ---"
	$validateScript = Join-Path $PSScriptRoot "..\..\1c-metadata-manage\tools\1c-cfe-manage\scripts\cfe-validate.ps1"
	if (Test-Path $validateScript) {
		& powershell.exe -NoProfile -File $validateScript -ExtensionPath $extDir
	}
	else {
		Write-Host "[WARN] cfe-validate.ps1 not found"
	}

	if (Test-Path (Join-Path $extDir "ConfigDumpInfo.xml")) {
		Write-Host "[WARN] ConfigDumpInfo.xml present - remove if load hangs"
	}

	$bslIssues = Test-ExtensionBsl $extDir
	foreach ($i in $bslIssues) { Write-Host "[WARN] $i" }
	if ($bslIssues.Count -eq 0) { Write-Host "[OK] No known risky BSL patterns" }

	$verifyScript = Join-Path $PSScriptRoot "cfe-verify-interceptors.ps1"
	if (Test-Path $verifyScript) {
		Write-Host ""
		Write-Host "--- Verify interceptors vs typical ---"
		& powershell.exe -NoProfile -File $verifyScript -ExtensionPath $extDir
		if ($LASTEXITCODE -ne 0) {
			Write-Host "[ERROR] Invalid interceptors - fix before LoadConfigFromFiles"
		}
	}
	Write-Host ""
}

if ($Action -eq "Delete" -or $Action -eq "Recover") {
	Write-Host "--- DeleteCfg ---"
	$log = Join-Path $logsDir "cfe-delete.log"
	$r = Invoke-Designer @("/DeleteCfg", "-Extension", $ExtensionName, "/Out", $log) 120
	if ($r.ExitCode -eq 0) {
		Write-Host "[OK] DeleteCfg exit 0"
	}
	else {
		Write-Host "[WARN] DeleteCfg exit $($r.ExitCode) - check $log"
	}
	Write-Host ""
}

if ($Action -eq "Load" -or $Action -eq "Recover") {
	Write-Host "--- LoadConfigFromFiles ---"
	$log = Join-Path $logsDir "cfe-load.log"
	$sw = [Diagnostics.Stopwatch]::StartNew()
	$r = Invoke-Designer @(
		"/LoadConfigFromFiles", $extDir,
		"-Extension", $ExtensionName,
		"/Out", $log
	) $LoadTimeoutSec
	$sw.Stop()
	if ($r.TimedOut) {
		Write-Host "[FAIL] Load timed out (>$LoadTimeoutSec s) - fix shell in IB or BSL/XML"
		exit 2
	}
	if ($r.ExitCode -eq 0 -and $sw.Elapsed.TotalSeconds -lt 60) {
		Write-Host "[OK] Load exit 0 in $([math]::Round($sw.Elapsed.TotalSeconds, 1))s"
		exit 0
	}
	Write-Host "[FAIL] Load exit $($r.ExitCode) in $([math]::Round($sw.Elapsed.TotalSeconds, 1))s - see $log"
	exit 1
}

exit 0
