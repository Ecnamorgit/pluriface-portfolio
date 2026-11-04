# Mini-apps Flutter de démonstration

Trois applications Flutter volontairement petites (un seul `lib/main.dart` chacune, aucune dépendance externe),
affichées dans des cadres de téléphone sur `solutions/applications-mobiles.html`.

| Dossier | Démo | Couleur de marque |
|---|---|---|
| `fidelite/` | Carte de fidélité pour commerçant | ambre `#D97706` |
| `voyageurs/` | Information voyageurs (réseau de bus) | turquoise `#14B3A3` |
| `rendezvous/` | Prise de rendez-vous | violet `#7C3AED` |

## Compiler pour le site

Depuis la racine du portfolio, sous PowerShell :

```powershell
.\build-apps.ps1                 # site servi sous /pluriface-portfolio/ (GitHub Pages)
.\build-apps.ps1 -BasePath "/"   # site servi à la racine d'un domaine
```

Le script ajoute les fichiers `web/` manquants (`flutter create --platforms web .`), compile en release et copie
`build/web` dans `apps/<nom>/`. Tant que la compilation n'a pas été faite, `apps/<nom>/index.html` contient un
aperçu statique provisoire.

## Lancer une démo en local

```powershell
cd flutter-apps\fidelite
flutter create --platforms web .
flutter run -d chrome
```
