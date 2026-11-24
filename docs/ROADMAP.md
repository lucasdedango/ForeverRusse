# Roadmap

## P0 — validation réelle de v0.1
- Vérifier le chargement sur le build Forever actuel, les templates de frames, les polices cyrilliques et les hooks de tooltip. Tester sans FRS puis avec FRS v3 en mode normal et API only.
- Inspecter un vrai record de quête FRS (structure, champs, placeholders, objectifs) ; corriger l'adaptateur et ajouter des fixtures minimales fictives.
- Vérifier PNJ et zones, voix TTS russes, scroll et taille du panneau sur différentes résolutions. Tester en combat pour confirmer absence d'erreur / taint.
- Ajouter tests d'intégration avec mocks, trace opt-in et tests des valeurs secrètes.

## P1 — pédagogie plus fine
- Exercices lettres ciblés par fréquence et difficulté, écoute→lettre, saisie avec clavier cyrillique virtuel, lecture de vrais mots, distinction lettres trompeuses (В Н Р С У Х).
- Utiliser une translittération pédagogique configurable, puis masquer les aides des lettres acquises. Préférer accents et sons corrects à une phonétique approximative.
- Séparer les cartes directionnelles RU→FR / FR→RU, ajouter FSRS/SM-2 si utile, révision à la demande, suspendre/supprimer/éditer les cartes, import/export local compatible Anki.
- Bouton de copie des phrases sans envoi automatique, catégories et recherche améliorées.

## P2 — immersion et narration
- Panneau parallèle pour quête avec vrai alignement de phrases, mots cliquables et info de grammaire, données de quêtes structurées. Conserver français accessible et éviter les mélanges grammaticalement incohérents.
- Glossaire de lemmes, accents et formes (étudier pymorphy3 hors jeu ; vérifier licences et qualité des données). Ne pas ajouter un modèle lourd au client.
- Historique des contextes, monde bilingue, détails de sorts/objets selon les règles du fournisseur, éventuellement carte/objectif en overlay non protégé.
- Immersion adaptative uniquement dans le panneau propre à l'addon en premier ; étudier les autres surfaces après tests. Jamais d'actions protégées.
