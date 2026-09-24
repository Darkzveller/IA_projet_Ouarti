# Pack d'installation — Projet IA F1

Le projet entraîne une IA à trouver la trajectoire la plus rapide sur un
circuit, dans le simulateur Assetto Corsa.

**PC gaming** → font tourner le jeu et l'entraînement de l'IA.
**PC bureautique** → servent à coder et rédiger. Pas besoin du jeu.

Les 4 machines finissent avec le même environnement Python (conda
`p309`), pour que le code circule sans rien changer.

---

## Étape 0 — Récupérer le dossier

**Si vous n'avez pas encore Git** (cas le plus courant au démarrage) :
sur la page GitHub du dépôt, bouton vert **Code** → **Download ZIP**.
Décompressez le zip où vous voulez.

> Sous Windows, décompressez vraiment le dossier (clic droit >
> *Extraire tout*). Lancer le `.bat` directement depuis l'aperçu du
> zip ne marche pas.

**Si vous avez déjà Git** :
```
git clone <lien-du-dépôt>
```

Dans les deux cas vous obtenez le dossier complet. Chacun n'utilise
ensuite que les fichiers de sa machine (voir tableau ci-dessous), les
autres ne gênent pas.

> Git sera installé automatiquement par le script à l'étape 1. Une fois
> qu'il sera là, vous pourrez utiliser `git clone` pour les mises à jour
> suivantes.

## Étape 1 — Lancer le script de sa machine

| Machine | Fichiers concernés | Quoi faire |
|---|---|---|
| PC bureautique (Windows) | `LANCER-bureau.bat` + `install-bureau-windows.ps1` | double-clic sur le `.bat` |
| PC gaming (Windows) | `LANCER-gamer.bat` + `install-gamer-windows.ps1` | double-clic sur le `.bat` |
| PC gaming (Linux) | `install-gamer-linux.sh` | `chmod +x install-gamer-linux.sh && ./install-gamer-linux.sh` |

> Le `.bat` et le `.ps1` doivent rester **dans le même dossier** :
> le `.bat` appelle le `.ps1`.
>
> Ne lancez pas le `.ps1` par clic droit, Windows le bloque.
> Passez toujours par le `.bat`.

## Étape 2 — Patienter

Bureautique : 10 à 20 min. Gaming : 30 à 45 min.

**Ne fermez pas la fenêtre.** Certaines étapes n'affichent rien pendant
plusieurs minutes, c'est normal. C'est fini quand `=== Termine ===`
apparaît.

Si le script demande de rouvrir le terminal après avoir installé
Miniconda : fermez, rouvrez, relancez le même `.bat`.

## Étape 3 — (gaming) Installer le jeu

Assetto Corsa sur Steam, avec votre propre compte.

> **PAS** Assetto Corsa *Competizione*, **PAS** *EVO*.
> Ce sont des jeux différents, l'interface ne marche pas avec eux.

## Étape 4 — (gaming) Content Manager + patch CSP

Installer Content Manager, puis le patch **CSP version 0.2.1** via
*Settings > Custom Shaders Patch*.

Les autres versions posent problème. Si l'erreur `INIReader::cache`
apparaît, passer en 0.2.7.

## Étape 5 — (gaming) Installer le plugin

Suivre `assetto_corsa_gym/INSTALL.md`, dans le dossier téléchargé par
le script.

## Étape 6 — (gaming) Pilotes GPU

Les mettre à jour : app NVIDIA, ou AMD Adrenalin.

## Étape 7 — (gaming Linux uniquement)

Proton **GE-Proton9-2** via ProtonUp-Qt, lien symbolique du dossier
config Steam, copie des fichiers `windows-libs`.
Tout est détaillé dans `INSTALL_Linux.md`.

## Étape 8 — Régler le jeu

Résolution la plus basse, graphismes au minimum, **pas de plein écran**,
et fermer les autres applications.

## Étape 9 — Vérifier que ça marche

Lancer les deux notebooks du dépôt :
- `test_client.ipynb` (communication avec le jeu)
- `test_gym.ipynb` (interface Gym)

**Tant qu'ils ne tournent pas, inutile d'aller plus loin.**

---

## Point de vigilance

PyTorch 1.12.1 / CUDA 11.6 datent de 2022 et peuvent refuser de
fonctionner sur une carte graphique récente. À tester en premier.

Dépôt : https://github.com/dasGringuen/assetto_corsa_gym
