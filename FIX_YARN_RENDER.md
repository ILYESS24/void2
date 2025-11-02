# 🔧 Correction : Render utilise yarn au lieu de npm

## Problème
Render exécute automatiquement `yarn` avant le `buildCommand`, ce qui fait échouer le build car le projet n'accepte que npm.

## Solutions dans render.yaml

J'ai ajouté plusieurs variables d'environnement pour forcer npm :

1. `skipAutoDetect: true` - Empêche Render de détecter automatiquement yarn
2. `npm_execpath: /usr/bin/npm` - Force npm dans preinstall.js
3. `VSCODE_SKIP_YARN_CHECK: "1"` - Variable pour skip (si supportée)

## Solution alternative : Modifier dans Render Dashboard

Si `skipAutoDetect` ne fonctionne pas :

1. **Settings** → **Build & Deploy**
2. **Auto-Deploy** : Garder activé
3. **Build Command** : Forcer avec `npm ci --legacy-peer-deps && npm run compile-web && npm run download-builtin-extensions`
4. **Cocher "Skip install"** ou désactiver l'auto-install si disponible

## Vérification

Après correction, les logs devraient montrer :
```
==> Running build command 'npm ci --legacy-peer-deps'
```

Pas de `yarn install` avant.

