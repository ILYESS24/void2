# ⚠️ IMPORTANT : Correction du Build Command dans Render

## Problème

Render utilise toujours l'ancienne commande de build au lieu de `render.yaml`. Le service a probablement été créé manuellement dans le Dashboard.

## Solution : Modifier dans Render Dashboard

**ÉTAPE OBLIGATOIRE** :

1. Allez sur [dashboard.render.com](https://dashboard.render.com)
2. Ouvrez votre service `void-editor`
3. Cliquez sur **Settings** (⚙️)
4. Allez dans la section **Build & Deploy**
5. Trouvez **Build Command**
6. **REMPLACEZ** la commande actuelle par :
   ```
   chmod +x build-render.sh && ./build-render.sh
   ```
7. Cliquez sur **Save Changes**
8. Allez dans **Manual Deploy** → **Deploy latest commit**

## Commande actuelle (INCORRECTE) :
```
npm ci --legacy-peer-deps --ignore-scripts && npm install gulp --legacy-peer-deps --ignore-scripts --save-dev && npx gulp compile-web && npm run download-builtin-extensions
```

## Nouvelle commande (CORRECTE) :
```
chmod +x build-render.sh && ./build-render.sh
```

## Pourquoi ?

Le script `build-render.sh` :
- ✅ Installe toutes les dépendances correctement
- ✅ Vérifie et installe gulp si nécessaire
- ✅ Utilise plusieurs méthodes pour exécuter gulp (fallback)
- ✅ Gère mieux les erreurs

**Sans cette modification, Render continuera d'utiliser l'ancienne commande qui ne fonctionne pas.**

