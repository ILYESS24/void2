# Déploiement sur Cloudflare Pages/Workers

Ce guide explique comment déployer Void Code sur Cloudflare Pages via Wrangler CLI.

## ⚠️ Limitations importantes

VS Code Web nécessite un **serveur Node.js persistant** pour :
- Les WebSockets (pour les extensions)
- Le serveur backend (`@vscode/test-web`)
- Les extensions et le système de fichiers

**Cloudflare Pages/Workers sert uniquement les fichiers statiques.** Pour une utilisation complète, vous devez :

1. **Héberger le serveur backend** sur Render, Railway, ou un autre service Node.js
2. **Servir les fichiers statiques** via Cloudflare Pages
3. **Configurer CORS** pour permettre la communication entre le frontend (Cloudflare) et le backend (autre service)

## 📋 Prérequis

1. Un compte Cloudflare avec un abonnement (Workers Paid ou Pages)
2. Wrangler CLI installé : `npm install -g wrangler` ou `npm install wrangler`
3. Authentification Cloudflare : `wrangler login`

## 🚀 Déploiement

### Option 1 : Via Wrangler CLI (recommandé)

```bash
# Installer les dépendances
npm install

# Build pour Cloudflare
npm run build:cloudflare

# Déployer
npx wrangler pages deploy dist

# Ou utiliser le script combiné
npm run deploy:cloudflare
```

### Option 2 : Via GitHub (automatique)

1. Connectez votre repo GitHub à Cloudflare Pages
2. Configurez :
   - **Build command** : `npm run build:cloudflare`
   - **Build output directory** : `dist`
   - **Node version** : `20.x` ou supérieur

### Option 3 : Via le Dashboard Cloudflare

1. Allez sur [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Sélectionnez **Pages** → **Create a project**
3. Connectez votre repo GitHub
4. Configurez :
   - Framework preset : **None** (ou custom)
   - Build command : `npm run build:cloudflare`
   - Build output directory : `dist`

## 🔧 Configuration

### Variables d'environnement

Dans Cloudflare Pages, ajoutez :

- `NODE_VERSION`: `20` (ou supérieur)
- `NPM_FLAGS`: `--legacy-peer-deps`

### Routes personnalisées

Si vous utilisez un backend séparé, configurez les routes dans `wrangler.toml` :

```toml
[[routes]]
pattern = "/api/*"
zone_name = "votre-domaine.com"
```

## 🔗 Architecture recommandée

```
┌─────────────────┐
│  Cloudflare     │  →  Sert les fichiers statiques (HTML, JS, CSS)
│  Pages          │     (workbench.html, extensions, etc.)
└─────────────────┘
         │
         │ WebSocket / API
         ▼
┌─────────────────┐
│  Render/Railway │  →  Serveur Node.js (@vscode/test-web)
│  Backend        │     (server.js, extensions host)
└─────────────────┘
```

## 📝 Notes importantes

1. **Build process** : Le script `build-cloudflare.sh` compile le code TypeScript et copie les fichiers nécessaires dans `dist/`

2. **Fichiers servis** :
   - `dist/index.html` - Page d'accueil
   - `dist/out/` - Code compilé
   - `dist/extensions/` - Extensions web compilées

3. **CORS** : Si vous utilisez un backend séparé, configurez CORS dans votre serveur backend pour accepter les requêtes depuis votre domaine Cloudflare.

## 🐛 Dépannage

### Erreur : "Build failed"

- Vérifiez que toutes les dépendances sont installées : `npm ci --legacy-peer-deps`
- Vérifiez que le build fonctionne localement : `npm run build:cloudflare`

### Erreur : "Module not found"

- Assurez-vous que `node_modules` est bien installé
- Vérifiez que le script `build-cloudflare.sh` a les permissions d'exécution : `chmod +x build-cloudflare.sh`

### Page blanche

- Vérifiez que `out/vs/code/browser/workbench/workbench.js` existe dans `dist/`
- Vérifiez la console du navigateur pour les erreurs
- Assurez-vous que le backend est accessible et configuré correctement

## 📚 Ressources

- [Cloudflare Pages Documentation](https://developers.cloudflare.com/pages/)
- [Wrangler CLI Documentation](https://developers.cloudflare.com/workers/wrangler/)
- [VS Code Web Architecture](https://github.com/microsoft/vscode/tree/main/src/vs/server)

