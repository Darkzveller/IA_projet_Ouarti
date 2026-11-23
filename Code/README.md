# OUARTI — README du dossier `Code/`

## Afficheur de trajectoire à trois agents

Ouvrir le [poste de guidage](06_Trois_Agents/00_Poste_de_guidage.ipynb) pour utiliser la perception et la trajectoire avec un pilote humain. Le troisième agent PPO se charge dans les modes de pilotage et de test qui le demandent. Le [protocole de recette](06_Trois_Agents/PROTOCOLE.md) couvre les essais isolés, l’affichage en direct et le pilotage optionnel. Les carnets PPO V3 décrits plus bas correspondent au prototype monolithique archivé.

### Mise à jour du 23/11/2026 — État des trois agents (Imola, vue capot)

> **Résumé au 23/11/2026 :** la chaîne complète `06_Trois_Agents/` a été passée en **vue capot (`capot_abarth500_v1`) sur Imola / Abarth 500** (`bgr 640×360`, 100 % caméra). Le HUD temps réel tourne à **`75,8 FPS`** sur GPU (mais a encore du mal à bien percevoir les virages au loin) et l'Agent 3 PPO a bouclé **`3/3` tours complets d'Imola (`4 906 m`) sans sortie ni collision**.

#### Modifications effectuées le 23/11/2026 dans `Code/06_Trois_Agents/`

| Notebook | Changements apportés le 23/11/2026 |
|---|---|
| `01_Perception.ipynb` | U-Net 3 niveaux `256×144` (16:9 exact) + perte `CE + Soft-Dice`, entraîné sur `240` images propres (`session_20261123_045440`) et validé sur `100` images d'un 2ᵉ tour indépendant (`session_20261123_051954`) ; inférence GPU automatique avec repli CPU ; rétrocompatible `contrat=1/2`. |
| `02_Trajectoire.ipynb` | Trajectoire monotone v6 ancrée devant le capot (sans bombements extérieurs), comblement ciblé des micro-trous d'ombre, secours en arc quadratique lisse et plancher d'horizon `max(117, y_loin + 3)`. |
| `Capteurs_lecture.ipynb` | Lissage temporel EMA (`0,35` position, `0,25` vitesse) + rendu courbe `smooth=True` dans l'overlay HUD. |
| `03_Pilote_PPO.ipynb` | Pénalité de survitesse et anti-inertie gaz lorsque `v > cible`, permettant à PPO d'apprendre à lever le pied et ralentir avant les virages. |
| `Pilotage_Assetto.ipynb` | Repli paresseux `_received_unix` si `timestamp_unix` absent, lecture de `actualGear`, et boucle de retry Windows sur `os.replace(..., 'command.txt')` contre les `PermissionError [WinError 5]` du pont CSP. |
| `00_Poste_de_guidage.ipynb` | Ajout de `MODE = 'sauvegarder_checkpoint'` (sauvegarde CSP en 1 clic), bascule GPU auto pour A1 en mode réel, lots Stage 4 à `512` pas (`n_epochs=8`, `lr=5e-4`), versions mises à jour. |

#### Réussites et versions de référence (23/11/2026)

- **Agent 1 (`VERSION_A1 = '20261123_064246_bb00ca1e'`) :** `93,46 %` IoU piste (`92,6 %` horizon), `84,3 %` herbe, `43,9 %` vibreurs ; pipeline `A1 GPU + A2 CPU` en **`13,2 ms/image` (`75,8 FPS`)**.
- **Agent 2 (`VERSION_A2 = '20261123_064311_1622081c'`) :** **`460 / 460` (`100 %`) et `0` franchissement** sur les 4 sessions annotées d'Imola ; `810 / 810` sur tout le 2ᵉ tour non vu.
- **Agent 3 (`VERSION_A3 = '20261123_191455_9f12c152'`, `31 744` pas PPO) :** Stage 1 (`10 m`) `10/10`, Stage 2 (`30 m`) `10/10`, Stage 3 (`100 m`) `10/10`, et **Stage 4 (tour complet `4 906 m`) `3/3` tours validés** (`0` sortie, `0` collision, `0` perte de guidage, écart moyen `4,0 %` — rapport `reports/trois_agents/evaluer_a3_577e54af5c.json`).
- **Recette hors jeu (`recette_hors_jeu`) :** 100 % passante.

#### Problèmes et limites actuels (23/11/2026)

- **Virages au loin (HUD / A1 + A2) :** le HUD est fluide en temps réel mais a encore du mal à percevoir et anticiper les virages très lointains ou masqués derrière une crête (vision pure sans carte du circuit).
- **Vitesse trop lente (`≤ 50 km/h` en ligne droite, jusqu'à `~15 km/h` en virage) :** la vitesse cible d'A2 est plafonnée à `50 km/h` (`12 + 38 × sigmoid`), et l'Agent 3 braque parfois le volant en butée (`±1,0`) dans les virages serrés, ce qui freine la voiture par frottement.
- **Petits zigzags légers en ligne droite (Agent 3) :** gain de volant trop vif à `8,3 Hz` et pénalité de lissage volant trop faible (`-0,008`).
- **Trajectoire prudente (« milieu → corde ») :** pas encore de trajectoire sportive « extérieur → corde → extérieur ».
- **Généralisation :** entraîné et validé uniquement sur Imola par temps sec sans trafic ; évaluation Stage 4 encore à étendre de `3` à `10` épisodes.

---

**Architecture actuelle :** notebooks Jupyter autonomes sous Python global **3.9.13**, avec le dossier `Code/` à la racine du dépôt, à côté de `assetto_corsa_gym/`. Ce document réunit le README du dossier `Code` et le journal technique **OUARTI — mise en service**, sans remplacer le README général du dépôt.

> **État validé sur le PC :** noyau Jupyter, connexion au simulateur, télémétrie, volant vJoy, pédales vJoy et capture caméra. **Non encore validés :** synchronisation complète des images et de la télémétrie, entraînement PPO et pilotage autonome.
>
> **À retenir :** la section sur la génération initiale du ZIP décrit uniquement les vérifications effectuées lors de sa création. Les essais réels ultérieurs sont documentés dans la mise en service. Les modifications faites directement dans `apps/python/sensors_par/` du jeu ne sont pas sauvegardées automatiquement dans Git.

## Sommaire

- [Mise à jour du 23/11/2026 — État des trois agents (Imola, vue capot)](#mise-à-jour-du-23112026--état-des-trois-agents-imola-vue-capot)
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

## Diagnostic du checkpoint — 16 novembre 2026

Le notebook autonome `01_Tests/07_Diagnostic_Checkpoint_CSP.ipynb` interroge
uniquement `PING`, `CAPABILITIES` et `STATUS`. Il ne commande pas la voiture
et ne nécessite ni PPO, ni vJoy, ni connexion de télémétrie.

Sur le PC examiné, le jeu répond effectivement `PONG`, mais annonce
`full_snapshot=false; position_fallback=false; offline=true`, puis
`NOT_SAVED`. La connexion fonctionne ; aucun mécanisme de restauration n'est
actuellement utilisable. L'installation déclare **CSP 0.1.79 (build 2144)** et
son SDK local ne déclare pas `ac.saveCarStateAsync` ou `ac.loadCarState`.
Le SDK expose `physics.setCarPosition`, mais sa présence ne suffit pas :
`physics.allowed()` doit aussi autoriser son utilisation dans la session.

Le notebook `03_Entrainement/02_Entrainement_PPO_Assetto.ipynb` contrôle
désormais ces capacités avant la sauvegarde et avant l'entraînement. Il
explique aussi comment créer le checkpoint si `STATUS` indique `NOT_SAVED`.
L'activation de l'entraînement est remise à `False` et le chemin du diagnostic
des journaux est corrigé.

Pour débloquer les épisodes au départ fixe, vérifier la version dans
**Content Manager > Settings > Custom Shaders Patch > About & Updates**,
puis choisir une version compatible avec le plugin `sensors_par` et les
fonctions nécessaires. Après tout changement, redémarrer le jeu et relancer
le diagnostic. Une mise à jour ne garantit pas à elle seule que les fonctions
physiques soient autorisées. Ne passer à la sauvegarde du checkpoint qu'une
fois au moins une capacité disponible ; après `SAVE`, le notebook PPO vérifie
encore la position, l'orientation et la vitesse lors de chaque restauration.

Références : [SDK CSP](https://github.com/ac-custom-shaders-patch/acc-lua-sdk)
et [utilisation des snapshots dans l'application CSP Debug](https://github.com/ac-custom-shaders-patch/acc-lua-internal/blob/main/included-apps/CspDebug/CspDebug.lua).
Le SDK installé est consultable sous
`<Assetto Corsa>/extension/internal/lua-sdk/ac_apps/lib.lua`.

Validation effectuée : syntaxe des cellules des notebooks actifs, scénarios
de capacités et protocole de fichiers testés hors jeu, puis interrogation du
jeu par `PING`, `CAPABILITIES` et `STATUS`. Aucun `SAVE`, `LOAD` ou entraînement
n'a été lancé pendant cette vérification. Le retour automatique au départ
reste à valider sur une installation disposant des capacités nécessaires.

## Démarrage

### Superviseur local : apprentissage vers un tour complet

Le notebook **`03_Entrainement/06_Superviseur_Local_Autonome.ipynb`** enchaîne
localement entraînement, sauvegarde, évaluation déterministe et décision.
Il ne contacte ni Codex ni une API payante. Il applique des règles fixes et
ne modifie pas lui-même le code ou les hyperparamètres hors du parcours prévu.

Parcours par défaut : **30 m → 100 m → 300 m → 1 000 m → tour complet**.
Chaque leçon utilise un nouvel agent issu du meilleur précédent. Les lots
PPO augmentent de 512 à 8 192 pas : les retours au départ entre lots de
128 pas auraient empêché de pratiquer un tour entier. Les objectifs 300 m et
1 000 m restent dans le stage 3, avec leurs propres métadonnées et agents.
Reprendre ces agents via ce superviseur, dont les évaluations utilisent le
même objectif particulier que leur entraînement.

Pour lancer, ouvrir ce notebook seul avec le jeu dans une session locale et
modifier **REGLAGES** :

```python
ACTIVER_SUPERVISEUR = True
ACTIVER_SAUVEGARDE_CHECKPOINT = False  # True si absent, voiture immobile
CAMPAGNE = 'vers_un_tour_01'
DUREE_MAX_HEURES = 8.0
MAX_CYCLES_PAR_LANCEMENT = 12          # mettre 1 pour le premier essai
```

Puis **Tout exécuter**. La source par défaut est l'agent stage 2 actuel.
Le premier passage évalue une copie de référence, puis chaque cycle entraîne
un candidat distinct. Un candidat en régression est archivé pour inspection,
mais le prochain cycle repart du meilleur agent. Les petits écarts de
chronométrage inférieurs à 3 % ne suffisent pas à remplacer le meilleur.

Critères de passage par défaut : **10 épisodes valides**, au moins **90 % de
réussite**, au plus **5 % de sorties**, aucune collision détectée, sur **deux
évaluations consécutives**. Pour le tour complet, au moins trois tours sont
également exigés dans chaque série et aucun tour invalidé n'est accepté.
Avec 10 essais et 90 % de réussite, le seuil de réussite impose en pratique
au moins neuf tours réussis par série finale.

Un tour complet exige simultanément une progression nette d'au moins **une
longueur du circuit**, une augmentation du compteur `LapCount`, et aucun
`LapInvalidated` depuis le reset. Le départ doit lui-même être valide.
Un passage précoce de la ligne de départ ne valide donc pas l'objectif. Le
premier tour réussi est signalé dès que son épisode et sa preuve sont exportés,
même si la suite de l'évaluation rencontre ensuite un problème technique.
Cela ne vaut pas encore validation de la fiabilité sur plusieurs séries.

État et rapports : `reports/superviseur_local/<CAMPAGNE>/` contient
`etat.json`, `evenements.jsonl` et `NOTIFICATION.txt`. L'état indique le meilleur
agent archivé, les métriques, la leçon et le candidat éventuellement en attente.
Les rapports détaillés restent aussi dans `reports/evaluation_v3/`. Une
notification est locale (fichier et signal sonore), sans message envoyé à
Codex. Les versions précédentes restent accessibles via le gestionnaire 05.

Relancer la même campagne reprend son état ; un candidat sauvegardé après
entraînement est évalué avant de poursuivre l'apprentissage. Un changement du
parcours ou des critères demande un nouveau nom de campagne. Les limites de
temps/cycles peuvent être ajustées pour la prochaine reprise.

Par défaut, la boucle s'arrête après huit heures, douze cycles par lancement,
huit cycles sur une leçon, quatre cycles sans progrès, ou une panne technique
persistante après une nouvelle tentative. Les capteurs restent contrôlés ;
un incident n'est pas compté comme un échec de conduite. Le budget horaire est
contrôlé pendant les actions et entre les phases, mais un calcul PPO, une
sauvegarde ou un appel bloqué peut dépasser l'heure limite avant de rendre la
main. **Interrompre le noyau** reste l'arrêt manuel.

Le PC doit rester allumé, le jeu visible et un seul client de conduite actif.
L'atteinte du tour complet n'est pas garantie en une nuit ; le système peut
s'arrêter sur stagnation pour permettre une analyse. Les répétitions depuis
un départ fixe ne valident pas la généralisation à des circuits inconnus.

Validation hors jeu : exécution désactivée, horizon SB3 réel de 8 192 pas,
refus des passages de ligne prématurés et des tours invalidés, comparaison des
candidats, retour au meilleur après régression, progression de campagne,
notification du premier tour, pause/reprise persistante et arrêt sur erreur
testés avec des dépendances factices. Aucun entraînement ni tour réel n'a été
lancé lors de cette création.

### Stages, versions et retour en arrière

Le **stage 1** à 131 328 actions est conservé sous
`models/ppo_vision_checkpoint_v3_stage1.zip`, avec une copie vérifiée dans
`models/versions/`. Le **stage 2**, objectif **30 m**, est initialisé dans
`models/ppo_vision_checkpoint_v3_stage2.zip` avec les mêmes poids et le même
compteur global. Il n'a encore appris aucune action supplémentaire : ses
métadonnées indiquent `stage_timesteps=0` et identifient la version parente.

Les notebooks 02 et 03 sont préparés pour le stage 2, avec **4 096 actions**
supplémentaires et les commandes désactivées par défaut. Après ce premier
entraînement, le compteur attendu est 135 424 au total et 4 096 dans ce stage.
Le notebook d'évaluation est aussi réglé pour le stage 2, sur trois épisodes.

- Avant de modifier un agent principal, le code archive son ZIP et ses
  métadonnées exacts ; une nouvelle version est conservée après sa sauvegarde.
  Les paires déjà archivées sont dédupliquées par leurs empreintes SHA-256.
- Chaque dossier de version contient `agent.zip`, `agent_meta.json` et
  `manifest.json`. Le manifeste décrit le stage, le compteur, l'origine et les
  empreintes. Une archive altérée est refusée à la lecture. Les fonctions
  d'entraînement refusent d'écrire dans `models/versions/`.
- Les checkpoints périodiques conservent aussi l'identifiant de leur session
  dans leur nom, afin que deux reprises au même compteur ne s'écrasent pas.
  Ils restent séparés des versions principales pour limiter les duplications.
- Le modèle précédent et ses récompenses ne sont pas modifiés par un
  transfert. Le transfert est autorisé uniquement vers l'étape suivante avec
  un autre nom ; une cible existante est reprise après validation, jamais
  réinitialisée depuis sa source. Les espaces de contrôle et d'observation
  doivent rester compatibles.

Pour lancer le stage 2 : dans 02, conserver
`MODELE_NOM='ppo_vision_checkpoint_v3_stage2'`,
`ETAPE_APPRENTISSAGE=2`, puis activer l'entraînement et **Tout exécuter**.
Activer aussi la sauvegarde du checkpoint CSP si le jeu a redémarré, voiture
immobile au départ voulu. Le checkpoint physique reste en mémoire du jeu ;
restaurer un ancien agent ne restaure pas à lui seul un checkpoint CSP perdu.

Pour revenir à un ancien agent, ouvrir
**`03_Entrainement/05_Gerer_Stages_Agents.ipynb`**. Exécuter d'abord le notebook
avec `ACTIVER_OPERATION=False` pour afficher les versions. Copier la valeur
`source_selectionnable` de la version souhaitée dans `MODELE_SOURCE`, puis :

```python
ACTIVER_OPERATION = True
OPERATION = 'revenir_version'
MODELE_SOURCE = 'versions/.../agent'  # chemin exact donné par l'inventaire
NOM_MODELE_CIBLE = 'ppo_vision_checkpoint_v3_stage1_retour_01'
```

**Tout exécuter** crée une copie sous ce nouveau nom, avec le stage et le
compteur d'origine. Choisir ensuite ce nom et son stage dans les réglages du
notebook d'entraînement ou d'évaluation. Pour seulement évaluer une archive,
le notebook 04.01 accepte directement son chemin `versions/.../agent`.

Le gestionnaire permet aussi `archiver` et `transferer_stage`. Pour préparer
un futur stage 3, choisir la source stage 2, un nouveau nom de modèle et
`STAGE_CIBLE=3`. Les archives sont protégées par le code, sans suppression
automatique. **`models/` est ignoré par Git : un push ne sauvegarde pas les
agents ; copier ce dossier sur un autre support pour une sauvegarde externe.**

Validation : transfert et restauration testés dans un dossier temporaire,
écrasement et modification d'archives refusés, deux reprises et compteurs de
stage contrôlés, sauvegarde sur erreur vérifiée. Le vrai modèle stage 2 a été
chargé sous SB3 sans conduite ; le ZIP et les métadonnées du stage 1 sont
restés inchangés. Aucun entraînement réel du stage 2 n'a été lancé.

### Évaluer le modèle V3 sans apprentissage

`04_Evaluation/01_Evaluer_Modele.ipynb` utilise maintenant le même checkpoint
CSP, le même contrôle vJoy V3 et les mêmes observations que l'entraînement.
Une cellule **REGLAGES**, puis **Tout exécuter**, pilote toute la séquence.

- Par défaut, `ACTIVER_EVALUATION=False` et
  `ACTIVER_SAUVEGARDE_CHECKPOINT=False` : les fichiers et métadonnées sont
  vérifiés sans connexion au jeu.
- Pour un premier essai, mettre `N_EPISODES=3` et
  `ACTIVER_EVALUATION=True`. Si le jeu a redémarré, immobiliser la voiture
  au départ choisi et activer aussi `ACTIVER_SAUVEGARDE_CHECKPOINT=True`.
  Un checkpoint déjà valide est conservé.
- `MODELES_A_EVALUER` sélectionne un ou plusieurs ZIP, relatifs à
  `Code/models/`. Le modèle final est sélectionné par défaut. Pour le comparer
  à mi-parcours, décommenter par exemple
  `checkpoints/ppo_vision_checkpoint_v3_stage1_65792_steps` si cette sauvegarde
  existe. Tous les modèles doivent correspondre à la même voiture, au même
  circuit, au même schéma et à la même étape.
- Chaque épisode commence par une restauration vérifiée. Le pilotage utilise
  `deterministic=True`, sans mise à jour et sans coupure de lot PPO. Les
  fichiers de modèles et leurs métadonnées sont vérifiés par SHA-256 avant
  et après l'évaluation ; le compteur d'apprentissage doit rester identique.
- Le tableau final mesure réussite, sorties, collisions détectées,
  immobilisations, limites, progression, temps pour réussir, vitesse et
  mouvements du volant. Les erreurs techniques sont comptées séparément et
  arrêtent la série. Les résultats valides ont leur propre dénominateur.
- Les fichiers `episodes.csv`, `comparaison.csv`, `etat_session.json` et les
  journaux détaillés sont écrits dans `reports/evaluation_v3/<session>/`.
  Ils sont conservés aussi en cas d'interruption ou d'erreur ; un fichier
  `erreur.txt` explique alors l'arrêt.

Ne pas lancer un entraînement ou un autre client de télémétrie en parallèle.
Garder le jeu visible pour la caméra. Utiliser **Interrompre le noyau** pour
arrêter la conduite. Répéter un départ fixe avec une politique déterministe
peut reproduire le même scénario : ce test mesure la répétabilité de cet
exercice, pas la généralisation à des circuits inconnus.

Validation du 17 novembre 2026 : notebook entier exécuté en mode désactivé,
modèle réel à 131 328 actions chargé et prédictions déterministes vérifiées,
comparaison de deux modèles avec capteurs factices, métriques et exports
contrôlés, erreurs caméra/reset simulées et nettoyage UDP/vJoy après erreur
de frein testé. Aucun essai de conduite réel n'a été lancé pour cette mise
à jour.

### Continuer le PPO après le premier essai

La cellule **REGLAGES** des notebooks 02 et 03 expose désormais
`PENALITE_SORTIE_PISTE = 100.0` : ce montant positif est soustrait à la
récompense lors d'une sortie détectée, contre 15 auparavant à l'étape 1
(25 aux étapes suivantes). L'épisode se termine toujours dès la détection.
Un objectif de distance ou un tour franchi en sortant de piste ou en collision
ne reçoit plus son bonus de réussite. Le montant appliqué est enregistré dans
les journaux et la configuration dans les métadonnées du modèle. La détection
reste celle du prototype : plus de deux pneus hors piste ou centre de la
voiture au-delà des limites géométriques. Tester l'effet sur une session courte
avant une nuit entière ; le nouveau réglage s'applique à la prochaine création
de l'environnement, pas à un entraînement déjà en cours.

Les notebooks `03_Entrainement/02_Entrainement_PPO_Assetto.ipynb` et
`03_Entrainement/03_Reprendre_PPO.ipynb` utilisent maintenant le même
environnement avec restauration du checkpoint CSP. Le notebook 03 exige un
modèle existant ; le notebook 02 peut aussi créer un nouveau modèle.

- `REPRENDRE_MODELE_EXISTANT=True` charge le ZIP et conserve les poids,
  l'optimiseur et le compteur. La session, le schéma de contrôle et l'étape
  doivent correspondre aux métadonnées. Choisir un autre `MODELE_NOM` pour
  recommencer : le modèle existant n'est pas écrasé par une nouvelle politique.
- `TOTAL_TIMESTEPS=4096` représente des actions **supplémentaires**. Pour le
  modèle actuel à 256 actions, la fin normale atteint 4 352 actions cumulées.
- Une copie du modèle et de ses métadonnées est conservée dans
  `models/checkpoints/` avant chaque reprise. Des sauvegardes périodiques y
  sont aussi écrites entre les lots, après les mises à jour. Une interruption
  clavier produit une sauvegarde séparée avec le suffixe `_interrupted_...`.
- Le dernier pas de chaque lot PPO termine l'épisode par une troncature
  explicite, sans pénalité d'échec supplémentaire. Le véhicule reste freiné
  pendant le calcul. Après la mise à jour, le checkpoint est restauré et
  l'observation de départ est renouvelée. Aucun épisode ne traverse le calcul
  des mises à jour ; un reset vide supplémentaire de VecEnv peut créer des
  sauts de numéros d'épisodes.
- Les journaux de chaque session ont leur propre sous-dossier dans
  `reports/ppo_checkpoint_v3_stage1/`. Le tableau final sélectionne le journal
  le plus récent et indique les `coupure PPO` pour distinguer ces troncatures.

**Séquencement automatique :** recharger le notebook depuis le disque. La
première cellule de code, **REGLAGES**, est maintenant le seul endroit où
modifier les interrupteurs et les paramètres. Aucune autre cellule ne change
leur valeur. Cliquer ensuite sur **Tout exécuter** : les définitions sont
chargées, puis une seule séquence vérifie la session, sauvegarde si demandé
et lance l'entraînement si activé.

| Sauvegarde checkpoint | Entraînement | Résultat |
|---|---|---|
| `False` | `False` | Charge les définitions sans connexion au jeu |
| `True` | `False` | Crée le checkpoint manquant, voiture immobile, sans conduite |
| `True` | `True` | Crée le checkpoint manquant puis entraîne ; conserve un checkpoint déjà valide |
| `False` | `True` | Entraîne avec le checkpoint existant ; explique le réglage à changer s'il manque |

Après un redémarrage du jeu, immobiliser la voiture au départ choisi et mettre
les deux interrupteurs à `True` pour sauvegarder puis entraîner. Pour les
sessions suivantes, seule l'activation de l'entraînement est nécessaire.
Une fois les définitions chargées, on peut aussi réexécuter **REGLAGES**, puis
uniquement **EXECUTER LA SEQUENCE**. Les deux restent des cellules séparées.
Modifier un booléen pendant un calcul ne l'arrête pas : utiliser **Interrompre
le noyau** pour interrompre un entraînement en cours.

Ne pas ouvrir deux connexions de télémétrie en parallèle. Le message attendu
est `REPRISE du modele, compteur initial: 256` pour la première continuation
du modèle actuel. Les cas désactivé, sauvegarde seule, sauvegarde suivie de
l'entraînement, checkpoint existant, checkpoint absent et voiture en mouvement
ont été vérifiés avec des dépendances factices. L'exécution complète avec
les interrupteurs désactivés a aussi été vérifiée sous Python 3.9.

Validation hors simulateur avec Python 3.9 / Stable-Baselines3 2.3.2 : modèle
réel chargé à 256 actions, métadonnées incompatibles refusées, entraînement
court sur environnement factice avec trois lots et resets après calcul,
sauvegardes et reprise du compteur de 12 à 20, puis test du vrai `step()`
avec des capteurs factices. Aucun nouvel entraînement dans Assetto Corsa
n'a été lancé pendant cette modification. Le mécanisme utilise les événements
de [callback SB3](https://stable-baselines3.readthedocs.io/en/master/guide/callbacks.html)
et renouvelle les observations internes de PPO ; le test d'intégration est à
refaire en cas de changement de version de SB3.

### Installation et premiers tests

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
