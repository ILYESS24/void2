# 🔧 Correction : Erreur Dockerfile sur Render

## Problème
Render essaie d'utiliser Docker alors qu'il n'y a pas de Dockerfile :
```
error: failed to solve: failed to read dockerfile: open Dockerfile: no such file or directory
```

## Solution

### Option 1 : Dans le Dashboard Render (RECOMMANDÉ)

1. **Allez dans votre service** sur Render Dashboard
2. **Settings** → **Build & Deploy**
3. **Désactivez Docker** :
   - Changez **Runtime** de `Docker` à `Node`
   - Ou changez **Build Command** pour utiliser Nixpacks
4. **Sauvegardez**

### Option 2 : Reconfigurer le service

1. **Supprimez le service actuel** (optionnel, seulement si nécessaire)
2. **Recréez-le** avec ces paramètres :
   - **Runtime** : `Node` (pas Docker)
   - **Build Command** : `npm ci --legacy-peer-deps && npm run compile-web && npm run download-builtin-extensions`
   - **Start Command** : `node server.js`
   - **Environment** : `Node`

### Option 3 : Forcer render.yaml

Si Render détecte automatiquement Docker, forcez l'utilisation de `render.yaml` :

1. Dans **Settings** → **Build & Deploy**
2. Cochez **"Use render.yaml"**
3. Ou supprimez toute référence à Docker

---

## Configuration correcte

### render.yaml mis à jour

J'ai ajouté `dockerfilePath: ""` pour forcer Render à ne pas utiliser Docker.

### Paramètres corrects :

- ✅ **Runtime** : `Node` (pas Docker)
- ✅ **Build Command** : `npm ci --legacy-peer-deps && npm run compile-web && npm run download-builtin-extensions`
- ✅ **Start Command** : `node server.js`
- ✅ **Plan** : `Free`

---

## Vérification

Après correction, les logs devraient montrer :
```
==> Cloning from https://github.com/ILYESS24/void2
==> Checking out commit...
==> Detected Node
==> Installing dependencies...
npm ci --legacy-peer-deps
```

Pas de messages Docker.

---

## Si le problème persiste

1. **Supprimez le service** dans Render Dashboard
2. **Recréez-le** manuellement avec les bons paramètres
3. **Assurez-vous** que `render.yaml` est bien dans le repo (il est déjà là ✅)

