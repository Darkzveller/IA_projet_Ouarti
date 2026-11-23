# OUARTI — Tester les trois agents dans l’ordre

Ouvrir `00_Poste_de_guidage.ipynb` avec le noyau Python 3.9 du projet. Choisir un seul `MODE` dans **RÉGLAGES** et cliquer sur **Tout exécuter**. Le mode initial `inventaire` liste les versions locales. Un noyau neuf permet de vérifier les dépendances de chaque essai.

Pour un premier passage automatique, choisir **`MODE='recette_hors_jeu'`**. Le poste teste la perception, la trajectoire, l’afficheur à deux agents, puis le pilote et l’intégration des trois. Il s’arrête sur le premier test en échec et conserve les versions des étapes réussies. Le résultat donne les trois identifiants à reporter dans les réglages. Les étapes ci-dessous permettent ensuite de reproduire un essai isolé ou de passer aux captures du simulateur.

## Ce que consomme et produit chaque agent

| Agent | Entrée | Sortie utilisable séparément |
|---|---|---|
| 1 · Perception | Image caméra grise ou BGR, ramenée à 128 × 96 en gris | Masque à sept classes et probabilité de piste pour chaque pixel |
| 2 · Trajectoire | Probabilité de piste, vitesse en m/s, vitesse de lacet en rad/s | Sept points en coordonnées image normalisées, du plus proche au plus éloigné, et vitesse cible indicative en km/h |
| 3 · Pilote optionnel | Abscisses du plan, vitesse cible, vitesse et lacet mesurés | Volant et demande longitudinale, convertie en accélérateur ou frein |

L’agent 2 apprend sur des corridors générés avec un coût de lissage, de marge et d’entrée en courbe. La vitesse cible est initialisée par une règle de prudence apprise sur ces scènes. L’efficacité au chronomètre et l’adhérence disponible doivent encore être mesurées dans Assetto Corsa. Les points sont exprimés dans l’image de la caméra. Conserver la même vue et le même cadrage pendant la recette.

## 1. Valider la perception seule

1. Choisir `tester_a1`. Le carnet entraîne un petit U-Net sur des images synthétiques et mesure l’intersection sur union (IoU) par classe sur 48 autres images. Un score de 1 indique un recouvrement parfait. Le test exige au moins 0,75 pour la piste et 0,35 pour les obstacles synthétiques. Reporter la `version_a1` affichée dans `VERSION_A1`.
2. Pour passer aux images du jeu, utiliser le carnet existant `02_Donnees/04_Capturer_Images.ipynb`. Enregistrer deux sessions distinctes, dont une réservée à la validation. Garder le jeu au premier plan et vérifier visuellement les PNG. Inclure des lignes droites, des virages, des bords et des obstacles visibles. L’outil de capture enregistre les pixels visibles à l’écran.
3. Renseigner `SESSION_TRAIN` et `SESSION_VALIDATION`, puis utiliser successivement `annoter_train` et `annoter_validation`. Dans la fenêtre OpenCV, choisir une classe de 0 à 6, cliquer sur les sommets d’un polygone, puis **Entrée** pour le remplir. **u** retire le dernier sommet, **s** enregistre, **n** passe à l’image suivante et **Échap** termine. Les identifiants sont 0 fond, 1 piste, 2 vibreur, 3 herbe, 4 gravier, 5 mur, 6 véhicule ou obstacle. Les pixels ignorés valent 255. Annoter aussi les zones interdites et, pour tester une ligne en entier, couvrir le passage visible devant la voiture.
4. Choisir `entrainer_a1_reel`. Reporter sa nouvelle version dans `VERSION_A1`. Examiner les IoU réelles **par classe**, le nombre d’images et la diversité des scènes. L’entrée en mode direct exige une IoU piste d’au moins 0,75 sur la session réservée. Une classe absente de la validation reste à tester.

## 2. Valider la trajectoire, puis l’afficheur pour le pilote humain

1. Choisir `tester_a2` dans un noyau neuf. L’agent 2 reçoit des masques de référence indépendants de l’agent 1. Vérifier que les points vont à gauche puis à droite dans les virages correspondants, que la cible est plus basse en virage et que le modèle refuse une carte invalide ou un passage coupé. Reporter `version_a2` dans `VERSION_A2`.
2. Choisir `tester_chaine`, puis `demo_hud`, avec les deux versions synthétiques. Le premier compte les plans disponibles sur 40 scènes. Le second montre l’image et la ligne effectivement produite. Ces deux modes fonctionnent avec le carnet du pilote et celui de vJoy retirés.
3. Sélectionner la version A1 entraînée sur le jeu et choisir `evaluer_a2_reel`. Pour chaque capture annotée, le carnet retrouve la télémétrie correspondante et compare **la ligne entière** au masque humain indépendant. Examiner `hors_masque`, `annotation_incomplete`, `desynchronise` et `indisponible`. Pour une première recette, viser zéro franchissement et au moins 90 % de lignes entièrement vérifiées sur 30 images couvrant les deux sens de virage. Ce sont des critères proposés pour la campagne, à confronter à la conduite réelle.
4. Choisir `hud_direct` avec le jeu au premier plan et le plugin en vJoy local. `AFFICHAGE='notebook'` permet un contrôle sur un second écran. `AFFICHAGE='superposition'` dessine la ligne dans une fenêtre transparente au-dessus du jeu en mode fenêtré sans bordure. Cette fenêtre laisse passer les clics et demande à Windows de l’exclure de la capture pour éviter que l’agent voie sa propre ligne. Si Windows refuse l’exclusion, utiliser l’affichage notebook. Vérifier l’alignement, l’actualisation en virage et la disparition du guidage lorsque la capture est interrompue. Le conducteur conserve le volant et les pédales. Arrêter les autres carnets connectés au plugin avant cet essai.

## 3. Tester le pilote en dernier

1. Choisir `tester_a3` dans un noyau neuf. Un plan de référence alimente le PPO sur un petit banc cinématique. Le test entraîne 512 pas, sauvegarde et recharge les poids, puis mesure l’écart de suivi sur trois épisodes. Il vérifie aussi que gaz et frein sont exclusifs. Reporter sa `version_a3` pour réutiliser ce pilote dans le test d’intégration.
2. Choisir `tester_integration` avec les deux versions synthétiques. Les trois agents fonctionnent ensemble avec un simulateur en mémoire. L’essai compare l’entrée du pilote au plan affichable, contrôle la conversion de sa commande et simule une perte de piste pour vérifier le frein et la fin d’épisode.
3. Après la recette de l’afficheur en conduite humaine, préparer un checkpoint CSP à l’arrêt avec le carnet 02 historique, sauvegarde activée et entraînement désactivé. Revenir au poste avec les versions réelles A1/A2, `STAGE=1` et `MODE='entrainer_a3'`. Le PPO utilise uniquement le suivi du plan et les récompenses du simulateur. Un nouveau pilote démarre avec `VERSION_A3=''`. Le frein de surveillance et le reset vérifié sont ceux du prototype CSP. Le mode entraîne dès l’exécution de la dernière cellule.
4. Choisir la version A3 affichée, puis `evaluer_a3`. Ce mode effectue des épisodes déterministes. Examiner progression, sorties, collisions, pertes de guidage et écart de suivi dans les rapports. Proposition de passage au palier suivant : deux séries de dix épisodes avec au moins neuf réussites et aucune sortie ni collision. Les paliers existants sont 10 m, 30 m, 100 m et tour complet. Le tour exige une progression cumulée d’au moins la longueur du circuit, un franchissement de ligne et un tour valide. Le superviseur historique 06 reste celui du pilote monolithique.

## Reproduire une version

Chaque entraînement crée un nouveau dossier sous `Code/models/trois_agents/<agent>/<version>`. Le manifeste conserve le contrat et l’empreinte SHA-256. Les versions du pilote mémorisent les deux modèles de guidage utilisés, le stage et le compteur PPO. Pour revenir en arrière, remettre les identifiants exacts dans les réglages. Les rapports JSON se trouvent sous `Code/reports/trois_agents/`. Poids, images et rapports sont locaux. Sauvegarder ces dossiers séparément pour pouvoir les restaurer sur un autre PC.

## Première exécution du 18 novembre 2026

Sur 48 images synthétiques réservées, l’IoU atteint 0,965 pour la piste et 0,787 pour les obstacles. Sur 40 autres scènes, le guidage a affiché 27 lignes intégralement contenues dans le masque de référence et s’est abstenu 13 fois. Le pilote de banc a effectué 512 pas d’apprentissage puis trois épisodes déterministes avec zéro sortie. La perte de piste injectée dans la chaîne complète a déclenché le frein simulé. Les essais sur captures de piste annotées, l’alignement de la superposition en jeu et le temps au tour constituent les prochains contrôles.

## Avancement et essais réels du 23/11/2026

En vue capot sur Imola (`capot_abarth500_v1`, Abarth 500, caméra `bgr 640×360`), la chaîne complète a été testée en jeu : l'Agent 1 (`20261123_064246_bb00ca1e`, U-Net 3 niveaux `256×144` sur GPU) atteint `93,46 %` d'IoU piste sur `100` images d'un second tour indépendant (`75,8 FPS` pour `A1 + A2`) ; l'Agent 2 (`20261123_064311_1622081c`, trajectoire monotone v6) obtient `460/460` (`0` franchissement) sur les quatre sessions annotées ; le mode `sauvegarder_checkpoint` a été ajouté directement dans `00_Poste_de_guidage.ipynb` et l'Agent 3 PPO (`20261123_191455_9f12c152`, `31 744` pas) a validé les paliers `10 m` (`10/10`), `30 m` (`10/10`), `100 m` (`10/10`) puis `3/3` tours complets (`4 906 m`, `0` sortie, `0` collision, écart moyen `4,0 %`). Limites restantes au 23/11/2026 : perception encore difficile des virages au loin sur le HUD, vitesse bridée à `50 km/h` (`~15 km/h` dans certains virages), légers zigzags en ligne droite, trajectoire prudente « milieu → corde », et validation à étendre sur `10` tours ainsi que sur d'autres circuits.
