# Validation

## Hors jeu

Depuis la racine :

```sh
find ForeverRusse -name '*.lua' -print0 | xargs -0 -n1 luac5.1 -p
lua5.1 tests/run.lua
python3 scripts/package.py
```

Le test charge les fichiers du TOC avec un namespace simulé. Il couvre alphabet, UTF-8, glossaire, déduplication, échéances, QCM, données FRS simulées, épinglage et appel TTS simulé. Ce n'est pas un émulateur du client ; les frames, tooltips et événements réels sont à vérifier manuellement.

## Résultat de validation initial

Le 24 novembre 2026, les fichiers du TOC ont été chargés et le test exécuté avec la bibliothèque Lua 5.4 disponible dans l’environnement de création : **31 assertions réussies**, vérifications additionnelles et 123 cartes de départ. Lua 5.1 et le vrai client WoW n’étaient pas disponibles localement ; la CI est configurée pour tester Lua 5.1 au premier push.

## Checklist en jeu (à réaliser)

- Ouvrir `/fru fonttest` et vérifier les 33 lettres dans les deux casses, les accents français et les accents toniques. Basculer la coloration dans Options et vérifier que l’accent suit sa lettre. Contrôler aussi les boutons d’alphabet au survol, le texte russe d’une quête, la saisie et les résultats du lexique, puis les réponses de révision avant et après désactivation.
- Survoler un équipement traduit et ouvrir la comparaison avec Maj. Vérifier le bloc russe doré sous le titre de l’objet principal et de chaque objet équipé, la couleur de rareté du titre français, la lecture grise facultative et les écarts de statistiques. Refaire en position basse et vérifier que le bloc suit les écarts de statistiques. Alterner entre objets traduits et non traduits, rouvrir la même infobulle et tester avec FRS en mode normal puis API only.

1. Activer `/console scriptErrors 1`, installer sans FRS, `/reload`, `/fru debug`, ouvrir chaque onglet. Vérifier lettres russes visibles et panneau déplaçable.
2. Cliquer une lettre, lancer un QCM, répondre juste/faux, changer de mode. Faire `/reload` et vérifier la persistance. Ajouter `/fru add лес ; forêt` ; chercher dans le lexique.
3. Survoler pierre de foyer et sort du mage si disponibles : FR intact, RU ajouté, pas de doublon. Tester en combat (aucune tentative de traduction dynamique attendue).
4. Installer FRS + packs, confirmer API v3 via `/fru debug`, activer `/frs api on` si souhaité, `/reload`. Survoler une variété d'objets et sorts, cibler un PNJ, changer de zone. Tester les réglages individuels.
5. Ouvrir une quête, puis `/fru context` ; comparer au texte russe FRS. Essayer `/fru quest ID`. Tester l'épinglage, le masquage FR, le scroll, les accents et les mots reconnus.
6. `/fru voices`, choisir une voix réellement russe, écouter « Привет! ». Vérifier que rien n'est envoyé au chat. Désactiver audio et vérifier le comportement.
7. Activer la révision en taxi, prendre un maître de vol ; vérifier ouverture unique, puis désactiver. Vérifier pas d'ouverture automatique par défaut.
8. Tester avec une UI personnalisée, sur petits écrans, et vérifier les erreurs via `/fru debug`. Signaler tout blocage d'action ou taint. Pour une issue, joindre version, build, étape, comportement attendu et erreur sans informations privées.

Les tests client ci-dessus ne sont pas déclarés réussis dans cette version.
