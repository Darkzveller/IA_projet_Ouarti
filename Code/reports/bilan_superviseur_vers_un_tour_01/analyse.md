# OUARTI — analyse de la campagne vers_un_tour_01

Campagne exécutée le 17 novembre 2026 ; analyse du 18 novembre 2026.

## Conclusion

Le superviseur a fonctionné pendant **1 h 24**, de **11 h 41 à 13 h 05**, et s'est arrêté conformément à la règle de **quatre cycles sans progrès** à la leçon de 100 m. Il n'a pas atteint son budget de huit heures et ne s'est pas arrêté sur une panne de caméra. **Les 30 m sont validés, les 100 m ne le sont pas, aucun tour complet n'a été effectué.**

## Données contrôlées

- Six entraînements de 4 096 actions : **24 576 actions collectées** au total.
- Huit évaluations de dix épisodes : **80 épisodes valides et zéro erreur technique**.
- Cohérence entre les longueurs des épisodes et les journaux détaillés vérifiée pour chaque entraînement et chaque évaluation.
- Intégrité des modèles pendant les évaluations confirmée dans les rapports.
- Écart caméra/télémétrie maximal : environ **101 ms**. Écart maximal au départ après reset : environ **1,5 mm**.

| Leçon / agent | Réussite | Progression moyenne | Vitesse maximale | Décision |
|---|---:|---:|---:|---|
| 30 m, référence | 0/10 | 17,75 m | 42,8 km/h | référence initiale |
| 30 m, candidat 1 | 10/10 | 31,31 m | 59,3 km/h | conservé |
| 30 m, candidat 2 | 10/10 | 31,46 m | 59,6 km/h | non retenu, gain insuffisant |
| 100 m, référence | 0/10 | 94,64 m | 95,3 km/h | meilleur repli |
| 100 m, candidat 3 | 0/10 | 39,44 m | 56,7 km/h | rejeté |
| 100 m, candidat 4 | 0/10 | 79,71 m | 82,6 km/h | rejeté |
| 100 m, candidat 5 | 0/10 | 92,78 m | 94,7 km/h | rejeté |
| 100 m, candidat 6 | 0/10 | 33,77 m | 53,4 km/h | rejeté |

Le candidat 1 réussit les 30 m en moyenne en **4,58 s**. Le candidat 2 n'améliore pas ce temps (4,60 s) et se trouve plus loin du centre en fin d'exercice ; le superviseur a conservé le candidat 1. Le meilleur repli 100 m est une copie exacte des poids de ce champion 30 m : il ne faut donc pas le présenter comme un agent ayant validé les 100 m.

## Blocage de pilotage observé

La référence 100 m envoie **100 % de gaz et aucun frein sur toutes les actions évaluées**. Elle atteint environ 95 km/h avant de franchir les limites géométriques vers 94–95 m. Les quatre nouveaux candidats franchissent aussi les limites lors des dix essais chacun. Les cinquante sorties de la leçon 100 m sont cohérentes avec l'écart latéral supérieur à la demi-largeur du CSV. Une vérification visuelle du calage du CSV reste utile avant de considérer cette géométrie comme une vérité absolue.

Le volant n'est plus en butée en évaluation, mais cela ne suffit pas à démontrer un bon pilotage : les petites corrections ne maintiennent pas toujours la trajectoire dans la piste. Les candidats 3 et 4 commencent à freiner, mais cela ne résout pas le problème de trajectoire. L'entraînement conserve une forte exploration : environ 31 à 34 % des commandes de volant sont proches de la butée dans les cycles 100 m. Un épisode d'entraînement du candidat 5 atteint l'objectif ; ce comportement n'est pas reproduit par sa politique déterministe.

Ces observations soutiennent l'hypothèse d'un manque de maîtrise de la trajectoire et de la vitesse sur une distance plus longue ; elles ne prouvent pas à elles seules la cause interne du réseau, ni que le CNN ignore les images.

## Limite du superviseur révélée par cette campagne

Les quatre candidats 100 m ont tous un compteur final de **143 616**, car ils repartent chacun du même agent à **139 520** et ajoutent seulement 4 096 actions. Ce ne sont pas 16 384 actions successives accumulées par un même candidat. Le retour systématique au champion protège les acquis, mais peut empêcher une adaptation qui demande plusieurs lots avant de redevenir meilleure. Cette règle conservatrice a correctement rejeté les régressions tout en limitant l'exploration cumulative.

## Suite recommandée

1. **Conserver les champions et les archives actuels.** Le stage 1 et l'agent validé sur 30 m constituent les références de retour.
2. **Introduire 50/60 m puis 80 m avant les 100 m**, dans une nouvelle campagne, au lieu de diminuer l'exigence pour déclarer artificiellement les 100 m réussis.
3. **Distinguer champion et candidat en apprentissage continu.** Laisser une branche candidate apprendre pendant deux à quatre cycles, avec évaluation à chaque cycle et sauvegardes, sans remplacer le champion tant qu'elle ne le dépasse pas. Le nombre exact de cycles reste à expérimenter.
4. **Tester une exploration et un pas d'apprentissage plus faibles dans une branche séparée.** La fréquence des commandes extrêmes pendant l'entraînement justifie cette expérience, mais ne démontre pas qu'un réglage particulier suffira.
5. **Donner un signal progressif sur la marge à la piste**, en conservant la progression comme récompense principale. Ajouter éventuellement un curriculum de vitesse, documenté comme tel. Augmenter encore la seule pénalité finale de sortie n'apparaît pas comme la première action à tenter.
6. Revalider les paliers, puis reprendre 100, 300, 1000 m et le tour complet. Aucune modification des critères, des agents ou du code de conduite n'a été faite pendant cette analyse.

## Fichiers produits

`comparaison_agents.csv`, `entrainements.csv`, `episodes_evaluation.csv`, `synthese.json` et `bilan_campagne.png` accompagnent ce rapport. Les sources sont les événements et l'état de la campagne, les huit dossiers d'évaluation et les six journaux d'entraînement qu'ils référencent.
