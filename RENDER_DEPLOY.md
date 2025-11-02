# 🚀 Guide de déploiement sur Render

## Étapes pour déployer Void sur Render

### 1. Préparer votre repository
- ✅ Tous les fichiers sont déjà en place :
  - `server.js` - Serveur pour Render
  - `render.yaml` - Configuration Render
  - `.nvmrc` - Version Node.js
  - `.npmrc` - Configuration npm

### 2. Créer un compte Render
1. Allez sur [render.com](https://render.com)
2. Créez un compte (gratuit avec GitHub/Google)

### 3. Déployer depuis GitHub
1. Dans Render Dashboard, cliquez sur **"New +"** → **"Web Service"**
2. Connectez votre repository GitHub
3. Render détectera automatiquement `render.yaml`
4. Ou configurez manuellement :
   - **Name**: `void-editor`
   - **Environment**: `Node`
   - **Build Command**: `npm ci --legacy-peer-deps && npm run compile-web && npm run download-builtin-extensions`
   - **Start Command**: `node server.js`
   - **Plan**: `Free`

### 4. Variables d'environnement (optionnel)
- `NODE_ENV`: `production`
- `HOST`: `0.0.0.0` (déjà configuré)

### 5. Déployer
- Cliquez sur **"Create Web Service"**
- Le build peut prendre 10-15 minutes (compilation TypeScript)
- Une fois terminé, votre Void sera accessible !

## ⚠️ Notes importantes

### Plan gratuit Render :
- ✅ 750 heures gratuites par mois
- ⚠️ S'endort après **15 minutes d'inactivité**
- ⏱️ Premier démarrage après sommeil : ~30 secondes

### Si le build échoue :
1. Vérifiez les logs dans Render Dashboard
2. Le build nécessite beaucoup de mémoire (peut échouer sur free tier si trop gros)
3. Solution : Augmenter temporairement à "Starter" ($7/mois) pour le build, puis revenir en free

### Vérifier que ça fonctionne :
- Ouvrez l'URL fournie par Render
- Vous devriez voir l'interface Void !

## 🔧 Commandes utiles

### Build local (test avant déploiement) :
```bash
npm ci --legacy-peer-deps
npm run compile-web
npm run download-builtin-extensions
node server.js
```

### Accéder à l'application :
- Render vous donnera une URL comme : `https://void-editor.onrender.com`
- Première visite après sommeil : attendez 30 secondes

## 🎉 C'est tout !
Votre Void est maintenant en ligne gratuitement sur Render !

