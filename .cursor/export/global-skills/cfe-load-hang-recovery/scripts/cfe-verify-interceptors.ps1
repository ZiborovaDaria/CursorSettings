# cfe-verify-interceptors - validate extension interceptors against base configuration
# UTF-8 with BOM. Exit 0 = OK, 1 = invalid interceptors found.
param(
	[Parameter(Mandatory)]
	[string]$ExtensionPath,
	[string]$ConfigPath = "C:\Cursor\SB",
	[switch]$Quiet
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Cyrillic keywords (avoid source encoding issues)
$KwProc = [char]0x041F + [char]0x0440 + [char]0x043E + [char]0x0446 + [char]0x0435 + [char]0x0434 + [char]0x0443 + [char]0x0440 + [char]0x0430
$KwFunc = [char]0x0424 + [char]0x0443 + [char]0x043D + [char]0x043A + [char]0x0446 + [char]0x0438 + [char]0x044F

function Resolve-ExtensionDir {
	param([string]$Path)
	if (Test-Path $Path -PathType Container) {
		$candidate = Join-Path $Path "Configuration.xml"
		if (Test-Path $candidate) { return (Resolve-Path $Path).Path }
		throw "No Configuration.xml in: $Path"
	}
	throw "Path not found: $Path"
}

function Test-HandlerInTypical {
	param(
		[string]$ConfigRoot,
		[string]$ModuleRelPath,
		[string]$HandlerName
	)
	$typicalPath = Join-Path $ConfigRoot ($ModuleRelPath -replace '/', '\')
	if (-not (Test-Path $typicalPath)) {
		return @{ Found = $false; Reason = "typical module not found: $ModuleRelPath" }
	}
	$escaped = [regex]::Escape($HandlerName)
	$pattern = "(?m)^\s*(?:$KwProc|$KwFunc)\s+$escaped\s*\("
	$text = [System.IO.File]::ReadAllText($typicalPath, [System.Text.Encoding]::UTF8)
	if ($text -match $pattern) {
		return @{ Found = $true; TypicalPath = $typicalPath }
	}
	return @{ Found = $false; Reason = "no handler $HandlerName in $typicalPath" }
}

function Get-InterceptorsFromBsl {
	param([string]$Text)
	$list = [System.Collections.Generic.List[object]]::new()
	# &<word>("HandlerName")
	$rx = [regex]'&\w+\("([^"]+)"\)'
	foreach ($m in $rx.Matches($Text)) {
		$ann = $m.Value
		if ($ann -notmatch '^&\w+\(') { continue }
		# only extension annotations (Cyrillic word after &)
		if ($ann -notmatch '^&[\u0400-\u04FF]') { continue }
		$list.Add([PSCustomObject]@{ Handler = $m.Groups[1].Value; Annotation = ($ann -replace '\(".*', '') })
	}
	return $list
}

$extDir = Resolve-ExtensionDir $ExtensionPath
if (-not (Test-Path $ConfigPath)) {
	Write-Error "ConfigPath not found: $ConfigPath"
}

$issues = [System.Collections.Generic.List[string]]::new()
$checked = 0
$moduleRx = '^(Documents|Catalogs|DataProcessors|Reports|ChartsOfAccounts|ChartsOfCharacteristicTypes|ExchangePlans|BusinessProcesses|Tasks)\\[^\\]+\\Ext\\(ObjectModule|ManagerModule)\.bsl$'

$bslFiles = Get-ChildItem -Path $extDir -Filter "*.bsl" -Recurse -ErrorAction SilentlyContinue
foreach ($file in $bslFiles) {
	$rel = $file.FullName.Substring($extDir.Length).TrimStart('\', '/')
	if ($rel -notmatch $moduleRx) { continue }

	$text = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
	foreach ($item in (Get-InterceptorsFromBsl $text)) {
		$checked++
		$result = Test-HandlerInTypical -ConfigRoot $ConfigPath -ModuleRelPath $rel -HandlerName $item.Handler
		if (-not $result.Found) {
			$msg = "$rel : $($item.Annotation)(`"$($item.Handler)`") - $($result.Reason)"
			$issues.Add($msg)
		}
	}
}

if (-not $Quiet) {
	Write-Host "=== cfe-verify-interceptors ==="
	Write-Host "  Extension: $extDir"
	Write-Host "  Config:    $ConfigPath"
	Write-Host "  Checked:   $checked interceptor(s)"
}

if ($issues.Count -gt 0) {
	if (-not $Quiet) {
		Write-Host "[FAIL] Invalid interceptor(s):"
		foreach ($i in $issues) { Write-Host "  $i" }
	}
	exit 1
}

if (-not $Quiet) {
	Write-Host "[OK] All interceptors match typical module handlers"
}
exit 0
