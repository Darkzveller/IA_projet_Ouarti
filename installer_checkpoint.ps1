param(
    [string]$AssettoPath = 'C:\Program Files\Assetto-Corsa-SteamRIP.com\Assetto Corsa'
)
$ErrorActionPreference = 'Stop'
$source = Join-Path $PSScriptRoot 'AssettoCorsa_CSP_app\apps\lua\OUARTICheckpoint'
$luaRoot = Join-Path $AssettoPath 'apps\lua'
$dest = Join-Path $luaRoot 'OUARTICheckpoint'
if (-not (Test-Path (Join-Path $AssettoPath 'acs.exe'))) {
    throw "Le chemin donne n'est pas une installation Assetto Corsa avec acs.exe : $AssettoPath"
}
if (-not (Test-Path (Join-Path $source 'OUARTICheckpoint.lua'))) {
    throw "Source Lua introuvable : $source"
}
if (-not (Test-Path $luaRoot)) {
    throw "Dossier CSP Lua introuvable : $luaRoot. Verifier l'installation de CSP."
}
if (Get-Process acs -ErrorAction SilentlyContinue) {
    throw "Fermer Assetto Corsa avant l'installation de l'application."
}
New-Item -Path $dest -ItemType Directory -Force | Out-Null
Copy-Item -Path (Join-Path $source 'manifest.ini') -Destination $dest -Force
Copy-Item -Path (Join-Path $source 'OUARTICheckpoint.lua') -Destination $dest -Force
Write-Host "Application OUARTICheckpoint copiee dans : $dest"
Write-Host 'Activer l application CSP dans Content Manager, puis verifier le checkpoint dans le notebook.'
