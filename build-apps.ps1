# Pluriface — compile les 3 mini-apps Flutter en version web et les place dans apps/.
# Usage (PowerShell, à la racine du portfolio) :
#   .\build-apps.ps1                                  # site servi sous /pluriface-portfolio/ (GitHub Pages)
#   .\build-apps.ps1 -BasePath "/"                    # site servi à la racine d'un domaine
# Prérequis : Flutter installé et dans le PATH (flutter doctor).

param(
  [string]$BasePath = "/pluriface-portfolio/"
)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$apps = @("fidelite", "voyageurs", "rendezvous")

foreach ($app in $apps) {
  $src = Join-Path $root "flutter-apps\$app"
  $out = Join-Path $root "apps\$app"
  Write-Host "`n=== $app ===" -ForegroundColor Cyan
  Push-Location $src
  try {
    # Ajoute les fichiers web/ manquants sans toucher à lib/main.dart ni pubspec.yaml.
    flutter create --platforms web --project-name $app . | Out-Null
    flutter pub get
    $href = "$BasePath" + "apps/$app/"
    flutter build web --release --base-href $href --pwa-strategy none
    if (Test-Path $out) { Remove-Item -Recurse -Force $out }
    New-Item -ItemType Directory -Force -Path (Split-Path $out) | Out-Null
    Copy-Item -Recurse (Join-Path $src "build\web") $out
    Write-Host "OK -> apps\$app (base-href $href)" -ForegroundColor Green
  } finally {
    Pop-Location
  }
}

Write-Host "`nTerminé. Ouvrez solutions/applications-mobiles.html pour vérifier, puis commit + push." -ForegroundColor Green
