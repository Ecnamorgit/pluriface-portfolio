# Fabrique les images de partage 1200 x 630 (Open Graph / Twitter).
# Couleurs du logo : marine #0F2A4F, turquoise #12B1A0. Le turquoise sur le marine
# donne 6,4:1 de contraste ; sur du blanc il serait illisible, d'ou le fond sombre.
import io, os, sys
from PIL import Image, ImageDraw, ImageFont

# La racine du depot, deduite de l'emplacement du script : il reste lancable
# depuis n'importe quel dossier, et sur n'importe quelle machine.
RACINE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SORTIE = os.path.join(RACINE, "assets")

MARINE = (15, 42, 79)
TURQUOISE = (18, 177, 160)
BLANC = (255, 255, 255)
GRIS = (178, 192, 210)

def police(fichier, taille):
    for d in (r"C:\Windows\Fonts",):
        p = os.path.join(d, fichier)
        if os.path.exists(p):
            return ImageFont.truetype(p, taille)
    raise SystemExit("police introuvable : " + fichier)

GRAS = lambda t: police("segoeuib.ttf", t)
NORMAL = lambda t: police("segoeui.ttf", t)

def couper(draw, texte, font, largeur):
    mots, lignes, courante = texte.split(), [], ""
    for m in mots:
        essai = (courante + " " + m).strip()
        if draw.textlength(essai, font=font) <= largeur:
            courante = essai
        else:
            if courante:
                lignes.append(courante)
            courante = m
    if courante:
        lignes.append(courante)
    return lignes

def carte(titre, surtitre, nom):
    img = Image.new("RGB", (1200, 630), MARINE)
    d = ImageDraw.Draw(img)

    # Bande turquoise a gauche : le seul element graphique, repris du site.
    d.rectangle([0, 0, 18, 630], fill=TURQUOISE)

    # Logo en haut a droite. Le PNG n'est pas detoure : son fond passe du blanc au
    # transparent, et pose tel quel sur le marine il laisse un rectangle sale. On le
    # pose donc dans une pastille blanche assumee, qui absorbe le degrade.
    try:
        pastille = 132
        px, py = 1200 - 88 - pastille, 72
        d.rectangle([px, py, px + pastille, py + pastille], fill=BLANC)
        logo = Image.open(os.path.join(SORTIE, "logo_pluriface.png")).convert("RGBA")
        logo.thumbnail((96, 96), Image.LANCZOS)
        fond = Image.new("RGB", logo.size, BLANC)
        fond.paste(logo, (0, 0), logo)
        img.paste(fond, (px + (pastille - logo.width) // 2,
                         py + (pastille - logo.height) // 2))
    except Exception as e:
        print("logo non pose :", e)

    f_sur = NORMAL(26)
    d.text((88, 84), surtitre.upper(), font=f_sur, fill=TURQUOISE)

    # Le titre descend d'un cran de taille tant qu'il depasse trois lignes.
    for taille in (72, 64, 58, 52):
        f = GRAS(taille)
        lignes = couper(d, titre, f, 900)
        if len(lignes) <= 3:
            break
    y = 196
    for ligne in lignes:
        d.text((88, y), ligne, font=f, fill=BLANC)
        y += int(taille * 1.16)

    d.line([(88, 520), (248, 520)], fill=TURQUOISE, width=4)
    d.text((88, 546), "Pluriface · studio digital · Montceau-les-Mines",
           font=NORMAL(28), fill=GRIS)

    chemin = os.path.join(SORTIE, nom)
    img.save(chemin, "PNG", optimize=True)
    print(nom, os.path.getsize(chemin) // 1024, "Ko")

carte("Des outils numériques qui marchent, et qu'on fait vivre après la livraison.",
      "Sites · applications · formation · IA", "og-accueil.png")
carte("Une plateforme de formation et de suivi, à vos couleurs.",
      "Solution clés en main", "og-formation.png")
carte("Répondre aux commentaires sans y passer vos soirées.",
      "Assistant réseaux sociaux", "og-assistant.png")
carte("Une seule application pour Android, iPhone et le web.",
      "Applications mobiles", "og-mobiles.png")
carte("Transcrire des vidéos et traduire des documents, automatiquement.",
      "Étude de cas", "og-traduction.png")
