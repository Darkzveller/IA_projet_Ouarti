# OUARTI — README du dossier `Code/`

**Architecture actuelle :** notebooks Jupyter autonomes sous Python global **3.9.13**, avec le dossier `Code/` à la racine du dépôt, à côté de `assetto_corsa_gym/`. Ce document réunit le README du dossier `Code` et le journal technique **OUARTI — mise en service**, sans remplacer le README général du dépôt.

> **État validé sur le PC :** noyau Jupyter, connexion au simulateur, télémétrie, volant vJoy, pédales vJoy et capture caméra. **Non encore validés :** synchronisation complète des images et de la télémétrie, entraînement PPO et pilotage autonome.
>
> **À retenir :** la section sur la génération initiale du ZIP décrit uniquement les vérifications effectuées lors de sa création. Les essais réels ultérieurs sont documentés dans la mise en service. Les modifications faites directement dans `apps/python/sensors_par/` du jeu ne sont pas sauvegardées automatiquement dans Git.

## Sommaire

- [Présentation et architecture Jupyter](#présentation--code-jupyter-autonome-python-39)
- [Emplacement du dossier dans le dépôt](#emplacement-du-dossier-dans-le-dépôt)
- [Démarrage](#démarrage)
- [Fonctionnement et limites réelles](#fonctionnement-et-limites-réelles)
- [Vérifications initiales du ZIP](#vérifications-effectuées-lors-de-la-génération-initiale-du-zip)
- [Journal de mise en service](#journal-technique--mise-en-service-de-jupyter-vjoy-télémétrie-et-caméra-assetto-corsa)
- [Configuration de la capture caméra](#7-test-06--activation-de-la-capture-caméra-dans-le-jeu)
- [Correction win32event](#8-correction-win32event-dans-le-python-33-intégré-au-jeu)
- [Dépendances OpenCV et MSS](#9-correction-des-bibliothèques-manquantes-dans-python-39)
- [État final des tests](#10-état-final-vérifié)
- [Dépannage caméra](#11-contrôles-rapides-si-la-caméra-retombe-en-panne)

---

## Présentation — Code Jupyter autonome (Python 3.9)

Le dossier contient **uniquement des notebooks `.ipynb`** pour le code du projet, sans `main.py`, sans Makefile, sans dossier `ouarti/` et sans nouvel environnement virtuel. Chaque notebook contient ses propres fonctions (y compris les fonctions réseau) et se lance individuellement. Il n'est pas nécessaire de lancer un autre notebook avant lui, sauf le notebook d'installation si des dépendances manquent.

## Emplacement du dossier dans le dépôt

Le dossier de notebooks s’appelle désormais **`Code/`**. Il est placé à la racine du dépôt `IA_projet_Ouarti_ds_github`, à côté de `assetto_corsa_gym/` (déjà présent, à conserver).

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

## Démarrage

1. Ouvre **la racine du dépôt** dans VS Code.
2. Ouvre `Code/00_Installer_Bibliotheques_Python39.ipynb`.
3. Sélectionne **Python 3.9** comme noyau. Ce notebook vérifie l'interpréteur avant toute installation.
4. Si besoin, mets `INSTALLER_BASE=True`, puis exécute les cellules. Mets `INSTALLER_IA=True` pour PyTorch / Gymnasium / Stable-Baselines3. Redémarre le noyau après installation.
5. Ouvre `Code/01_Tests/02_Connexion_Simulateur.ipynb` lorsque le jeu est lancé.
6. Teste `03_Reception_Telemetrie.ipynb`. Le CSV se trouve dans `Code/reports/`.
7. Chaque autre notebook peut se lancer seul en sélectionnant le même noyau Python 3.9.

## Fonctionnement et limites réelles

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

## Vérifications effectuées lors de la génération initiale du ZIP

- Les notebooks sont des fichiers valides au format `.ipynb` et leurs cellules Python ont été analysées syntaxiquement.
- Lors de la génération du ZIP, aucune connexion au jeu, au GPU, à vJoy ni à la caméra n’avait été testée. Les tests réalisés **ensuite sur le PC** sont consignés dans le journal de mise en service ci-dessous.
- Aucune ancienne copie du dépôt Assetto Corsa Gym, aucun `.py` généré, aucun exécutable et aucun environnement virtuel ne sont inclus.

---

## Journal technique — mise en service de Jupyter, vJoy, télémétrie et caméra Assetto Corsa

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

| Axe HID | vJoy | Fonction dans Assetto Corsa |
|---|---|---|
| `0x30` | Axe 1 (X) | Direction |
| `0x31` | Axe 2 (Y) | Accélérateur |
| `0x32` | Axe 3 (Z) | Frein |

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

| Test | Statut | Preuve observée |
|---|---|---|
| `01_Diagnostic.ipynb` | ✅ Validé | Python global 3.9.13 utilisable dans Jupyter |
| `02_Connexion_Simulateur.ipynb` | ✅ Validé | Configuration et session récupérées via TCP 2347 |
| `03_Reception_Telemetrie.ipynb` | ✅ Validé | Données dynamiques, 93 colonnes, CSV, vitesse cohérente |
| `04_Test_Volant_vJoy.ipynb` | ✅ Validé | Direction pilotée ; pédales initialisées au repos |
| `05_Test_Pedales_vJoy.ipynb` | ✅ Validé | Accélération, freinage, relâchement testés |
| `06_Test_Camera.ipynb` | ✅ Confirmé | L'utilisateur a confirmé que la capture fonctionne après les dépendances manquantes |
| Synchronisation images + télémétrie | ⏳ À valider | Pas encore de vérification de dataset synchronisé |
| Entraînement PPO / pilotage IA autonome | ⏳ À valider | Pas encore d'entraînement complet démontré |

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

| Élément | Changement |
|---|---|
| `Code/01_Tests/*.ipynb` | Adaptation du chemin `OUARTI` → `Code`, vérifications et tests |
| `Code/01_Tests/04_Test_Volant_vJoy.ipynb` | Initialisation X/Y/Z pour éviter les commandes de pédales parasites |
| `Code/01_Tests/05_Test_Pedales_vJoy.ipynb` | Cycle complet accélérateur/frein validé |
| `.../apps/python/sensors_par/config.py` | Interpréteur alternatif Python global 3.9, caméra activée, chemin corrigé en chaîne |
| `.../apps/python/sensors_par/ego_server.py` | Repli `ctypes` pour les événements Windows en l'absence de `win32event` dans Python 3.3 |
| Python 3.9 global | `typing_extensions==4.12.2`, `opencv-python==4.8.1.78`, installation de `mss` |

> **Important pour Git/GitHub :** les modifications apportées dans `apps/python/sensors_par/` **à l'intérieur de l'installation du jeu** ne sont pas automatiquement versionnées dans ton dépôt. Conserve un diff ou une copie de ces deux fichiers corrigés, en évitant de publier des chemins Windows personnels. Si le jeu est réinstallé, ces changements peuvent être perdus.

---

**Résumé :** l'architecture 100 % notebooks, Python 3.9 global, la télémétrie et vJoy fonctionnent ; la caméra a nécessité (1) une configuration correcte du worker Python externe, (2) un correctif d'événements Windows pour le Python 3.3 du jeu, puis (3) OpenCV et MSS dans Python 3.9. Les prochaines étapes portent sur l'horodatage/synchronisation des images et de la télémétrie, puis l'entraînement de l'IA.
