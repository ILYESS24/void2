# 🧪 Tester le déploiement Render localement

Ce guide vous permet de tester **exactement** ce que Render va faire, étape par étape, pour détecter les erreurs en avance.

## 🚀 Méthode rapide (recommandée)

### Sur Windows :
```bash
# 1. Simuler le build Render
.\test-render-build.bat

# 2. Tester le serveur (dans un autre terminal)
.\test-render-server.bat
```

### Sur Linux/Mac :
```bash
# 1. Rendre les scripts exécutables
chmod +x test-render-build.sh test-render-server.sh

# 2. Simuler le build Render
./test-render-build.sh

# 3. Tester le serveur (dans un autre terminal)
./test-render-server.sh
```

### Avec npm (tous les systèmes) :
```bash
# 1. Simuler le build Render (identique à Render)
npm run test-render-build

# 2. Tester le serveur avec les mêmes variables d'environnement
npm run test-render-server
```

---

## 📋 Ce que les scripts font

### Étape 1 : Build (`test-render-build`)
Simule **exactement** ce que Render fait lors du build :
1. ✅ `npm ci --legacy-peer-deps` - Installation propre des dépendances
2. ✅ `npm run compile-web` - Compilation TypeScript → JavaScript
3. ✅ `npm run download-builtin-extensions` - Téléchargement des extensions

### Étape 2 : Serveur (`test-render-server`)
Teste le serveur avec les **mêmes variables d'environnement** que Render :
- `NODE_ENV=production`
- `HOST=0.0.0.0`
- `PORT=10000`
- `NODE_OPTIONS=--max-old-space-size=4096`

---

## 🔍 Vérifications à faire

### ✅ Si le build réussit :
1. Le dossier `out/` doit être créé avec des fichiers `.js`
2. Pas d'erreurs TypeScript
3. Les extensions sont dans `.build/builtInWebDevExtensions`

### ✅ Si le serveur démarre :
1. Console affiche : `🚀 Starting Void web server on 0.0.0.0:10000...`
2. URL accessible : `http://localhost:10000`
3. L'interface Void s'affiche dans le navigateur

---

## ❌ Erreurs courantes et solutions

### Erreur : "Module not found"
```bash
# Solution : Réinstaller les dépendances
rm -rf node_modules package-lock.json  # Linux/Mac
del /s /q node_modules package-lock.json  # Windows
npm ci --legacy-peer-deps
```

### Erreur : "Out of memory"
```bash
# Solution : Augmenter la mémoire
set NODE_OPTIONS=--max-old-space-size=8192  # Windows
export NODE_OPTIONS="--max-old-space-size=8192"  # Linux/Mac
```

### Erreur : "Cannot find module '@vscode/test-web'"
```bash
# Solution : Réinstaller et compiler
npm ci --legacy-peer-deps
npm run compile-web
```

### Erreur : Port déjà utilisé
```bash
# Solution : Changer le port
set PORT=3000 && npm run test-render-server  # Windows
PORT=3000 npm run test-render-server  # Linux/Mac
```

---

## 📊 Comparaison : Local vs Render

| Étape | Local | Render |
|-------|-------|--------|
| Build | ✅ `test-render-build` | ✅ `buildCommand` dans `render.yaml` |
| Variables | ✅ Scripts | ✅ `envVars` dans `render.yaml` |
| Serveur | ✅ `test-render-server` | ✅ `startCommand` dans `render.yaml` |
| Logs | ✅ Terminal | ✅ Dashboard Render |

**Si ça marche localement, ça marchera sur Render !** ✅

---

## 🎯 Checklist avant déploiement

- [ ] `npm run test-render-build` réussit sans erreur
- [ ] `npm run test-render-server` démarre correctement
- [ ] Interface accessible sur `http://localhost:10000`
- [ ] Pas d'erreurs dans la console du navigateur
- [ ] Les fichiers `out/` sont générés correctement

---

## 💡 Astuce

Si vous modifiez le code après le build, relancez simplement :
```bash
npm run test-render-build
```

Puis testez à nouveau avec :
```bash
npm run test-render-server
```

---

## 🐛 Debug avancé

Si vous avez des erreurs étranges, comparez **exactement** avec Render :

1. **Vérifiez les logs Render** dans le Dashboard
2. **Comparez** avec vos logs locaux
3. **Cherchez les différences** dans :
   - Versions Node.js (`.nvmrc`)
   - Variables d'environnement
   - Chemins de fichiers

---

**Résultat** : Si tout fonctionne localement, votre déploiement Render fonctionnera du premier coup ! 🎉

