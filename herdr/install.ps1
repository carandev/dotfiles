# Installs the Herdr config, scripts and plugin settings on Windows.
$ErrorActionPreference = 'Stop'

$src = $PSScriptRoot
$herdrDir = Join-Path $env:APPDATA 'herdr'
$scriptsDir = Join-Path $herdrDir 'scripts'

foreach ($cmd in 'herdr', 'node', 'git', 'nvim') {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) { Write-Warning "'$cmd' is not on PATH" }
}

New-Item -ItemType Directory -Force -Path $scriptsDir | Out-Null
Copy-Item (Join-Path $src 'scripts\open-user-secrets.mjs') $scriptsDir -Force

$config = Join-Path $herdrDir 'config.toml'
if (Test-Path $config) {
    Copy-Item $config "$config.$(Get-Date -Format yyyyMMddHHmmss).bak"
}
# Forward slashes keep the path valid inside a TOML literal string and for cmd.exe.
$template = Get-Content (Join-Path $src 'config.toml') -Raw
$rendered = $template.Replace('@SCRIPTS_DIR@', ($scriptsDir -replace '\\', '/'))
[IO.File]::WriteAllText($config, $rendered, (New-Object Text.UTF8Encoding $false))

if (-not ((herdr plugin list 2>$null) -match '^- repo-worktrees ')) {
    herdr plugin install --yes carandev/herdr-repo-worktrees
    if ($LASTEXITCODE -ne 0) { throw 'herdr plugin install failed' }
}
$pluginConfigDir = (herdr plugin config-dir repo-worktrees).Trim()
New-Item -ItemType Directory -Force -Path $pluginConfigDir | Out-Null
Copy-Item (Join-Path $src 'plugins\repo-worktrees\config.json') $pluginConfigDir -Force

herdr config check
if ($LASTEXITCODE -ne 0) { throw 'herdr config check failed' }
herdr server reload-config *> $null
if ($LASTEXITCODE -ne 0) { Write-Host 'Herdr server not running; the config applies on next start.' }
Write-Host "Herdr config installed in $herdrDir"
