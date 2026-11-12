# Pack d'installation — Projet IA F1

Le projet entraîne une IA à trouver la trajectoire la plus rapide sur un
circuit, dans le simulateur Assetto Corsa.

**PC gaming** → font tourner le jeu et l'entraînement de l'IA.
**PC bureautique** → servent à coder et rédiger. Pas besoin du jeu.

Les 4 machines finissent avec le même environnement Python (conda
`p309`), pour que le code circule sans rien changer.

> **Mise à jour du 12 novembre 2026 — configuration actuelle sur le PC testé :** le développement OUARTI se fait dans `Code/`, en notebooks Jupyter indépendants avec le **Python global 3.9.13** ; télémétrie, volant, pédales et capture caméra sont validés. Les indications historiques ci-dessous concernant Conda `p309`, le Makefile, `ouarti_stage1` et Python 3.11 restent conservées comme historique et ne remplacent pas la configuration actuelle détaillée en fin de document.

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
- [Mise à jour — dossier Code et notebooks Jupyter](#mise-à-jour--dossier-code-et-notebooks-jupyter)
- [Journal de mise en service — corrections vérifiées](#journal-de-mise-en-service--corrections-vérifiées)

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

| Machine                  | Fichiers concernés                                    | Quoi faire                                                      |
| ------------------------ | ------------------------------------------------------ | --------------------------------------------------------------- |
| PC bureautique (Windows) | `LANCER-bureau.bat` + `install-bureau-windows.ps1` | double-clic sur le `.bat`                                     |
| PC gaming (Windows)      | `LANCER-gamer.bat` + `install-gamer-windows.ps1`   | double-clic sur le `.bat`                                     |
| PC gaming (Linux)        | `install-gamer-linux.sh`                             | `chmod +x install-gamer-linux.sh && ./install-gamer-linux.sh` |

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

| Script           | Rôle                                                                             | Commandes principales                     | Attention                                                                                   |
| ---------------- | --------------------------------------------------------------------------------- | ----------------------------------------- | ------------------------------------------------------------------------------------------- |
| `git_pull.bat` | Remettre le projet local exactement sur la dernière version distante de `main` | `fetch`, `reset --hard`, `pull`     | Peut supprimer les modifications non commitée **et les commits locaux non poussés** |
| `git_push.bat` | Envoyer les modifications locales vers le dépôt                                 | `status`, `add`, `commit`, `push` | Ajoute tous les fichiers et utilise un message de commit fixe                               |

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

---

## Avancement du 9 novembre 2026 — Préparation de l'étape 1

Cette section complète le guide d'installation ci-dessus avec le travail effectué aujourd'hui. Elle distingue le code préparé, les vérifications hors jeu et les essais qui restent à effectuer sur le PC gaming.

**Aucun modèle n'est encore entraîné. Aucun entraînement ni Assetto Corsa n'a été lancé pendant le développement de cette version.** La capacité à conduire et les performances sur circuit restent à mesurer.

### 1. Récupération et examen du projet

Les fichiers de gestion, le cahier des charges, l'arborescence et le script `install-gamer-windows-venv-youssef.ps1` ont été examinés. Les premières archives contenaient les documents de gestion, mais pas les sources Python du simulateur.

Le script d'installation a permis de retrouver le dépôt utilisé : [dasGringuen/assetto_corsa_gym](https://github.com/dasGringuen/assetto_corsa_gym). Il a été récupéré directement, sans avoir à transférer tout le dossier d'installation local.

La base inspectée correspond à la révision `ef0fa502bdd257fc2affad9361c02b3dbdfe1632`. Les éventuelles modifications restées uniquement sur un PC personnel ne sont pas comprises dans cette récupération.

L'examen a porté notamment sur le client, l'environnement Gym, les fichiers de piste, les trajectoires de référence, les commandes vJoy et le plugin `sensors_par` : télémétrie, serveur ego, capture d'écran et mémoire partagée.

Deux points ont orienté les ajouts :

- L'entraînement historique utilise SAC/DisCor et Gym 0.21. L'étape 1 demandée utilise deux politiques PPO distinctes.
- Certaines observations historiques reposent sur des trajectoires de référence. La nouvelle chaîne sépare ces informations des observations de la stratégie, pour respecter l'apprentissage sans imitation de tours humains.

### 2. Infrastructure ajoutée pour les trois IA

Le travail a été livré dans `OUARTI_Etape1_source.zip`. Les nouveaux fichiers se trouvent dans **`assetto_corsa_gym/ouarti_stage1/`**, depuis la racine du projet principal. Les programmes historiques restent disponibles.

| Composant                  | Travail préparé                                                                                           |
| -------------------------- | ----------------------------------------------------------------------------------------------------------- |
| Perception — petite U-Net | Segmentation des images, classes visuelles, dataset, augmentations, entraînement, métriques et inférence |
| Pilote neuronal — PPO     | Commandes volant/accélérateur/frein, objectifs locaux et exercices progressifs                            |
| Stratégie — PPO          | Choix de quatre points locaux et d'une vitesse cible, exécutés par le pilote déjà entraîné            |
| Liaison avec le jeu        | Adaptateur des protocoles existants, contrôle des délais, synchronisation et arrêt des commandes         |
| Données et outils         | Collecte de sessions, préparation des annotations, replay, visualisation, calibration et benchmark         |
| Sauvegardes et exports     | Checkpoints, reprise, journaux et export ONNX des trois modèles                                            |
| Documentation et tests     | Configurations séparées, guides techniques et tests hors simulateur                                       |

La perception apprend avec des masques annotés. Les deux politiques de conduite apprennent par renforcement. Le pilote peut commencer avec des objectifs générés depuis les bords de piste, avant que la perception soit prête. Aucun tour de pilote humain n'est utilisé comme exemple à imiter par les politiques.

Les classes prévues couvrent notamment l'asphalte, les lignes, les vibreurs, l'herbe, le gravier, les dégagements, les voitures, les barrières et les marquages de course. Leur reconnaissance réelle dépendra des annotations et des résultats d'entraînement.

### 3. Adaptation du plugin

Quatre fichiers du plugin ont été modifiés pour cette version :

| Fichier                      | Modification                                                                                                              |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `structures.py`            | Ajout d'un horodatage de télémétrie et du dommage total, utilisé comme indicateur de collision                        |
| `dual_buffer.py`           | Ajout de métadonnées temporelles et correction de la lecture des pixels noirs en fin d'image                            |
| `screen_capture_worker.py` | Horodatage de la capture avant son écriture en mémoire partagée                                                        |
| `ego_server.py`            | Ajout d'un watchdog activé par les nouveaux clients pour freiner en cas d'absence de commandes, avec vJoy côté serveur |

Le code refuse les données trop anciennes ou incohérentes et vérifie la correspondance du circuit et de la voiture avec la configuration. Ces mécanismes ont été vérifiés hors jeu avec des données synthétiques ; leurs effets dans le simulateur doivent encore être contrôlés.

Le reset disponible dépend de CSP. Aucun changement automatique de circuit, sélection arbitraire de point de départ ou réglage automatique de météo n'est présenté comme opérationnel.

### 4. Environnement Python séparé

**Précision par rapport au début de ce README :** l'environnement commun Conda `p309` concerne l'installation historique. Le script sans Conda utilise, lui, le venv `python/py3.9`. La nouvelle étape 1 possède son propre environnement et ne doit pas être installée en mélangeant les dépendances de ces anciennes variantes.

| Élément                                    | Nouvelle étape 1                                       |
| -------------------------------------------- | ------------------------------------------------------- |
| Version Python prévue par le script Windows | Python 3.11                                             |
| Dossier de l'environnement                   | `assetto_corsa_gym/ouarti_stage1/.venv-stage1/`       |
| Bibliothèques principales                   | PyTorch 2.5.1, Gymnasium 1.0.0, Stable-Baselines3 2.4.1 |
| Script d'installation                        | `install-windows-stage1.ps1`                          |
| Calcul installé par défaut                 | Processeur, pour préparer et vérifier les interfaces  |

L'installation GPU adaptée à la carte devra être vérifiée avant les longs entraînements. Conserver l'ancien environnement Python.

Depuis la racine du projet, ouvrir PowerShell puis entrer :

```powershell
cd .\assetto_corsa_gym\ouarti_stage1
py -3.11 --version
powershell -ExecutionPolicy Bypass -File .\install-windows-stage1.ps1
```

Si Python 3.11 manque, l'installer avant de relancer. Ce script prépare les bibliothèques ; il ne démarre ni le jeu ni les entraînements. Son installation complète sur le PC gaming n'a pas été confirmée dans les échanges d'aujourd'hui.

Vérifications hors jeu à lancer après installation, depuis le même dossier :

```powershell
.\.venv-stage1\Scripts\python.exe -m ouarti.cli --help
.\.venv-stage1\Scripts\python.exe -m ouarti.cli audit --config configs/pilot.yaml
.\.venv-stage1\Scripts\python.exe -m pytest
```

L'audit contrôle les versions et la présence des fichiers de circuits ; il ne prouve pas la connexion au jeu.

### 5. Installation du plugin : point d'arrêt actuel

Le terminal a été ouvert dans le dossier `assetto_corsa_gym/ouarti_stage1`, puis cette commande a été lancée :

```powershell
powershell -ExecutionPolicy Bypass -File .\install-plugin-stage1.ps1
```

PowerShell a demandé le paramètre suivant :

```text
AssettoPath:
```

Ce paramètre est **le chemin du jeu installé par Steam**. Il désigne par exemple :

```text
C:\Program Files (x86)\Steam\steamapps\common\assettocorsa
```

Pour retrouver le chemin exact : **Steam → Bibliothèque → clic droit sur Assetto Corsa → Gérer → Parcourir les fichiers locaux**, puis copier le chemin dans la barre d'adresse de l'explorateur.

L'installation a été reportée à ce moment-là. **Le patch du plugin n'est donc pas confirmé comme installé.**

Pour reprendre plus tard, fermer le jeu, revenir dans `ouarti_stage1`, puis relancer la commande et fournir le bon chemin. Il est aussi possible de le passer directement, en adaptant cet exemple :

```powershell
powershell -ExecutionPolicy Bypass -File .\install-plugin-stage1.ps1 -AssettoPath "C:\Program Files (x86)\Steam\steamapps\common\assettocorsa"
```

Le script met à jour quatre fichiers du plugin et conserve des sauvegardes des fichiers existants. **Il demande que le plugin original soit déjà installé.** Si ce n'est pas le cas, suivre d'abord [INSTALL.md](assetto_corsa_gym/INSTALL.md).

Le projet Python reste dans le dossier de travail. Seuls les fichiers du plugin concernés sont copiés dans le dossier du jeu.

### 6. Configuration à vérifier après la copie du plugin

Dans le `config.py` du plugin réellement installé dans Assetto Corsa, les valeurs prévues pour la nouvelle chaîne sont :

```python
self.sampling_freq = 100
self.ego_sampling_freq = 25
self.vjoy_executed_by_server = True
self.screen_capture_enable = True
self.screen_capture_freq = 25
self.final_image_width = 320
self.final_image_height = 240
self.color_mode = 'bgr'
```

Ces valeurs sont des réglages demandés au plugin, pas des fréquences déjà mesurées. Le mode vJoy côté serveur exige 100 Hz dans le code inspecté.

Il faudra aussi vérifier :

- L'installation et la configuration de vJoy.
- Le chemin de l'interpréteur utilisé par le worker externe de capture, notamment `config_python_executable`.
- La boîte automatique, car les commandes actuelles ne gèrent pas le passage manuel des rapports.
- Une caméra avant fixe, avec un cadrage conservé pour la calibration et les essais.
- La correspondance circuit/voiture entre le jeu et le YAML ; les configurations livrées commencent avec Monza et `dallara_f317`.

La capture actuelle passe par une mémoire partagée locale Windows. Pour la chaîne visuelle en direct, le client Python doit donc tourner sur le même PC Windows que le jeu. Les outils hors ligne restent séparés de cette contrainte.

### 7. Vérifications déjà effectuées hors jeu

**28 tests ont passé dans l'environnement de développement Linux/Python 3.12, sur processeur.** Le script d'installation Windows prévoit Python 3.11 ; son fonctionnement sur le PC gaming reste à vérifier.

Les vérifications couvrent notamment :

- Les formats de télémétrie, observations et actions.
- Les dimensions des réseaux et des tenseurs.
- Les limites de commandes et la conversion des pédales vers le protocole du plugin.
- Les données périmées, les séquences et la synchronisation.
- Les récompenses, les sorties de piste, l'immobilisation et les sauts de position.
- La sauvegarde et le chargement des politiques.
- La chaîne stratégique → pilote → commandes avec un simulateur remplacé par des données synthétiques.
- Les exports ONNX, comparés aux sorties PyTorch sur des modèles non entraînés.

Les modules ajoutés et les quatre fichiers du plugin modifiés ont également passé la compilation Python. Les fichiers de bords des cinq circuits configurés sont présents et lisibles dans le dépôt récupéré.

**Ces contrôles ne valident ni la connexion réelle au jeu, ni la conduite, ni les chronos.** Aucun poids entraîné et aucun résultat de performance fictif ne sont livrés.

### 8. Prochains tests, dans l'ordre

| Ordre | Test à réaliser     | Ce qu'on doit vérifier                                                                       |
| ----- | --------------------- | --------------------------------------------------------------------------------------------- |
| 1     | Environnement Windows | Python 3.11, installation terminée sans erreur, aide CLI, audit et tests hors jeu            |
| 2     | Plugin                | Installation originale présente, patch copié et configuration effectivement chargée        |
| 3     | Télémétrie         | Vitesse, position, orientation et autres mesures reçues avec des horodatages cohérents      |
| 4     | Caméra               | Images BGR reçues à la résolution prévue, sans images trop anciennes ni mauvais cadrage   |
| 5     | Commandes             | Bon sens du volant, accélérateur et frein sur les bons axes, boîte automatique active      |
| 6     | Arrêts               | Freinage lors d'un arrêt volontaire ou d'une perte de commandes, sans commandes résiduelles |
| 7     | Reset                 | Retour de la voiture dans un état utilisable et départ adapté au premier exercice          |
| 8     | Acquisition           | Fréquences et délais réels, en particulier l'écart entre image et télémétrie           |
| 9     | Session courte        | Enregistrement puis visualisation hors ligne des images et mesures                            |

Les essais qui commandent la voiture sont à lancer volontairement dans une session de simulation prête. Les notebooks historiques `test_client.ipynb` et `test_gym.ipynb` concernent l'ancien client/environnement et doivent utiliser leurs dépendances compatibles. Ils ne remplacent pas les vérifications de la nouvelle chaîne.

### 9. Après la validation de la liaison au jeu

Les étapes suivantes seront :

1. **Constituer les données de perception.** Enregistrer plusieurs sessions, annoter les masques et vérifier les classes. Le plugin ne fournit pas de masques sémantiques natifs confirmés.
2. **Entraîner la U-Net.** Séparer entraînement, validation et test, puis mesurer les erreurs par classe et sur les limites de piste.
3. **Entraîner le pilote PPO.** Passer progressivement par la ligne droite, le suivi de piste, les virages, la gestion de vitesse et les tours complets. Cet apprentissage peut commencer avec la géométrie avant la fin de la perception.
4. **Calibrer la caméra et tester perception + pilote.** Relier les pixels aux mètres avec des mesures indépendantes. La calibration plane actuelle ne suffit pas à garantir des distances correctes dans les fortes pentes ou dévers.
5. **Entraîner le PPO stratégique.** Garder le pilote et la perception fixes, puis apprendre le placement et la vitesse.
6. **Comparer les résultats.** Mesurer tours terminés, erreurs, collisions détectées et chronos dans des conditions comparables.

Les circuits sont répartis ainsi :

| Usage                                            | Circuits                              |
| ------------------------------------------------ | ------------------------------------- |
| Entraînement                                    | Monza, Barcelona GP, Red Bull Ring GP |
| Validation et choix des réglages                | Imola                                 |
| Test final, gardé à part pendant les réglages | Silverstone GP                        |

La présence des CSV ne confirme pas que les circuits et la voiture sont installés dans le jeu ou que leur géométrie correspond exactement aux fichiers. Cela reste à vérifier.

Les objectifs du cahier des charges, dont moins de 10 % de dégradation sur un circuit inconnu et moins de 100 ms de latence d'affichage, ne sont pas encore mesurés. Le benchmark d'inférence seul n'inclut pas toute la capture et l'affichage du futur HUD.

### 10. Où retrouver les instructions et les sauvegardes

| Fichier ou dossier                                                       | Contenu                                                                     |
| ------------------------------------------------------------------------ | --------------------------------------------------------------------------- |
| [README de l&#39;étape 1](assetto_corsa_gym/ouarti_stage1/README.md)     | Commandes de collecte, entraînement, reprise, évaluation et visualisation |
| [INTEGRATION.md](assetto_corsa_gym/ouarti_stage1/docs/INTEGRATION.md)     | Installation/configuration du plugin, échanges et synchronisation          |
| [DONNEES.md](assetto_corsa_gym/ouarti_stage1/docs/DONNEES.md)             | Annotations, classes et calibration                                         |
| [CONTRATS.md](assetto_corsa_gym/ouarti_stage1/docs/CONTRATS.md)           | Observations, actions et récompenses                                       |
| [ETAT.md](assetto_corsa_gym/ouarti_stage1/docs/ETAT.md)                   | Fonctions préparées et limites restantes                                  |
| [VERIFICATION.txt](assetto_corsa_gym/ouarti_stage1/docs/VERIFICATION.txt) | Résultat des contrôles hors simulateur                                    |
| `assetto_corsa_gym/ouarti_stage1/configs/`                             | Configurations séparées des modèles                                      |
| `assetto_corsa_gym/ouarti_stage1/data/`                                | Données et calibration à constituer                                       |
| `assetto_corsa_gym/ouarti_stage1/outputs/`                             | Futurs modèles et journaux d'entraînement                                 |

Pour reprendre un PPO, conserver ensemble le fichier `.zip`, son `.json` et son `.rng.pt`. Pour la perception, conserver les checkpoints `.pt`. Les sauvegardes ne restaurent pas l'état physique exact de la voiture. `total_timesteps` est un total cumulatif : il faut l'augmenter lorsqu'on reprend pour ajouter de l'apprentissage.

Avant de partager les ajouts avec Git, vérifier que les nouveaux fichiers sont bien suivis et que les venv/datasets ne sont pas ajoutés inutilement. Le dépôt `assetto_corsa_gym` étant récupéré avec Git, contrôler aussi sa gestion comme éventuel dépôt imbriqué : un envoi du dépôt principal ne garantit pas à lui seul la publication de ses changements internes.

**À la prochaine reprise : terminer d'abord le patch du plugin avec le bon `AssettoPath`, puis vérifier sa configuration et la liaison au jeu. Les entraînements seront lancés après ces contrôles.**

---

## Mise à jour — dossier Code et notebooks Jupyter

**Statut : installation actuelle validée sur le PC de test (12 novembre 2026).** Cette section reprend le README du dossier `Code` fourni avec les notebooks, en corrigeant les chemins d’exemple de `OUARTI/` vers `Code/`. Le second exemplaire de ce README étant identique, il n’est pas répété.

> **Coexistence des versions :** les scripts d’installation Conda et les notes de l’ancienne étape `ouarti_stage1` dans les premières sections du README principal sont conservés pour l’historique et pour les autres machines. Pour **ce poste** et les nouveaux tests interactifs, le parcours validé est `Code/` → notebooks `.ipynb` → noyau **Python global 3.9.13**.

Le dossier contient **uniquement des notebooks `.ipynb`** pour le code du projet, sans `main.py`, sans Makefile, sans dossier `ouarti/` et sans nouvel environnement virtuel. Chaque notebook contient ses propres fonctions (y compris les fonctions réseau) et se lance individuellement. Il n'est pas nécessaire de lancer un autre notebook avant lui, sauf le notebook d'installation si des dépendances manquent.

### Installation dans ton dépôt existant

Place le dossier **`Code/`** à la racine de `IA_projet_Ouarti_ds_github`, **à côté de** `assetto_corsa_gym/` (déjà présent chez toi).

```text
IA_projet_Ouarti_ds_github/
├── assetto_corsa_gym/         (existant, NON inclus dans le ZIP)
├── Code/
│   ├── 00_Installer_Bibliotheques_Python39.ipynb
│   ├── 01_Tests/            (6 notebooks)
│   ├── 02_Donnees/          (4 notebooks)
│   ├── 03_Entrainement/     (4 notebooks)
│   ├── 04_Evaluation/       (2 notebooks)
│   ├── 05_HUD/              (1 notebook)
│   ├── datasets/
│   ├── models/
│   └── reports/
└── ...
```

### Démarrage

1. Ouvre **la racine du dépôt** dans VS Code.
2. Ouvre `Code/00_Installer_Bibliotheques_Python39.ipynb`.
3. Sélectionne **Python 3.9** comme noyau. Ce notebook vérifie l'interpréteur avant toute installation.
4. Si besoin, mets `INSTALLER_BASE=True`, puis exécute les cellules. Mets `INSTALLER_IA=True` pour PyTorch / Gymnasium / Stable-Baselines3. Redémarre le noyau après installation.
5. Ouvre `Code/01_Tests/02_Connexion_Simulateur.ipynb` lorsque le jeu est lancé.
6. Teste `03_Reception_Telemetrie.ipynb`. Le CSV se trouve dans `Code/reports/`.
7. Chaque autre notebook peut se lancer seul en sélectionnant le même noyau Python 3.9.

### Fonctionnement et limites réelles

- **Pas de venv ni de Makefile**. Les installations `pip` s'appliquent **à l'interpréteur du noyau sélectionné**, donc elles peuvent modifier d'autres projets utilisant le même Python. Vérifie la cellule de diagnostic.
- **Assetto Corsa Gym** n'est pas recopié : on utilise le projet déjà présent à la racine, notamment la définition de la mémoire partagée et les CSV de pistes.
- Le port UDP **2345** transmet les données et le port TCP **2347** sert à la gestion de simulation. Le plugin `sensors_par` doit être actif dans Assetto Corsa.
- Une seule connexion de télémétrie peut être cliente active à la fois. Ne lance pas simultanément plusieurs notebooks qui ouvrent le flux UDP.
- Les notebooks de télémétrie se contentent de recevoir les données : aucune commande au véhicule.
- Les notebooks vJoy n'envoient **aucun mouvement par défaut**. Tu dois mettre le booléen d'activation à `True` consciemment et vérifier le périphérique.
- Caméra : nécessite capture activée dans la config du plugin, worker de capture et Windows. Pour les timestamps, le `dual_buffer` fourni doit être le même que celui installé côté jeu.
- Entraînement PPO : **prototype expérimental réellement branché au simulateur**, pas la reprise exacte de tous les algorithmes du projet `ouarti_stage1` initial. Afin de rester 100 % notebook, le projet est réorganisé ; tous les modules originaux complexes (perception stratégique hiérarchique et supervision multi-agents) n'ont pas été intégralement portés. Les notebooks PPO nécessitent `vjoy_executed_by_server=True` et `sampling_freq=100` dans le plugin et une session compatible. Aucun entraînement ne démarre automatiquement.
- Apprentissage par imitation : exige **les actions réellement enregistrées** du conducteur ; aucune donnée n'est inventée.
- Python 3.9 est une version en fin de maintenance ; vérifier l'absence de conflits avec l'installation globale, pilotes et GPU.
- **Le runtime Python de l'application du jeu est distinct de ton Python 3.9 Jupyter.** Il ne faut pas remplacer l'interpréteur embarqué Assetto Corsa.

### Vérifications effectuées pour le ZIP

- Les notebooks sont des fichiers valides au format `.ipynb` et leurs cellules Python ont été analysées syntaxiquement.
- Aucune connexion à ton jeu, GPU, pilote vJoy ou caméra n'a été testée ici ; seuls des essais sur ton PC peuvent valider les flux réels et les timings.
- Aucune ancienne copie du dépôt Assetto Corsa Gym, aucun `.py` généré, aucun exécutable et aucun environnement virtuel ne sont inclus.

---

## Journal de mise en service — corrections vérifiées

Cette partie est ajoutée à partir du compte rendu de mise en service précédemment établi : elle liste les erreurs rencontrées, les modifications effectuées **dans les fichiers du jeu**, les commandes PowerShell de diagnostic et les fonctionnalités validées.

> **État au 12 novembre 2026 :** les essais effectués sur le PC ont validé le noyau Jupyter Python 3.9.13, la communication avec `sensors_par`, la réception de la télémétrie, le contrôle vJoy du volant et des pédales, puis la capture caméra (confirmation de fonctionnement par l'utilisateur). **L'entraînement et la synchronisation complète images/télémétrie ne sont pas encore validés.**
>
> **Objet de ce document :** garder une trace des changements réalisés, des erreurs rencontrées et de la configuration qui a permis au projet de fonctionner. Ce guide décrit l'installation *existante* ; il ne faut pas réexécuter toutes les installations si tout fonctionne déjà.

### 1. Architecture retenue

L'objectif était d'abandonner le `Makefile`, `main.py` et l'environnement virtuel du prototype `ouarti_stage1`, pour utiliser **des notebooks Jupyter indépendants** dans VS Code, en sélectionnant manuellement le **Python 3.9.13 global de Windows**.

Structure réelle retenue (le dossier s'appelle **`Code`**, pas `OUARTI`) :

```text
IA_projet_Ouarti_ds_github/
├── assetto_corsa_gym/         # Dépôt déjà présent ; NE PAS le remplacer
│   └── assetto_corsa_gym/
│       └── AssettoCorsaPlugin/
│           └── plugins/sensors_par/
├── Code/
│   ├── 00_Installer_Bibliotheques_Python39.ipynb
│   ├── 01_Tests/
│   │   ├── 01_Diagnostic.ipynb
│   │   ├── 02_Connexion_Simulateur.ipynb
│   │   ├── 03_Reception_Telemetrie.ipynb
│   │   ├── 04_Test_Volant_vJoy.ipynb
│   │   ├── 05_Test_Pedales_vJoy.ipynb
│   │   └── 06_Test_Camera.ipynb
│   ├── 02_Donnees/
│   ├── 03_Entrainement/
│   ├── 04_Evaluation/
│   ├── 05_HUD/
│   ├── datasets/
│   ├── models/
│   └── reports/
└── ...
```

**Correction des chemins :** les notebooks initialement générés cherchaient `PROJECT = REPO / 'OUARTI'` : ce dossier n'existe pas dans l'organisation choisie. Il a fallu remplacer cette référence par `PROJECT = REPO / 'Code'` (ou détecter la racine avec les dossiers `01_Tests` et `assetto_corsa_gym`). Les ressources d'Assetto Corsa Gym restent **à côté de `Code/`**, au niveau supérieur.

Il existe **deux emplacements distincts** pour le plugin :

1. **Copie du dépôt Git** : `assetto_corsa_gym/assetto_corsa_gym/AssettoCorsaPlugin/plugins/sensors_par/` (sert notamment aux imports des notebooks et aux définitions de mémoire partagée).
2. **Plugin réellement exécuté par le jeu** : `<DOSSIER_ASSETTO_CORSA>/apps/python/sensors_par/` (c'est là qu'ont été modifiés `config.py` et `ego_server.py`).

Modifier la copie du dépôt ne modifie pas automatiquement le plugin chargé par le jeu. Les deux copies doivent rester compatibles, notamment les structures partagées (`dual_buffer.py`).

### 2. Python global et noyau Jupyter

- **Python global Windows** : 3.9.13, sélectionné directement comme noyau de chaque notebook dans VS Code ; **aucun venv ou kernelspec personnalisé n'est nécessaire**.
- **Python intégré à Assetto Corsa** : 3.3.5, utilisé par les applications Python du jeu. Il est distinct de Python 3.9.
- `ipykernel` était déjà installé et importable en version **6.31.0**. Nous n'avons pas eu besoin de le mettre à jour pour résoudre la panne.

#### Erreur rencontrée : `TypeVar` introuvable

Erreur VS Code :

```text
The kernel failed to start as 'TypeVar' could not be imported
from ...\Python39\Lib\site-packages\typing_extensions.py
```

**Correction effectuée** : réinstallation ciblée de `typing_extensions` en **4.12.2** dans Python 3.9.13, puis vérification :

```powershell
py -3.9 -m pip show typing_extensions
py -3.9 -c "import typing_extensions as t; print(t.__file__); print(hasattr(t, 'TypeVar'))"
```

Résultat obtenu : `TypeVar disponible : True`. Le noyau Jupyter a ensuite pu exécuter les cellules. Un avertissement `Ignoring invalid distribution -illow` (Pillow) subsistait, sans empêcher ces tests. **Ne pas mettre à jour aveuglément toutes les dépendances**, car Assetto Corsa Gym utilise des versions historiques de certaines bibliothèques.

### 3. Test 01 — diagnostic et chemins

La détection du dossier projet échouait avec :

```text
FileNotFoundError: Dossier OUARTI absent : extraire OUARTI à la racine du dépôt.
```

**Cause :** les fichiers étaient sous `Code/` et non `OUARTI/`. La correction retenue a consisté à garder `Code/` et à remplacer le chemin attendu dans les notebooks.

**Résultat :** le noyau Jupyter Python 3.9.13 et les chemins du projet ont été validés.

### 4. Test 02 — connexion au simulateur

Le notebook `02_Connexion_Simulateur.ipynb` a pu récupérer la configuration du plugin et les informations de session. Exemple de sortie :

```text
ego_sampling_freq       : 25
sampling_freq           : 50
vjoy_executed_by_server : False
screen_capture_enable  : False (avant activation caméra)
color_mode              : gray
final_image_width       : 320
final_image_height      : 240
Session                 : ks_barcelona layout_gp / abarth500
```

**Ports du plugin** :

- **2345 / UDP** : flux de télémétrie (`ego_server`). `Test-NetConnection -Port 2345` vérifie **TCP**, donc son résultat ne suffit pas pour diagnostiquer ce flux UDP.
- **2347 / TCP** : commandes de gestion (`get_config`, `get_static_info`).

Contrôle du serveur de gestion :

```powershell
Test-NetConnection 127.0.0.1 -Port 2347
```

La connexion TCP seule ne garantit pas la réponse à `get_config` : un démarrage partiel du plugin peut laisser un port ouvert sans réponse utile.

### 5. Test 03 — réception de la télémétrie

Le notebook `03_Reception_Telemetrie.ipynb` a reçu des séries de mesures (un premier essai a recueilli **328 échantillons**, avec **93 colonnes**), puis a écrit :

```text
Code/reports/telemetrie_test.csv
```

- À l'arrêt, la vitesse était presque nulle avec de faibles fluctuations numériques.
- En roulant, la vitesse et le régime moteur ont augmenté de manière cohérente.
- Le champ `speed` représente la vitesse en **m/s** dans cette chaîne de télémétrie : `km/h = speed * 3.6`.
- La colonne `_capture_wall_time`, lorsqu'elle est présente, contient l'horodatage de réception (temps Unix) ; elle sert à situer le début et la fin de l'enregistrement.

**Attention :** les mesures du CSV du test 03 ne décrivent **pas** ce qui se passe pendant un test vJoy ultérieur : ce sont deux enregistrements différents.

### 6. Tests 04 et 05 — vJoy, volant et pédales

La DLL vJoy utilisée est :

```text
C:\Program Files\vJoy\x64\vJoyInterface.dll
```

L'accès fonctionne directement depuis un notebook via `ctypes` et `vJoyInterface.dll` (`GetVJDStatus`, `AcquireVJD`, `SetAxis`, `RelinquishVJD`). Le `Device 1` a renvoyé un statut disponible **1**, et les commandes de direction ont été acceptées.

#### Affectations confirmées dans Content Manager

| Axe HID  | vJoy      | Fonction dans Assetto Corsa |
| -------- | --------- | --------------------------- |
| `0x30` | Axe 1 (X) | Direction                   |
| `0x31` | Axe 2 (Y) | Accélérateur              |
| `0x32` | Axe 3 (Z) | Frein                       |

Valeurs vJoy utilisées : `0` à `32767`, centre de la direction autour de `16384`.

#### Pourquoi le premier test du volant déclenchait parfois les pédales

L'ancien test ne commandait que l'axe **X** : il ne fixait pas les valeurs de repos des axes **Y** et **Z**. Des états de pédales déjà présents dans vJoy, ou interprétés comme partiellement appuyés par le jeu, pouvaient subsister. L'ancienne télémétrie montrait d'ailleurs `accStatus ≈ 0.42` et `brakeStatus = 0`, **mais elle provenait d'un autre enregistrement** : elle ne prouve pas à elle seule ce qui s'est produit pendant le test du volant.

**Correction appliquée et validée dans le simulateur :** envoyer explicitement la position de repos de tous les axes avant le test :

```python
# À appeler APRES acquisition de vJoy, avec la fonction envoyer(...) du notebook.
envoyer(0x30, 16384)  # Volant centré
envoyer(0x31, 0)      # Accélérateur relâché
envoyer(0x32, 0)      # Frein relâché
```

Les pédales ont été testées séparément en faisant :

1. Monter l'accélérateur de 0 à 100 % progressivement ;
2. Appliquer 100 % de frein pendant 1 s puis le relâcher ;
3. Relâcher progressivement l'accélérateur jusqu'à 0 % ;
4. Appliquer 100 % de frein pendant 1 s, puis tout relâcher.

**Résultat :** tests de direction et de pédales validés sur le PC. Pour les nouveaux essais, toujours tester dans une session sécurisée, initialiser les trois axes et remettre les commandes au repos dans un bloc `finally` avant de libérer vJoy.

### 7. Test 06 — activation de la capture caméra dans le jeu

Le notebook caméra échouait d'abord parce que le plugin répondait :

```text
screen_capture_enable : False
RuntimeError: Activer screen_capture_enable dans le plugin sensors_par du jeu.
```

Nous avons modifié **le `config.py` installé dans le jeu**, pas seulement la copie du dépôt :

```text
<DOSSIER_ASSETTO_CORSA>/apps/python/sensors_par/config.py
```

#### Réglages définitifs utilisés

À conserver à l'intérieur du `__init__` de la classe `Config` :

```python
# Activer le processus externe Python 3.9 pour la capture.
self.enable_alternative_python_interpreter = True
self.config_python_env_name = "p309"   # Nom de secours ignoré si chemin explicite
self.config_python_executable = r"C:\Users\<UTILISATEUR>\AppData\Local\Programs\Python\Python39\python.exe"
self.screen_capture_worker = "screen_capture_worker.py"

# Capture caméra
self.screen_capture_enable = True
self.final_image_width = 640 // 2     # 320
self.final_image_height = 480 // 2    # 240
self.screen_capture_freq = 25
self.color_mode = "gray"
```

**À adapter :** remplace `<UTILISATEUR>` par le nom de ton compte Windows. Le plus fiable est d'obtenir le chemin avec `py -3.9 -c "import sys; print(sys.executable)"`.

**Erreur n° 1 :** `config_python_executable` était `None`, ce qui poussait le plugin à chercher un environnement Anaconda `...\anaconda3\envs\p309\python.exe`, inexistant sur ce PC.

**Erreur n° 2 :** le chemin a ensuite été écrit entre **accolades `{...}`**, ce qui créait un objet Python `set` au lieu d'une chaîne. Le journal affichait :

```text
TypeError: argument should be string, bytes or integer, not set
```

**Correction :** une chaîne `r"C:\...\python.exe"` **sans accolades**, par exemple `self.config_python_executable = r"..."`. Enregistrer `config.py` puis redémarrer complètement le jeu pour charger les changements.

### 8. Correction `win32event` dans le Python 3.3 intégré au jeu

Avec `screen_capture_enable=True`, l'initialisation du serveur échouait :

```text
WARNING - win32event not installed; screen capture is not possible.
NameError: global name 'win32event' is not defined
```

**Cause :** Assetto Corsa exécute `ego_server.py` sous **Python 3.3.5 embarqué**, où `win32event` n'était pas disponible. Installer `pywin32` dans le Python **global 3.9.13** ne résout pas l'import dans le Python intégré au jeu.

**Correction effectuée :** modification du fichier du jeu :

```text
<DOSSIER_ASSETTO_CORSA>/apps/python/sensors_par/ego_server.py
```

Nous avons ajouté un repli **`ctypes` / API Windows** lorsque `import win32event` échoue. Les appels `CreateEvent` et `SetEvent` passent alors par `kernel32`, avec un objet de compatibilité exposant les méthodes attendues. Le journal a ensuite indiqué :

```text
INFO - Windows events disponibles via ctypes.
```

Extrait simplifié du principe (ne pas coller une deuxième copie si la correction fonctionne déjà) :

```python
try:
    import win32event
except ImportError:
    import ctypes
    kernel32 = ctypes.WinDLL("kernel32", use_last_error=True)
    kernel32.CreateEventW.argtypes = [
        ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_wchar_p
    ]
    kernel32.CreateEventW.restype = ctypes.c_void_p
    kernel32.SetEvent.argtypes = [ctypes.c_void_p]
    kernel32.SetEvent.restype = ctypes.c_int
    # Une classe de compatibilité définit ensuite CreateEvent(...) et SetEvent(...).
```

Une erreur secondaire `TypeError: error() missing 1 required positional argument: 'msg'` venait du gestionnaire d'erreurs du plugin. Elle ne constituait pas la cause initiale du plantage caméra et **n'a pas été traitée comme un correctif validé**.

### 9. Correction des bibliothèques manquantes dans Python 3.9

Une fois le serveur relancé, le notebook recevait la configuration `screen_capture_enable=True`, mais échouait avec :

```text
RuntimeError: No stable timestamped camera frame
```

La liste des processus ne montrait pas de worker caméra durablement actif. Le journal du sous-processus :

```text
<DOSSIER_ASSETTO_CORSA>/sensor_par_subprocess_log.txt
```

contenait :

```text
screen_capture_worker initialized
ERROR: Error importing screen_capture: No module named 'cv2'
```

#### OpenCV

Installation exécutée dans le Python global **3.9.13** :

```powershell
py -3.9 -m pip install --no-deps "opencv-python==4.8.1.78"
```

Le résultat a confirmé l'installation de `opencv-python-4.8.1.78`. Le module importé s'appelle `cv2`.

#### MSS

Après OpenCV, le test des imports a révélé :

```text
ModuleNotFoundError: No module named 'mss'
```

La commande proposée a été :

```powershell
py -3.9 -m pip install --no-deps "mss==9.0.1"
```

**L'utilisateur a confirmé que la caméra fonctionne après cette étape.** La version exacte de `mss` installée peut être confirmée avec `py -3.9 -m pip show mss` ; elle n'a pas été affichée dans la conversation.

Pour vérifier les modules de capture en une seule commande :

```powershell
py -3.9 -c "import cv2, mss, numpy, win32event, win32con, win32gui; print('Imports capture OK'); print('OpenCV :', cv2.__version__)"
```

`pip` affichait aussi un avertissement `-illow` et une suggestion de mise à jour. **Ces avertissements n'expliquaient pas la panne caméra** ; nous n'avons pas mis à jour globalement `pip` ou toutes les dépendances.

### 10. État final vérifié

| Test                                     | Statut        | Preuve observée                                                                       |
| ---------------------------------------- | ------------- | -------------------------------------------------------------------------------------- |
| `01_Diagnostic.ipynb`                  | ✅ Validé    | Python global 3.9.13 utilisable dans Jupyter                                           |
| `02_Connexion_Simulateur.ipynb`        | ✅ Validé    | Configuration et session récupérées via TCP 2347                                    |
| `03_Reception_Telemetrie.ipynb`        | ✅ Validé    | Données dynamiques, 93 colonnes, CSV, vitesse cohérente                              |
| `04_Test_Volant_vJoy.ipynb`            | ✅ Validé    | Direction pilotée ; pédales initialisées au repos                                   |
| `05_Test_Pedales_vJoy.ipynb`           | ✅ Validé    | Accélération, freinage, relâchement testés                                         |
| `06_Test_Camera.ipynb`                 | ✅ Confirmé  | L'utilisateur a confirmé que la capture fonctionne après les dépendances manquantes |
| Synchronisation images + télémétrie   | ⏳ À valider | Pas encore de vérification de dataset synchronisé                                    |
| Entraînement PPO / pilotage IA autonome | ⏳ À valider | Pas encore d'entraînement complet démontré                                          |

### 11. Contrôles rapides si la caméra retombe en panne

1. **Assetto Corsa est-il ouvert dans une session de conduite ?** Content Manager seul ne suffit pas.
2. **Port de gestion :** `Test-NetConnection 127.0.0.1 -Port 2347` ; si `True`, vérifier aussi que `get_config` répond réellement.
3. **Configuration du jeu :** `screen_capture_enable=True`, `enable_alternative_python_interpreter=True`, et `config_python_executable` est une **chaîne valide**, pas `None` ou `{...}`.
4. **Journal principal :**
   ```powershell
   Get-Content "$env:USERPROFILE\Documents\Assetto Corsa\logs\py_log.txt" -Tail 100
   ```
5. **Journal du worker :**
   ```powershell
   Get-Content "<DOSSIER_ASSETTO_CORSA>\sensor_par_subprocess_log.txt" -Tail 80
   ```
6. **Dépendances Python 3.9 :**
   ```powershell
   py -3.9 -c "import cv2, mss, win32event, win32gui, numpy; print('OK')"
   ```
7. **Mémoire partagée :** si le notebook remonte `No stable timestamped camera frame`, vérifier que le worker externe démarre et écrit effectivement les images. `screen_capture_enable=True` ne garantit pas, à lui seul, qu'une image est produite.
8. **Après toute modification de `config.py` ou `ego_server.py` :** enregistrer, quitter complètement `acs.exe`, puis relancer une session et lire **les nouvelles lignes horodatées** du journal.

### 12. Fichiers modifiés / dépendances installées

| Élément                                     | Changement                                                                                    |
| --------------------------------------------- | --------------------------------------------------------------------------------------------- |
| `Code/01_Tests/*.ipynb`                     | Adaptation du chemin `OUARTI` → `Code`, vérifications et tests                          |
| `Code/01_Tests/04_Test_Volant_vJoy.ipynb`   | Initialisation X/Y/Z pour éviter les commandes de pédales parasites                         |
| `Code/01_Tests/05_Test_Pedales_vJoy.ipynb`  | Cycle complet accélérateur/frein validé                                                    |
| `.../apps/python/sensors_par/config.py`     | Interpréteur alternatif Python global 3.9, caméra activée, chemin corrigé en chaîne      |
| `.../apps/python/sensors_par/ego_server.py` | Repli `ctypes` pour les événements Windows en l'absence de `win32event` dans Python 3.3 |
| Python 3.9 global                             | `typing_extensions==4.12.2`, `opencv-python==4.8.1.78`, installation de `mss`           |

> **Important pour Git/GitHub :** les modifications apportées dans `apps/python/sensors_par/` **à l'intérieur de l'installation du jeu** ne sont pas automatiquement versionnées dans ton dépôt. Conserve un diff ou une copie de ces deux fichiers corrigés, en évitant de publier des chemins Windows personnels. Si le jeu est réinstallé, ces changements peuvent être perdus.

---

**Résumé :** l'architecture 100 % notebooks, Python 3.9 global, la télémétrie et vJoy fonctionnent ; la caméra a nécessité (1) une configuration correcte du worker Python externe, (2) un correctif d'événements Windows pour le Python 3.3 du jeu, puis (3) OpenCV et MSS dans Python 3.9. Les prochaines étapes portent sur l'horodatage/synchronisation des images et de la télémétrie, puis l'entraînement de l'IA.
