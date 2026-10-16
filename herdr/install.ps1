# Installs the Herdr config, plugins and plugin settings on Windows.
$ErrorActionPreference = 'Stop'

$src = $PSScriptRoot
$herdrDir = Join-Path $env:APPDATA 'herdr'

foreach ($cmd in 'herdr', 'node', 'git', 'nvim') {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) { Write-Warning "'$cmd' is not on PATH" }
}

New-Item -ItemType Directory -Force -Path $herdrDir | Out-Null
$config = Join-Path $herdrDir 'config.toml'
if (Test-Path $config) {
    Copy-Item $config "$config.$(Get-Date -Format yyyyMMddHHmmss).bak"
}
Copy-Item (Join-Path $src 'config.toml') $config -Force

$plugins = [ordered]@{
    'repo-worktrees' = 'carandev/herdr-repo-worktrees'
    'user-secrets'   = 'carandev/herdr-user-secrets'
}
$installed = herdr plugin list
foreach ($id in $plugins.Keys) {
    if (-not ($installed -match "^- $id ")) {
        herdr plugin install --yes $plugins[$id]
        if ($LASTEXITCODE -ne 0) { throw "herdr plugin install failed for $id" }
    }
}

$pluginConfigDir = (herdr plugin config-dir repo-worktrees).Trim()
New-Item -ItemType Directory -Force -Path $pluginConfigDir | Out-Null
Copy-Item (Join-Path $src 'plugins\repo-worktrees\config.json') $pluginConfigDir -Force

herdr config check
if ($LASTEXITCODE -ne 0) { throw 'herdr config check failed' }
herdr server reload-config *> $null
if ($LASTEXITCODE -ne 0) { Write-Host 'Herdr server not running; the config applies on next start.' }
Write-Host "Herdr config installed in $herdrDir"
