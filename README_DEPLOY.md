# 🚀 Guide de Déploiement Complet - Void Code

Ce guide couvre tous les déploiements possibles pour Void Code.

## 📋 Table des Matières

1. [Déploiement sur Render](#render)
2. [Déploiement sur Cloudflare Workers](#cloudflare-workers)
3. [Déploiement sur Cloudflare Pages](#cloudflare-pages)
4. [Architecture Recommandée](#architecture)

---

## 🎯 Render {#render}

### Prérequis
- Compte Render
- Repository GitHub

### Déploiement

1. **Connecter votre repo GitHub à Render**
   - Allez sur [Render Dashboard](https://dashboard.render.com/)
   - Cliquez sur "New" → "Web Service"
   - Connectez votre repository

2. **Configuration**
   - **Build Command**: `bash build-render.sh`
   - **Start Command**: `bash start-render.sh`
   - **Environment**: `Node`
   - **Node Version**: `20.x`

3. **Variables d'environnement** (optionnel)
   ```
   PORT=10000
   HOST=0.0.0.0
   ```

4. **Déployer**
   - Cliquez sur "Create Web Service"
   - Render va automatiquement builder et déployer

### Documentation
Voir `RENDER_DEPLOY.md` pour plus de détails.

---

## ⚡ Cloudflare Workers {#cloudflare-workers}

### Prérequis
- Compte Cloudflare
- Wrangler CLI installé
- Backend hébergé (Render, Railway, etc.)

### Déploiement Rapide

```bash
# Déploiement automatique
npm run deploy:worker:simple
```

### Déploiement Complet

1. **Authentification**
   ```bash
   npx wrangler login
   ```

2. **Configurer BACKEND_URL**

   Éditez `wrangler.toml`:
   ```toml
   [vars]
   BACKEND_URL = "https://votre-app.onrender.com"
   ```

3. **Déployer**
   ```bash
   npm run deploy:worker
   ```

4. **Upload des assets vers KV (optionnel)**
   ```bash
   # Créer le namespace KV
   npm run setup:kv

   # Build les fichiers
   npm run build:cloudflare

   # Upload vers KV
   npm run upload:kv
   ```

### Documentation
Voir `CLOUDFLARE_WORKERS_SETUP.md` pour plus de détails.

---

## 📄 Cloudflare Pages {#cloudflare-pages}

### Prérequis
- Compte Cloudflare
- Repository GitHub

### Déploiement

1. **Via GitHub**
   - Connectez votre repo à Cloudflare Pages
   - **Build command**: `npm run build:cloudflare`
   - **Build output directory**: `dist`

2. **Via CLI**
   ```bash
   npm run build:cloudflare
   npx wrangler pages deploy dist
   ```

### Documentation
Voir `CLOUDFLARE_DEPLOY.md` pour plus de détails.

---

## 🏗️ Architecture Recommandée {#architecture}

### Option 1 : Render (Tout-en-un) ⭐ Recommandé

```
┌─────────────────┐
│     Render      │
│  (Backend +     │
│   Frontend)     │
│                 │
│  - server.js    │
│  - Fichiers     │
│    statiques    │
└─────────────────┘
```

**Avantages**:
- Simple à configurer
- Tout au même endroit
- Pas besoin de configuration CORS

**Inconvénients**:
- Plus lent que Cloudflare pour les fichiers statiques
- Coûts potentiellement plus élevés

### Option 2 : Cloudflare Workers + Render (Hybride)

```
┌─────────────────┐      ┌─────────────────┐
│ Cloudflare      │──────│     Render     │
│ Workers         │Proxy │  (Backend)     │
│                 │      │                 │
│ - Fichiers      │      │ - server.js    │
│   statiques     │      │ - Extensions   │
│ - Proxy API     │      │ - WebSockets   │
└─────────────────┘      └─────────────────┘
```

**Avantages**:
- Performance optimale (CDN Cloudflare)
- Coûts réduits (plan gratuit Cloudflare)
- Scalabilité élevée

**Inconvénients**:
- Configuration plus complexe
- Nécessite configuration CORS

### Option 3 : Cloudflare Pages + Render

```
┌─────────────────┐      ┌─────────────────┐
│ Cloudflare      │      │     Render     │
│ Pages           │      │  (Backend)     │
│                 │      │                 │
│ - Fichiers      │      │ - server.js    │
│   statiques     │      │ - Extensions   │
│                 │      │ - WebSockets   │
└─────────────────┘      └─────────────────┘
```

**Avantages**:
- Bonne performance pour les fichiers statiques
- Facile à configurer

**Inconvénients**:
- Pas de proxy automatique (CORS nécessaire)
- Deux services à gérer

---

## 🔧 Configuration CORS

Si vous utilisez une architecture hybride (Cloudflare + Backend séparé), configurez CORS dans votre backend:

### Dans `server.js` (Render)

```javascript
// Ajouter avant le démarrage du serveur
const cors = require('cors');
app.use(cors({
    origin: ['https://votre-worker.workers.dev', 'https://votre-domaine.com'],
    credentials: true
}));
```

Ou manuellement:

```javascript
res.setHeader('Access-Control-Allow-Origin', 'https://votre-worker.workers.dev');
res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
```

---

## 📊 Comparaison des Solutions

| Solution | Coût | Performance | Complexité | Recommandé |
|---------|------|-------------|------------|------------|
| Render seul | $$ | ⭐⭐⭐ | ⭐ | ✅ Oui |
| Workers + Render | $ | ⭐⭐⭐⭐⭐ | ⭐⭐ | ✅ Oui (prod) |
| Pages + Render | $ | ⭐⭐⭐⭐ | ⭐⭐ | ⚠️ Moyen |

---

## 🐛 Dépannage

### Page blanche
- Vérifiez que le build s'est bien passé
- Vérifiez la console du navigateur
- Vérifiez que les fichiers statiques sont accessibles

### Erreurs CORS
- Configurez CORS dans votre backend
- Vérifiez que BACKEND_URL est correctement configuré

### Erreurs 503
- Vérifiez que le backend est démarré
- Vérifiez que BACKEND_URL pointe vers le bon serveur

### Build échoue
- Vérifiez que Node.js 20+ est installé
- Vérifiez que toutes les dépendances sont installées
- Exécutez `npm install --legacy-peer-deps`

---

## 📚 Ressources

- [Documentation Render](https://render.com/docs)
- [Documentation Cloudflare Workers](https://developers.cloudflare.com/workers/)
- [Documentation Cloudflare Pages](https://developers.cloudflare.com/pages/)

---

## 💡 Prochaines Étapes

1. Choisissez votre architecture
2. Suivez le guide de déploiement correspondant
3. Testez votre déploiement
4. Configurez un domaine personnalisé (optionnel)

---

**Note**: Pour une utilisation en production, l'architecture **Cloudflare Workers + Render** offre le meilleur équilibre performance/coût.

