#Requires -Version 5.1
<#
.SYNOPSIS
    Ожидание перед запуском 1С: нет других процессов платформы, пауза 30 с между стартами.
.DESCRIPTION
    Снижает исчерпание лицензий при автоматических прогонах агента.
    См. @rules/1c-single-instance-launch.mdc
.PARAMETER MinIntervalSec
    Минимальный интервал между запусками (по умолчанию 30).
.PARAMETER WaitProcessesSec
    Сколько секунд ждать освобождения процессов 1С (по умолчанию 600).
#>
function Wait-1cLicenseSlot {
    param(
        [int]$MinIntervalSec = 30,
        [int]$WaitProcessesSec = 600
    )

    $ErrorActionPreference = "Stop"

    $ProcessNames = @("1cv8", "1cv8c", "1cv8s", "1cv8st", "1cv8t")
    $MarkerDir = Split-Path -Parent $PSCommandPath
    $MarkerFile = Join-Path $MarkerDir ".last-1c-launch.txt"

    $deadline = [datetime]::UtcNow.AddSeconds($WaitProcessesSec)
    while ($true) {
        $running = @()
        foreach ($name in $ProcessNames) {
            $running += Get-Process -Name $name -ErrorAction SilentlyContinue
        }
        $running = $running | Sort-Object Id -Unique

        if ($running.Count -eq 0) {
            break
        }
        if ([datetime]::UtcNow -ge $deadline) {
            $ids = ($running | ForEach-Object { "$($_.ProcessName):$($_.Id)" }) -join ", "
            throw "Процессы 1С не завершились за ${WaitProcessesSec} с: $ids. Закройте 1С вручную и повторите."
        }
        Write-Host "[1C] Ожидание завершения процессов 1С ($($running.Count))..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
    }

    if (Test-Path $MarkerFile) {
        $lastUtc = [datetime]::Parse(
            (Get-Content $MarkerFile -Raw).Trim(),
            [System.Globalization.CultureInfo]::InvariantCulture,
            [System.Globalization.DateTimeStyles]::AssumeUniversal)
        $elapsed = ([datetime]::UtcNow - $lastUtc).TotalSeconds
        if ($elapsed -lt 0) {
            $elapsed = 0
        }
        if ($elapsed -lt $MinIntervalSec) {
            $sleepSec = [int][math]::Ceiling($MinIntervalSec - $elapsed)
            Write-Host "[1C] Пауза ${sleepSec} с (лицензии, мин. интервал ${MinIntervalSec} с)..." -ForegroundColor DarkYellow
            Start-Sleep -Seconds $sleepSec
        }
    }

    Set-Content -Path $MarkerFile -Value ([datetime]::UtcNow.ToString("o")) -Encoding UTF8 -NoNewline
    Write-Host "[1C] Слот запуска разрешён." -ForegroundColor DarkGray
}

if ($MyInvocation.InvocationName -ne '.') {
    Wait-1cLicenseSlot @PSBoundParameters
}
