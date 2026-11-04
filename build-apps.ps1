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
    # CanvasKit (le moteur de rendu, ~6 Mo) est partagé entre les 3 apps : téléchargé une fois, mis en cache.
    $ck = "$BasePath" + "apps/canvaskit/"
    flutter build web --release --base-href $href --pwa-strategy none --dart-define=FLUTTER_WEB_CANVASKIT_URL=$ck
    if (Test-Path $out) { Remove-Item -Recurse -Force $out }
    New-Item -ItemType Directory -Force -Path (Split-Path $out) | Out-Null
    Copy-Item -Recurse (Join-Path $src "build\web") $out
    $shared = Join-Path $root "apps\canvaskit"
    if (-not (Test-Path $shared)) { Copy-Item -Recurse (Join-Path $out "canvaskit") $shared }
    Remove-Item -Recurse -Force (Join-Path $out "canvaskit")
    # Fichiers inutiles en production (symboles de debug, variantes wasm non utilisees).
    Get-ChildItem $shared -Recurse -Include *.symbols,skwasm* | Remove-Item -Force -ErrorAction SilentlyContinue
    Remove-Item (Join-Path $out ".last_build_id") -Force -ErrorAction SilentlyContinue
    # Le chargeur Flutter va chercher CanvasKit sur le CDN Google par defaut : on le pointe vers le dossier partage.
    $boot = Join-Path $out "flutter_bootstrap.js"
    (Get-Content $boot -Raw) -replace '_flutter\.loader\.load\(\);', ('_flutter.loader.load({config: {canvasKitBaseUrl: "' + $ck + '"}});') | Set-Content $boot -NoNewline -Encoding UTF8
    # Titre et description de la page (flutter create met "A new Flutter project.").
    $titles = @{ fidelite = "Demo : carte de fidelite | Pluriface"; voyageurs = "Demo : information voyageurs | Pluriface"; rendezvous = "Demo : prise de rendez-vous | Pluriface" }
    $idx = Join-Path $out "index.html"
    (Get-Content $idx -Raw) -replace "<title>$app</title>", "<title>$($titles[$app])</title>" -replace 'content="A new Flutter project."', 'content="Demonstration Flutter web par Pluriface. Donnees fictives."' | Set-Content $idx -NoNewline -Encoding UTF8
    Write-Host "OK -> apps\$app (base-href $href, canvaskit partage)" -ForegroundColor Green
  } finally {
    Pop-Location
  }
}

Write-Host "`nTermine. Ouvrez solutions/applications-mobiles.html pour vérifier, puis commit + push." -ForegroundColor Green
