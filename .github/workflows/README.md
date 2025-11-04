# GitHub Actions Workflows

## Déploiement automatique sur Cloudflare Pages

Le workflow `deploy-cloudflare-pages.yml` déploie automatiquement votre application sur Cloudflare Pages à chaque push sur `main`.

### Configuration requise

1. **Secrets GitHub** (Settings → Secrets and variables → Actions) :
   - `CLOUDFLARE_API_TOKEN` : Token API Cloudflare avec permissions Pages
   - `CLOUDFLARE_ACCOUNT_ID` : ID de votre compte Cloudflare

### Comment obtenir les secrets

#### 1. CLOUDFLARE_API_TOKEN

1. Allez sur https://dash.cloudflare.com/profile/api-tokens
2. Cliquez sur **"Create Token"**
3. Utilisez le template **"Edit Cloudflare Workers"** ou créez un token personnalisé avec :
   - Permissions : `Account` → `Cloudflare Pages` → `Edit`
   - Account Resources : `Include` → `All accounts` (ou votre compte spécifique)
4. Copiez le token et ajoutez-le comme secret GitHub

#### 2. CLOUDFLARE_ACCOUNT_ID

1. Allez sur https://dash.cloudflare.com/
2. Sélectionnez n'importe quel site (Workers & Pages)
3. Dans la barre latérale droite, vous verrez **"Account ID"**
4. Copiez-le et ajoutez-le comme secret GitHub

### Alternative : Connexion via Dashboard

Si vous préférez ne pas utiliser GitHub Actions, vous pouvez connecter directement GitHub à Cloudflare Pages via le dashboard :

1. Allez sur https://dash.cloudflare.com/
2. **Workers & Pages** → **Create** → **Pages** → **Connect to Git**
3. Autorisez Cloudflare à accéder à GitHub
4. Sélectionnez `ILYESS24/void2`
5. Configurez :
   - Build command : `npm run build:cloudflare`
   - Build output directory : `dist`
   - Node version : `20`
   - Environment variables : `NPM_FLAGS` = `--legacy-peer-deps`

### Avantages de GitHub Actions

- ✅ Contrôle total sur le processus de build
- ✅ Logs détaillés dans GitHub
- ✅ Déploiement conditionnel (branches, tags, etc.)
- ✅ Pas besoin de configurer dans le dashboard Cloudflare

### Avantages de Cloudflare Pages (Dashboard)

- ✅ Plus simple à configurer
- ✅ Preview deployments automatiques pour les PRs
- ✅ Interface graphique pour gérer les déploiements
- ✅ Rollback facile

