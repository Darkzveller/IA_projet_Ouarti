# Pack d'installation — Projet IA F1

Le projet entraîne une IA à trouver la trajectoire la plus rapide sur un
circuit, dans le simulateur Assetto Corsa.

**PC gaming** → font tourner le jeu et l'entraînement de l'IA.  
**PC bureautique** → servent à coder et rédiger. Pas besoin du jeu.

Les 4 machines finissent avec le même environnement Python (conda
`p309`), pour que le code circule sans rien changer.

---

## Sommaire

- [Présentation](#présentation)
- [Étape 0 — Récupérer le dossier](#étape-0--récupérer-le-dossier)
- [Étape 1 — Lancer le script de sa machine](#étape-1--lancer-le-script-de-sa-machine)
- [Étape 2 — Patienter](#étape-2--patienter)
- [Étape 3 — Installer le jeu (gaming)](#étape-3--gaming-installer-le-jeu)
- [Étape 4 — Content Manager + patch CSP](#étape-4--gaming-content-manager--patch-csp)
- [Étape 5 — Installer le plugin](#étape-5--gaming-installer-le-plugin)
- [Étape 6 — Pilotes GPU](#étape-6--gaming-pilotes-gpu)
- [Étape 7 — Configuration Linux](#étape-7--gaming-linux-uniquement)
- [Étape 8 — Régler le jeu](#étape-8--régler-le-jeu)
- [Étape 9 — Vérifier que ça marche](#étape-9--vérifier-que-ça-marche)
- [Référence Makefile Python](#référence-makefile-python)
- [Point de vigilance](#point-de-vigilance)

---

## Présentation
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

## Référence Makefile Python

Pour les projets Python qui utilisent un **Makefile** afin de gérer automatiquement
leur environnement virtuel, la documentation complète est disponible ici :

**https://github.com/Darkzveller/Projet_python_makefile_example**

Le principe est simple : le Makefile centralise les commandes courantes du projet
et utilise directement le Python de l'environnement virtuel.

Commandes principales :

```powershell
make setup PY=3.10   # crée le venv et installe les dépendances
make run             # lance le programme avec le Python du venv
make shell           # ouvre un PowerShell avec le venv activé
make clean           # supprime le venv sélectionné
make info            # affiche la configuration utilisée
```

Arborescence minimale attendue :

```text
mon_projet/
├── Makefile
├── requirements.txt
└── src/
    └── main.py
```

`make setup PY=3.10` mémorise la version choisie dans le projet. Les commandes
suivantes peuvent donc réutiliser automatiquement cette version sans devoir
réécrire `PY=3.10`.

> Cette section est une référence complémentaire. Le présent projet IA F1 utilise
> l'environnement Conda `p309` décrit plus haut.

---

## Point de vigilance

PyTorch 1.12.1 / CUDA 11.6 datent de 2022 et peuvent refuser de
fonctionner sur une carte graphique récente. À tester en premier.

Dépôt : https://github.com/dasGringuen/assetto_corsa_gym
