param([Parameter(Mandatory=$true)][string]$AddOnsPath)
$ErrorActionPreference = 'Stop'
if (!(Test-Path -LiteralPath $AddOnsPath -PathType Container)) { throw 'Indique le dossier AddOns existant du client Forever.' }
$source = Join-Path (Split-Path -Parent $PSScriptRoot) 'ForeverRusse'
$target = Join-Path $AddOnsPath 'ForeverRusse'
# Copy only our addon. No deletion of files, other addons or SavedVariables.
New-Item -ItemType Directory -Force -Path $target | Out-Null
Copy-Item -Path (Join-Path $source '*') -Destination $target -Recurse -Force
Write-Host "Installé dans $target. /reload en jeu."
