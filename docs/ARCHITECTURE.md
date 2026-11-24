# Architecture

Le namespace privé `local _, A = ...` est partagé entre modules via le TOC. `Core.lua` fournit initialisation, événements et protections. Les données sont chargées avant les modules. Pas de global supplémentaire hors panneau nommé, slash commands et SavedVariable.

- `Data/Alphabet.lua` : 33 entrées [maj, min, translittération, note].
- `Data/Vocabulary.lua` : entrées [russe, français, catégorie, note], fiches, petit fallback.
- `Cyrillic.lua` : parcours UTF-8, normalisation cyrillique/accent, glossaire, formes fléchies explicites, couleurs. Pas d'analyse phonologique exacte.
- `Learning.lua` : identité carte russe normalisé + séparateur + français, observation dédupliquée 30 s, limite 5000, score, échéance. Les lettres ont leur propre espace. Les traductions synonymes peuvent produire plusieurs cartes intentionnellement. Le choix QCM mélange des distracteurs du même mode.
- `Translations.lua` : adaptateur FRS v3, getters synchrones, fallback local minimal, zone via résolution FRS. QuestText lit des champs texte candidats ; les objectifs structurés et substitutions ne sont pas rendus dans cette version. Ne pas modifier les tables du fournisseur.
- `Audio.lua` : `C_VoiceChat.GetTtsVoices` et `SpeakText` moderne, lecture locale seulement. Pas de voix distante.
- `Context.lua` : contexte courant, épinglage, glossaire des mots reconnus.
- `UI.lua` : six onglets, construction à la demande, panneau non protégé.
- `Integration.lua` : événements, tooltip post-calls, slash commands, option de révision taxi. Les callbacks de données dynamiques sont protégés par pcall, ignorés en combat et filtrent les valeurs secrètes connues. Ce n'est pas une preuve d'absence de taint : tester en jeu.

## SavedVariables schema 1

`settings`: booléens par module, voiceID optionnel. `cards`: map de fiches (ru, fr, category, source, seen, lastSeen, due, streak, reviews, errors, lastReview). `letters`: map de scores par majuscule. `stats`: day UTC, today, total. `missing`: set d'identifiants, sans contenu du chat. `seeded`: initialisation du lexique.

Les notes grammaticales sont statiques ; le moteur ne déduit pas de déclinaison inconnue. Pour les extensions de données, privilégier un fichier source JSON/TSV avec validation Python puis génération Lua déterministe, hors jeu. Les données FRS doivent rester externes au repo.
