# Mise en dépôt et reprise avec Codex

## Créer le repo

Décompresser le ZIP. Ouvrir le dossier racine (celui qui contient `README.md`, `AGENTS.md`, `.github/` et `ForeverRusse/`). Créer un dépôt vide GitHub nommé par exemple `forever-russe`, de préférence privé pendant les tests. Ne pas initialiser le repo distant avec un README si l'on utilise ces commandes.

Dans PowerShell ou Git Bash, après installation de Git :

```sh
git init
git add .
git commit -m "Initial ForeverRusse prototype"
git branch -M main
git remote add origin https://github.com/TON-COMPTE/forever-russe.git
git push -u origin main
```

Adapter l'URL et s'authentifier via GitHub. Si l'identité Git n'est pas configurée, définir `git config user.name` et `git config user.email` pour ce dépôt. Alternative : GitHub Desktop > Add local repository, puis Publish repository. Les fichiers cachés `.github` et `.gitignore` doivent être inclus.

## Avec Codex

Connecter/sélectionner le repo GitHub dans Codex ou ouvrir le dossier local avec Codex. Le fichier `AGENTS.md` donne la cible et les contraintes. Première demande conseillée :

> Lis AGENTS.md, README.md et docs/TESTS.md. Fais un audit du prototype ForeverRusse pour WoW Forever 16001 (pas Classic Era). Vérifie en priorité les contrats de l'API publique FRS v3, les champs de quête, les tooltips modernes et le TTS local. Ajoute des tests de régression et corrige les bugs sans supprimer le mode autonome. Donne-moi une checklist en jeu et un ZIP installable. N'invente pas de résultat de test WoW.

Puis tester en jeu, copier les erreurs de `/fru debug` et les éventuels messages Lua dans une issue ou dans le chat Codex. Ne pas publier les SavedVariables. Faire une branche par évolution. GitHub Actions vérifie les scripts Lua 5.1 et construit un ZIP installable à chaque push ou PR ; télécharger l'artefact dans Actions (il peut contenir un ZIP imbriqué).

## Packaging local

`python scripts/package.py` génère `dist/ForeverRusse-0.1.0-addon.zip`. Le ZIP projet et le ZIP installable ont des usages différents. Pour une version future, synchroniser le numéro dans Core.lua, TOC, README et script de packaging.
