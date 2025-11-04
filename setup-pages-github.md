# ✅ Projet Cloudflare Pages créé !

**Projet** : `void-code`  
**URL** : https://void-code.pages.dev

## 🔗 Connecter GitHub (Pour build automatique)

### Via Dashboard Cloudflare :

1. Allez sur https://dash.cloudflare.com/
2. **Workers & Pages** → **void-code**
3. Cliquez sur **"Connect to Git"**
4. Sélectionnez votre repo : `ILYESS24/void2`
5. Configurez :
   - **Production branch** : `main`
   - **Build command** : `npm run build:cloudflare`
   - **Build output directory** : `dist`
   - **Root directory** : `/`
   - **Node version** : `20`
   - **Environment variables** :
     - `NPM_FLAGS`: `--legacy-peer-deps`
6. **Save and Deploy**

### Après connexion :

- ✅ Build automatique à chaque push sur `main`
- ✅ Preview deployments pour chaque PR
- ✅ URL : https://void-code.pages.dev

## 🚀 Déploiement manuel (si besoin)

```bash
# Build + Deploy
npm run deploy:pages
```

Ou directement :
```bash
wrangler pages deploy dist --project-name=void-code
```

