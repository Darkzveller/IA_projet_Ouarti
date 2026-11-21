# OUARTI — bilan de la nuit du 17 novembre 2026

La session `20261117_010334_8a162d81` a atteint sa limite normale. Elle a ajouté **131 072 actions** au modèle initial de 256 actions : le modèle sauvegardé compte **131 328 actions**. Les mesures vont de **2026-11-17T01:03:36.165020+01:00** à **2026-11-17T08:15:51.648627+01:00**, soit **7 h 12 min environ**. Ce rapport n'a lancé aucune commande au véhicule ni entraînement.

## Résultats vérifiés

Les 131 072 lignes du journal correspondent exactement à la somme des longueurs des 6 063 épisodes de `monitor.csv`. Les récompenses cumulées concordent à 0,00004 près. Le modèle et ses métadonnées ont été sauvegardés à la fin de la session. L’intégrité ZIP du modèle a été vérifiée et son compteur interne confirme les 131 328 actions. Les anciennes sorties intégrées au notebook sont décalées par rapport à ces fichiers : elles ne décrivent pas toute la nuit.

- Objectif de 10 m atteint : **4 551 épisodes (75,1 %)**.
- Sortie de piste détectée : **514 épisodes (8,5 %)**.
- Coupure explicite à la fin d'un lot PPO : **946 épisodes (15,6 %)**, à distinguer d'un échec.
- Immobilisation : **53 épisodes (0,9 %)**. Les causes peuvent se chevaucher.
- Aucune collision signalée ; cela ne valide pas le détecteur de collision.
- Écart image/télémétrie moyen : **44 ms** ; 99 % des paires sous **86 ms** ; maximum **317 ms**.
- Aucune commande gaz/frein simultanée. Direction à plus de 95 % : **36,4 % des actions**.
- Vitesse moyenne pendant les actions : **10,6 km/h** ; maximum : **37,6 km/h**.

| Mesure | 500 premiers épisodes | 500 derniers épisodes |
|---|---:|---:|
| Objectif atteint | 72.8 % | 77.6 % |
| Sortie de piste | 6.2 % | 5.2 % |
| Récompense moyenne | 30.24 | 33.31 |
| Actions médianes pour réussir | 25 | 21 |
| Durée médiane mesurée pour réussir | 3.67 s | 3.18 s |

Ces nombres proviennent d'une politique qui explore pendant l'apprentissage. Ils ne mesurent pas une conduite déterministe du modèle final. Les 10 tranches de la nuit oscillent entre environ 69 % et 77 % de réussite ; il n'y a pas une amélioration régulière pendant sept heures. L'étape courte apprend surtout à démarrer et accélérer depuis ce départ, pas à tenir un circuit.

## Conclusion

La boucle de collecte, retour au checkpoint, apprentissage et sauvegarde a fonctionné pendant une nuit entière. Le pilote a appris un comportement utile sur un exercice court : atteindre 10 m plus vite et avec une réussite légèrement meilleure. Les commandes exploratoires de direction restent fréquemment en butée ; le comportement déterministe reste à mesurer. La maîtrise de virages, freinages ou circuits inconnus n'est pas démontrée. Continuer exactement le même exercice pendant plusieurs nuits ne constitue pas la meilleure prochaine étape.

## Directions prioritaires

1. **Évaluer sans apprendre.** Adapter d'abord `04_Evaluation/01_Evaluer_Modele.ipynb`, encore configuré pour l'ancien `ppo_vision_telemetrie` et un ancien schéma/reset. Tester le modèle V3 final et un checkpoint intermédiaire sur 30 à 50 épisodes au même départ, avec `deterministic=True`, sans mise à jour. Exiger par exemple 90 à 95 % de réussite et moins de 5 % de sorties avant de valider l'étape. Un même départ déterministe peut répéter exactement le même scénario ; compléter ensuite avec de petites variations contrôlées.
2. **Mesurer et rendre le contrôle plus fin.** Journaliser position, orientation, écart latéral et distance réelle, valider les signaux de collision et de boîte. Remplacer la projection au point central le plus proche par une projection continue sur les segments : la progression actuelle arrive par paliers d'environ 1,54 m. Examiner les changements de direction et les actions en butée avant d'ajouter une petite pénalité de variation ou une commande longitudinale signée ; changer les espaces d'action nécessite une migration ou un nouveau modèle, pas une reprise aveugle.
3. **Allonger le curriculum.** Réutiliser les poids dans un nouveau modèle d'étape 2 avec transfert explicite et métadonnées adaptées : 30 m, puis 100 m. La validation de reprise actuelle refuse à juste titre de changer simplement `curriculum_stage`. Ajouter plusieurs départs, un virage doux, puis du freinage. Comparer chaque nouvel exercice avec le précédent.
4. **Revenir à l'architecture OUARTI.** Le système actuel est une seule politique PPO avec CNN et télémétrie. Il ne constitue pas encore les trois agents perception/trajectoire/pilotage. Construire et vérifier la génération de masques avant U-Net, puis introduire une politique de trajectoire avec le pilote stabilisé. La conduite peut rester sans imitation ; la segmentation sémantique demande des cibles, éventuellement générées automatiquement.
5. **Fiabiliser l'exploitation longue durée.** Vérifier les correctifs caméra installés, les reprises après erreur et la sélection du checkpoint à charger, puis enregistrer début/fin et motif d'arrêt dans un état de session. La sauvegarde principale est correcte cette nuit ; les protections supplémentaires annoncées lors de la correction précédente ne doivent pas être supposées présentes sans vérifier le code.

## Sources locales

- Métadonnées : `Code\models\ppo_vision_checkpoint_v3_stage1_meta.json`.
- Journal : `C:\Users\elkat\Documents\Github\IA_projet_Ouarti_ds_github\Code\reports\ppo_checkpoint_v3_stage1\20261117_010334_8a162d81\ppo_steps.jsonl`.
- Monitor : `C:\Users\elkat\Documents\Github\IA_projet_Ouarti_ds_github\Code\reports\ppo_checkpoint_v3_stage1\20261117_010334_8a162d81\monitor.csv`.
- TensorBoard de cette session : 1 024 lots enregistrés, vitesse finale 5 actions/s, écart type d'exploration final environ 0,94. Les valeurs du critique fluctuent ; elles ne suffisent pas à noter le pilotage.
- `episodes.csv`, `evolution_par_250_episodes.csv`, `synthese.json` et `bilan_nuit.png` accompagnent ce rapport.
