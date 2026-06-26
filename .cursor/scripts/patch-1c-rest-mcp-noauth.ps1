# Патч @theyahia/1c-rest-mcp для публикации без HTTP Basic Auth (ONEC_NO_AUTH=1).
# Запускать после npx -y @theyahia/1c-rest-mcp, если REST MCP снова требует логин/пароль.

$ErrorActionPreference = 'Stop'
$files = Get-ChildItem "$env:LOCALAPPDATA\npm-cache\_npx" -Recurse -Filter 'client.js' -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -match '[\\/]1c-rest-mcp[\\/]dist[\\/]client\.js$' }

if (-not $files) {
    Write-Warning 'Файл 1c-rest-mcp/dist/client.js не найден. Сначала запустите MCP 1c-rest-mcp в Cursor.'
    exit 1
}

$needle = 'import { BaseHttpClient, BasicAuthStrategy, createLogger }'
$replacement = 'import { BaseHttpClient, BasicAuthStrategy, NoAuthStrategy, createLogger }'

foreach ($file in $files) {
    $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
    if ($content -match 'ONEC_NO_AUTH') {
        Write-Host "Уже пропатчено: $($file.FullName)"
        continue
    }
    if ($content -notmatch [regex]::Escape($needle)) {
        Write-Warning "Неизвестная версия client.js: $($file.FullName)"
        continue
    }
    $content = $content.Replace($needle, $replacement)
    $oldBlock = @'
function createOneCClient() {
    const { login, password } = getCredentials();
    return new BaseHttpClient({
        baseUrl: getBaseUrl(),
        timeout: 15_000,
        maxRetries: 3,
        auth: new BasicAuthStrategy(login, password),
        logger,
        headers: { Accept: "application/json" },
    });
}
'@
    $newBlock = @'
function isNoAuthMode() {
    const flag = process.env["ONEC_NO_AUTH"] ?? process.env["1C_NO_AUTH"];
    return flag === "1" || flag === "true";
}
function createOneCClient() {
    const auth = isNoAuthMode()
        ? new NoAuthStrategy()
        : new BasicAuthStrategy(...Object.values(getCredentials()));
    return new BaseHttpClient({
        baseUrl: getBaseUrl(),
        timeout: 15_000,
        maxRetries: 3,
        auth,
        logger,
        headers: { Accept: "application/json" },
    });
}
'@
    $content = $content.Replace($oldBlock, $newBlock)
    Set-Content -LiteralPath $file.FullName -Value $content -Encoding UTF8 -NoNewline
    Write-Host "Патч применён: $($file.FullName)"
}

Write-Host 'В mcp.json для 1c-rest-mcp задайте ONEC_NO_AUTH=1 и переподключите сервер в Cursor.'
