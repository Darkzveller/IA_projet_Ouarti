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
- [Synchronisation Git sous Windows](#synchronisation-git-sous-windows)
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


## Synchronisation Git sous Windows

Deux scripts `.bat` sont fournis pour simplifier la synchronisation du projet
avec le dépôt Git distant :

- `git_pull.bat` : récupère la version distante du projet ;
- `git_push.bat` : enregistre les modifications locales puis les envoie sur le dépôt.

Ils doivent être lancés depuis le dossier du projet Git, ou conservés à la
racine du dépôt.

### `git_pull.bat` — récupérer la version distante

Contenu du script :

```bat
@echo off

git fetch origin
git reset --hard origin/main
git pull
```

Son fonctionnement est le suivant :

1. `git fetch origin` contacte le dépôt distant nommé `origin` et récupère les
   dernières informations disponibles sans encore modifier les fichiers locaux.
2. `git reset --hard origin/main` force ensuite le dossier local à devenir
   exactement identique à la branche distante `origin/main`.
3. `git pull` vérifie enfin s'il reste des changements distants à récupérer.

En pratique, ce script sert donc à **remettre rapidement la machine sur la
dernière version disponible de la branche `main`**.

> **Attention :** `git reset --hard origin/main` supprime les modifications locales
> non enregistrées dans un commit. Il faut donc éviter d'utiliser `git_pull.bat`
> si vous avez du travail local que vous souhaitez conserver.

Workflow conseillé avant de lancer le script :

```text
Ai-je des modifications ou des commits locaux à conserver ?
                │
          ┌─────┴─────┐
          │           │
         NON         OUI
          │           │
  git_pull.bat     NE PAS lancer
                   git_pull.bat
                       │
                       ▼
              pousser les commits
              sur le dépôt distant
              ou créer une sauvegarde
              dans une autre branche
```

> **Important : un `git commit` local ne suffit pas.**
> Tant que ce commit n'est pas présent sur `origin/main` (ou sauvegardé ailleurs),
> `git reset --hard origin/main` peut le supprimer de la branche courante.

Pour simplement vérifier l'état du projet avant de récupérer la version distante :

```powershell
git status
```

Pour vérifier s'il existe des commits locaux qui ne sont pas encore sur le dépôt distant :

```powershell
git log origin/main..HEAD --oneline
```

Si cette commande affiche un ou plusieurs commits, **ne lancez pas `git_pull.bat`**
tant que ces commits n'ont pas été poussés ou sauvegardés ailleurs.

---

### `git_push.bat` — envoyer ses modifications

Contenu actuel :

```bat
echo off
git status && git add . && git commit -m "ajout sommaire + explication makefile pyhton" && git push
```

Les commandes sont reliées avec `&&`.

Cela signifie que la commande suivante n'est exécutée que si la précédente
s'est terminée correctement.

Le script effectue donc :

1. `git status` : affiche les fichiers modifiés, ajoutés ou supprimés ;
2. `git add .` : ajoute toutes les modifications du projet à la zone de préparation ;
3. `git commit -m "..."` : crée un commit Git ;
4. `git push` : envoie ce commit sur le dépôt distant.

Le fonctionnement peut être résumé ainsi :

```text
Fichiers modifiés
      │
      ▼
 git status
      │
      ▼
  git add .
      │
      ▼
 git commit
      │
      ▼
   git push
      │
      ▼
    GitHub
```

> Le message de commit est actuellement écrit directement dans le script :
> `ajout sommaire + explication makefile pyhton`.
> Toutes les exécutions de ce `.bat` utiliseront donc ce même message tant que
> le fichier n'est pas modifié.

> `git add .` sélectionne **toutes** les modifications du dossier Git. Il est
> recommandé de vérifier `git status` avant l'envoi afin de ne pas publier
> accidentellement un fichier temporaire, un environnement Python, un fichier
> contenant un secret ou un fichier qui devrait être ignoré par `.gitignore`.

---

### Ordre d'utilisation conseillé

Lorsque plusieurs machines travaillent sur le même projet, le principe est :

```text
1. Récupérer les dernières modifications
              │
              ▼
        git_pull.bat
              │
              ▼
2. Modifier / coder / tester
              │
              ▼
3. Vérifier les changements
              │
              ▼
          git status
              │
              ▼
4. Envoyer son travail
              │
              ▼
        git_push.bat
```

Cela permet de partir de la version la plus récente avant de commencer à
travailler et de partager ensuite les modifications avec les autres machines.

> Ce workflow suppose que `git_pull.bat` est lancé **avant de commencer à travailler**.
> Si des modifications ou des commits locaux existent déjà, il faut d'abord les
> sauvegarder correctement sur le dépôt distant ou dans une autre branche.

### Résumé des deux scripts

| Script | Rôle | Commandes principales | Attention |
|---|---|---|---|
| `git_pull.bat` | Remettre le projet local exactement sur la dernière version distante de `main` | `fetch`, `reset --hard`, `pull` | Peut supprimer les modifications non commitée **et les commits locaux non poussés** |
| `git_push.bat` | Envoyer les modifications locales vers le dépôt | `status`, `add`, `commit`, `push` | Ajoute tous les fichiers et utilise un message de commit fixe |

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
