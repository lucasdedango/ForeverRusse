# Instructions pour Codex / agents de développement

## Objectif
Créer un compagnon d'apprentissage du russe, discret et contextuel pour WoW Forever officiel, client français. Favoriser le vocabulaire réutilisable dans la vie quotidienne, le cyrillique et les répétitions naturelles. Interface française, contenu russe avec accents quand connus.

## Contraintes non négociables
- Cible Forever `16001`, game type `camelot`, API moderne. Ne pas déduire les APIs à partir du seul numéro d'interface ni utiliser les API Classic Era par défaut.
- Lua 5.1 compatible ; pas de dépendances réseau, pas d'automatisation du gameplay, pas de chat envoyé automatiquement, pas d'injection client ni de contournement des restrictions/secret values. Ne jamais lire ou traiter de valeurs secrètes pour obtenir un avantage.
- FRS API v3 optionnelle, `ForeverRosettaStoneDB` avec locale explicite. Ne pas modifier les records partagés, ni changer le réglage FRS sans consentement. Ne pas embarquer de catalogues tiers sans vérification de licence. Garder le mode autonome.
- Utiliser les données par ID, pas des suppositions de traduction. Distinguer textes de jeu, glossaire pédagogique et traductions IA. Ne jamais inventer une traduction manquante. Les analyses morphologiques doivent être validées ou signalées approximatives.
- Ne pas remplacer des frames protégées ou UI Blizzard. Ajouter des panneaux ou lignes propres, hors combat. Respecter la compatibilité avec les autres addons. Pas de boucle rapide ni de scan massif en combat.
- Préserver la SavedVariable `ForeverRusseDB` et les données utilisateur. Toute migration doit être testée et non destructive. UTF-8 sans BOM, accents combinants gérés, pas de `string.sub` sur une lettre russe sans découpage UTF-8.
- Aucun secret, token, dossier WTF ou identifiant de compte dans le repo.

## Workflow
1. Lire README et docs/ARCHITECTURE.md ; vérifier la documentation FRS et le code source UI branche `forever` avant changement d'API.
2. Modifier les modules ciblés, ajouter les tests dans tests/run.lua ou un nouveau fichier intégré à CI.
3. Exécuter `find ForeverRusse -name '*.lua' -print0 | xargs -0 -n1 luac5.1 -p` et `lua5.1 tests/run.lua` ; indiquer si indisponible. Ne jamais prétendre avoir testé le client réel si ce n'est pas le cas.
4. Mettre à jour README / ROADMAP / CHANGELOG et TOC si nouveau fichier, construire `python scripts/package.py`.
5. Pour chaque PR : expliquer changements, API confirmées, hypothèses, limites, étapes manuelles. Réserver les grandes refontes pour une PR séparée.
