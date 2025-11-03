# Configuration Cloudflare Workers pour Void Code

Ce guide explique comment déployer Void Code sur Cloudflare Workers.

## ⚠️ Architecture et Limitations

VS Code Web nécessite :
- **Serveur Node.js** pour les WebSockets et extensions (backend)
- **Fichiers statiques** pour l'interface (frontend)

**Solution recommandée** :
- **Cloudflare Workers** → Sert les fichiers statiques + proxy vers le backend
- **Render/Railway** → Héberge le serveur Node.js (`server.js`)

## 📋 Prérequis

1. Compte Cloudflare avec Workers (plan gratuit ou payant)
2. Wrangler CLI installé : `npm install -g wrangler` ou `npm install wrangler`
3. Authentification : `npx wrangler login`
4. Serveur backend hébergé (Render, Railway, etc.)

## 🚀 Déploiement

### Étape 1 : Créer un KV Namespace (optionnel mais recommandé)

Pour servir les fichiers statiques depuis KV Storage :

```bash
# Créer le namespace
npm run setup:kv

# Copier l'ID retourné et l'ajouter dans wrangler.toml
# [[kv_namespaces]]
# binding = "STATIC_ASSETS"
# id = "votre-id-ici"
```

### Étape 2 : Configurer le backend URL

Éditez `wrangler.toml` et remplacez `BACKEND_URL` :

```toml
[vars]
BACKEND_URL = "https://votre-app.onrender.com"
```

### Étape 3 : Build et upload des assets (si KV utilisé)

```bash
# Build les fichiers statiques
npm run build:cloudflare

# Upload vers KV (si vous utilisez KV)
npm run upload:kv
```

### Étape 4 : Déployer le Worker

```bash
# Déployer
npm run deploy:worker

# Ou directement
npx wrangler deploy
```

## 🔧 Configuration

### Variables d'environnement

Dans `wrangler.toml` :

```toml
[vars]
BACKEND_URL = "https://votre-backend.onrender.com"
```

Ou via CLI :

```bash
npx wrangler secret put BACKEND_URL
# Entrez: https://votre-backend.onrender.com
```

### Routes personnalisées

Si vous avez un domaine personnalisé, ajoutez dans `wrangler.toml` :

```toml
[[routes]]
pattern = "votre-domaine.com/*"
zone_name = "votre-domaine.com"
```

## 📁 Structure du Worker

```
worker/
  ├── index.js          # Code principal du Worker
  └── package.json      # Configuration du Worker

wrangler.toml           # Configuration Wrangler
upload-assets-to-kv.js  # Script pour uploader vers KV
```

## 🔄 Fonctionnement

Le Worker :

1. **Routes statiques** (`/out/`, `/extensions/`, `/resources/`)
   - Sert depuis KV Storage (si configuré)
   - Sinon, génère le HTML du workbench

2. **Routes API** (`/api/*`, `/vscode-remote-resource`)
   - Proxy vers le backend configuré

3. **WebSockets**
   - Proxy vers le backend pour les connexions WebSocket

4. **Route racine** (`/`)
   - Sert `workbench.html` avec la configuration appropriée

## 🐛 Dépannage

### Erreur : "Backend URL not configured"

Configurez `BACKEND_URL` dans `wrangler.toml` ou via secrets :

```bash
npx wrangler secret put BACKEND_URL
```

### Erreur : "KV namespace not found"

Créez le namespace :

```bash
npm run setup:kv
```

Puis ajoutez l'ID dans `wrangler.toml`.

### Les fichiers statiques ne se chargent pas

1. Vérifiez que le build a réussi : `npm run build:cloudflare`
2. Vérifiez que les fichiers sont dans `dist/`
3. Upload vers KV : `npm run upload:kv`
4. Vérifiez que le namespace est correctement configuré dans `wrangler.toml`

### CORS errors

Configurez CORS dans votre backend (`server.js` sur Render) :

```javascript
// Dans server.js ou votre backend
res.setHeader('Access-Control-Allow-Origin', 'https://votre-worker.votre-domaine.workers.dev');
res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
```

## 📊 Coûts Cloudflare

### Plan Gratuit
- 100,000 requêtes/jour
- 10ms CPU time par requête
- KV: 100,000 lectures/jour, 1,000 écritures/jour

### Plan Payant ($5/mois)
- 10M requêtes/mois inclus
- 50ms CPU time par requête
- KV: Lectures et écritures illimitées

## 🔗 Liens utiles

- [Cloudflare Workers Docs](https://developers.cloudflare.com/workers/)
- [Wrangler CLI](https://developers.cloudflare.com/workers/wrangler/)
- [KV Storage](https://developers.cloudflare.com/kv/)

## 💡 Alternative : Sans KV

Si vous ne voulez pas utiliser KV, vous pouvez :

1. Héberger les fichiers statiques sur Cloudflare Pages
2. Utiliser le Worker uniquement pour le proxy/routing
3. Ou servir les fichiers depuis votre backend directement

Consultez `CLOUDFLARE_DEPLOY.md` pour l'option Pages.

