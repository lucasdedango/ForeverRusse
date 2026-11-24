# ForeverRusse — Русский в Азероте

Addon expérimental pour apprendre le russe en jouant à World of Warcraft: Forever avec un client français. Version **0.1.0**, interface `16001`. Le projet est indépendant de Blizzard. Aucun réseau, aucune action de gameplay automatisée, aucun compte externe nécessaire.

## Installation rapide (Windows)

1. Décompresser le ZIP projet. Copier **uniquement** le sous-dossier `ForeverRusse` contenant directement `ForeverRusse.toc`, `Core.lua`, `Data/` et `Modules/` dans `World of Warcraft/_forever_/Interface/AddOns/`. Si l'installation utilise un autre dossier (p. ex. ancien `_classic_beta_`), choisir celui réellement utilisé par Forever. Ne pas copier le dossier racine du projet entier dans AddOns.
2. (Fortement recommandé) Installer [Forever Rosetta Stone](https://github.com/rphlmr/forever-rosetta-stone/releases) avec ses packs de données et l'activer dans la liste des addons. Le moteur utilise son API publique **v3** en `ruRU` et `frFR`. Pas besoin de mettre le client en russe.
3. Facultatif : pour éviter les doublons d'infobulles, taper `/frs api on`, puis `/reload`. Cela désactive l'interface FRS pour toute la session/compte selon son mode ; revenir en arrière avec `/frs api off` puis `/reload`. ForeverRusse ne modifie pas ce réglage lui-même.
4. Activer ForeverRusse sur l'écran de sélection des personnages. En jeu, `/fru` ouvre la fenêtre.
5. Taper `/fru debug` pour vérifier l'interface, la locale et la présence de FRS v3. Sans FRS, l'alphabet, les exercices, le dictionnaire et quelques noms de sorts/objets restent disponibles.

Autre méthode : utiliser le ZIP d'installation généré par `python scripts/package.py` ou la commande PowerShell `./scripts/deploy.ps1 -AddOnsPath 'C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns'` depuis le dépôt (adapter le chemin). Le script ne touche pas aux autres addons.

## Modules et état

| Module | Comportement v0.1 |
|---|---|
| Alphabet | 33 lettres majuscules/minuscules, explications FR, repères phonétiques, tests et couleurs de maîtrise |
| Tooltips | Ligne russe et translittération sur objets, sorts, PNJ selon les données disponibles |
| Contexte | Dernier texte rencontré, français facultatif, épinglage, lexique extrait par correspondance exacte ou formes connues |
| Quêtes | Événements PNJ et commande par ID, textes FRS en panneau séparé, ouverture automatique facultative |
| Monde | Zone/sous-zone via le résolveur FRS, PNJ ciblé via GUID ; pas de modification de carte |
| Audio | TTS locale, sélection manuelle/automatique de voix russe, lecture sur demande |
| Lexique | Plus de 100 cartes pédagogiques intégrées, recherche, pagination, collecte de noms traduits et de mots reconnus |
| Révisions | QCM lettres, RU→FR, FR→RU, phrases ; espacements 1/3/7/14/30 jours, erreur après 5 min |
| Grammaire | 7 fiches contextuelles et quelques formes fléchies explicites ; pas de lemmatiseur général |
| Progression | Cartes dues, lettres/cartes acquises (3 réussites consécutives), total quotidien UTC |
| Temps morts | Ouverture des révisions en taxi si activée ; désactivée par défaut |
| Options | Interrupteurs par fonctionnalité, panneau déplaçable, aucune réécriture de l'UI Blizzard |

Le corpus pédagogique est original et limité. Les traductions FRS peuvent inclure de l'IA ; le signal fourni par FRS est affiché quand disponible. Les noms locaux de secours ne sont pas une base de traductions officielle exhaustive. Les cartes collectées automatiquement ne sont pas toujours des mots isolés, mais peuvent être des noms complets.

## Commandes

- `/fru` : alphabet ; `/fru review` : révisions ; `/fru context` : dernier contexte ; `/fru dictionary` : lexique ; `/fru grammar` ; `/fru settings`.
- `/fru quest 783` : exemple de consultation par ID, si couvert par FRS.
- `/fru add лес ; forêt` : ajouter une carte manuelle.
- `/fru seed` : réimporter le lexique (sans doublons exacts). `/fru seed verbe` : une catégorie.
- `/fru voices`, `/fru voice 2` (ID exemple, choisir selon la liste), `/fru voice auto`, `/fru say Привет!`.
- `/fru debug` : erreurs internes capturées, build, FRS, traductions manquantes. `/fru hide` : fermer.

### Prononciation Windows

Installer le russe et, si disponible, le composant voix/synthèse vocale dans Paramètres Windows > Heure et langue > Langue et région. Redémarrer le jeu. Vérifier `/fru voices`. Certaines voix Windows ne sont pas exposées à WoW ; si aucune voix russe n'apparaît, l'audio reste indisponible. Aucun contournement registre inclus. La lecture d'une lettre isolée par le TTS est expérimentale (nom de lettre vs son en contexte). La translittération est un repère de lecture et non une transcription phonétique exacte.

## GitHub et Codex

Voir [GITHUB.md](GITHUB.md) pour créer le dépôt et [AGENTS.md](AGENTS.md) pour les consignes destinées à Codex. [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) présente les modules, [docs/ROADMAP.md](docs/ROADMAP.md) les prochaines étapes et [docs/TESTS.md](docs/TESTS.md) le protocole de validation en jeu.

## Sauvegarde / confidentialité

`ForeverRusseDB` est une SavedVariable de compte, enregistrée par WoW lors d'une déconnexion normale ou d'un `/reload`. Elle contient les préférences, mots rencontrés, dates de révision, statistiques et IDs manquants (500 max). Aucun chat privé ni nom de joueur n'est collecté ; aucun envoi de données. Sauvegarder `WTF/Account/<compte>/SavedVariables/ForeverRusse.lua` avant une réinitialisation ; ne jamais le publier sur GitHub sans inspection.

## Validation et limites

Prototype non exécuté dans un vrai client WoW. Tests hors jeu du moteur fournis. Les hooks modernes de tooltip, les valeurs secrètes, les champs précis des quêtes, l'affichage cyrillique de la police, la disponibilité TTS et l'agencement UI demandent une validation en jeu. Le panneau n'altère pas les quêtes, la carte, les actions ou le chat. Les dialogues de PNJ, la traduction complète des descriptions de sorts/objets, les mots cliquables, l'immersion adaptative dans l'UI Blizzard et la grammaire automatique ne sont pas encore réalisés.

Crédits et références : [docs/SOURCES.md](docs/SOURCES.md). Aucun catalogue FRS n'est redistribué. Aucune licence de redistribution de ce nouveau projet n'est imposée : à choisir par le propriétaire du dépôt avant publication.
