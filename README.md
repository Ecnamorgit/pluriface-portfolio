# Pluriface — site du studio

Site statique, sans dépendance ni étape de construction : on ouvre un fichier `.html`,
on l'édite, on pousse. GitHub Pages sert la branche `main` telle quelle.

En ligne : <https://ecnamorgit.github.io/pluriface-portfolio/>

| Fichier | Rôle |
|---|---|
| `index.html` | l'accueil |
| `solutions/*.html` | une page par produit, avec les démonstrations Flutter |
| `projet-traduction-ia.html` | l'étude de cas (utilise `style.css` et `app.js`, pas la feuille commune) |
| `mentions-legales.html` | mentions et confidentialité, en `noindex` |
| `agence.css` | la feuille commune aux quatre premières pages |
| `site.js` | menu mobile, apparition au défilement, décodage des coordonnées |
| `apps/` | les démonstrations compilées, servies dans des iframes |
| `flutter-apps/` | le code source de ces démonstrations |

## Le cache : toujours monter la version

`agence.css` et `site.js` sont servis avec `?v=N`. **Si vous modifiez l'un des deux,
montez le numéro dans toutes les pages qui le chargent**, sinon un visiteur déjà venu
reçoit le nouveau HTML avec l'ancienne feuille.

```bash
grep -rn "agence.css?v=" --include=*.html .
```

## Référencement : ce qui est en place

- `robots.txt` et `sitemap.xml` à la racine du projet
- une balise `<link rel="canonical">` sur chaque page
- Open Graph et carte Twitter complets, avec des images 1200 × 630 dédiées
  (`assets/og-*.png`)
- des données structurées JSON-LD : `ProfessionalService` + `WebSite` sur l'accueil,
  `Service` + `BreadcrumbList` sur chaque page solution, `Article` sur l'étude de cas

Les images de partage se refabriquent avec `python tools/og_images.py` (nécessite
Pillow) : fond marine, bande turquoise, titre, pastille du logo. Elles ne contiennent
aucune donnée datée, donc inutile de les régénérer à chaque modification du site —
seulement quand un titre de page change.

### Deux limites de l'hébergement actuel

1. **`robots.txt` n'est pas lu.** Seul `https://ecnamorgit.github.io/robots.txt` fait
   autorité pour l'hôte, et ce fichier appartient à GitHub, pas à nous. Celui du projet
   deviendra le bon le jour où le site aura son propre nom de domaine.
2. **Le plan du site doit être déclaré à la main** dans la Search Console, sur une
   propriété « préfixe d'URL » (`https://ecnamorgit.github.io/pluriface-portfolio/`).
   Une propriété de domaine est impossible tant qu'on est sur un sous-dossier d'un
   hôte partagé.

## Le jour où le nom de domaine arrive

L'adresse du site n'est écrite qu'à un seul endroit par fichier. Un chercher-remplacer
de `https://ecnamorgit.github.io/pluriface-portfolio/` par la nouvelle adresse suffit :

```bash
grep -rln "ecnamorgit.github.io/pluriface-portfolio" --include=*.html --include=*.xml --include=*.txt .
```

Ensuite, dans l'ordre :

1. poser un fichier `CNAME` à la racine (ou configurer le reverse proxy du NAS)
2. vérifier que `https://` répond, et que `http://` y redirige
3. créer une propriété **de domaine** dans la Search Console et y déclarer le sitemap
4. faire une demande de changement d'adresse depuis l'ancienne propriété
5. remplacer l'adresse Gmail du site par une adresse sur le domaine
6. régler la fiche Google Business Profile : c'est elle qui fait le gros du
   référencement local, et le bloc `ProfessionalService` de l'accueil est là pour s'y
   rattacher. Si une fiche existe déjà et porte la mention « définitivement fermé »,
   elle ne se remplace pas par une nouvelle : il faut la revendiquer, puis la rouvrir
   ou la déclarer déménagée. Deux fiches sur la même adresse se neutralisent.

## Les choix de forme, et pourquoi ils ne sont pas des oublis

Trois réglages ont l'air d'erreurs quand on les croise dans la feuille de style. Ils
sont volontaires, et les défaire ramène le site au gabarit dont il sort :

| Ce qu'on voit | Pourquoi |
|---|---|
| `--paper` n'est pas blanc (`#fbf9f6`) | fond blanc + cartes blanches + barre blanche : plus rien ne se détachait. Les cartes, elles, sont restées en blanc franc |
| Les boutons ont un bord et une ombre **sans flou** | une pilule de couleur plate qui monte de 2 px au survol, c'est le bouton de tous les gabarits. Ici il s'enfonce dans son ombre au clic |
| Le bouton turquoise est en texte **marine**, pas blanc | le blanc sur `#12b1a0` ne donne que 2,68:1. Le marine donne 5,34:1 |
| La barre du haut est en `--sand`, pas en `--paper` | une barre de la couleur de la page n'est pas une barre, c'est le haut de la page avec un trait dessous |
| Elle n'a **pas** de `backdrop-filter` | le flou ne se voyait pas derrière un fond opaque à 94 %, mais il créait un contexte de composition : le `mix-blend-mode` du logo se mélangeait au fond de la barre au lieu de la page, et la marque se délavait au défilement |
| `.topbar .nav .btn` a un `margin-right: 3px` | son ombre pleine part de 3 px vers la droite. Sans ce décalage, la masse du bouton dépassait de la colonne sur laquelle toute la page est alignée |
| Le logo de la barre est `logo_pluriface_marque.png` | le fichier d'origine fait 256 × 167 px mais l'encre s'arrête à 120 × 145 : plus de la moitié est du blanc, qui s'ajoutait à l'espacement CSS. `logo_pluriface.png` reste utilisé par `projet-traduction-ia.html`, qui a sa propre feuille de style |

Même logique pour le vocabulaire : « Flutter » ne reste que là où il est expliqué
(la section « Pourquoi Flutter » et le corps de la page mobile). Le titre, la
description et le badge parlent d'« application mobile » : la cible est un commerçant
ou une collectivité, pas un développeur.

## Le formulaire de contact

Le point d'envoi est la constante `POINT_ENVOI`, en haut du bloc formulaire de
`site.js`. **C'est le seul endroit à renseigner** : l'adresse d'un service de
formulaire, ou celle du script d'envoi du NAS.

| `POINT_ENVOI` | Ce qui se passe au clic |
|---|---|
| vide | le message est préparé pour l'e-mail, **et** affiché prêt à copier |
| renseignée | envoi en arrière-plan, message de confirmation, champs vidés |
| renseignée, mais l'envoi échoue | « L'envoi n'a pas abouti », message conservé et prêt à copier |

Dans tous les cas le visiteur voit quelque chose. C'est le point qui manquait : sur un
téléphone sans application de courrier configurée, `mailto:` n'ouvre rien, et le
bouton restait sans effet visible.

## Ce qui reste

- **L'e-mail reste écrit à l'envers** dans `data-m`, remis à l'endroit par `site.js` :
  c'est l'adresse que cherchent les aspirateurs. Le téléphone, lui, est en clair et
  déclaré dans les données structurées. Il changera avec le nom de domaine, moment où
  l'on pourra le mettre en clair aussi sans y perdre.
- **`flutter-apps/` contient les dossiers `build/` et `.dart_tool/`**, soit environ
  170 Mo versionnés qui n'ont pas à l'être, en double avec `apps/`.
