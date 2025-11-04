# 🚀 Configuration GitHub Actions pour Cloudflare Pages

## ✅ Workflow créé !

Un workflow GitHub Actions a été créé pour déployer automatiquement sur Cloudflare Pages à chaque push sur `main`.

## 📋 Étapes de configuration

### 1. Créer un token API Cloudflare

1. Allez sur : https://dash.cloudflare.com/profile/api-tokens
2. Cliquez sur **"Create Token"**
3. Utilisez le template **"Edit Cloudflare Workers"** ou créez un token personnalisé :
   - **Permissions** :
     - `Account` → `Cloudflare Pages` → `Edit`
   - **Account Resources** :
     - `Include` → `All accounts` (ou sélectionnez votre compte)
4. Cliquez sur **"Continue to summary"** → **"Create Token"**
5. **Copiez le token** (vous ne pourrez plus le voir après !)

### 2. Obtenir votre Account ID Cloudflare

1. Allez sur : https://dash.cloudflare.com/
2. Sélectionnez n'importe quel site dans **Workers & Pages**
3. Dans la barre latérale droite, trouvez **"Account ID"**
4. **Copiez l'Account ID**

### 3. Ajouter les secrets à GitHub

1. Allez sur votre repo : https://github.com/ILYESS24/void2
2. Cliquez sur **Settings** → **Secrets and variables** → **Actions**
3. Cliquez sur **"New repository secret"**
4. Ajoutez deux secrets :

   | Name | Value |
   |------|-------|
   | `CLOUDFLARE_API_TOKEN` | Le token API que vous avez copié |
   | `CLOUDFLARE_ACCOUNT_ID` | L'Account ID que vous avez copié |

### 4. Créer le projet Cloudflare Pages (si pas déjà fait)

1. Allez sur : https://dash.cloudflare.com/
2. **Workers & Pages** → **Create** → **Pages** → **Create a project**
3. Nom du projet : `void-code`
4. **Ne connectez PAS GitHub** (on utilise GitHub Actions)
5. Cliquez sur **"Create project"**

### 5. C'est tout !

✅ **Dès maintenant, chaque push sur `main` déclenchera automatiquement :**
- Installation des dépendances
- Build avec Node 20
- Déploiement sur Cloudflare Pages
- URL : `https://void-code.pages.dev`

## 🔍 Vérifier le déploiement

1. Allez sur votre repo GitHub : https://github.com/ILYESS24/void2
2. Cliquez sur l'onglet **"Actions"**
3. Vous verrez le workflow "Deploy to Cloudflare Pages" s'exécuter
4. Cliquez dessus pour voir les logs en temps réel

## 🎯 Alternative : Connexion directe GitHub → Cloudflare Pages

Si vous préférez ne pas utiliser GitHub Actions, vous pouvez connecter directement GitHub à Cloudflare Pages via le dashboard (voir `DEPLOY_NOW.md`).

## ❓ Problèmes ?

- **Build échoue** : Vérifiez les logs dans l'onglet Actions
- **Token invalide** : Vérifiez que le token a les bonnes permissions
- **Account ID incorrect** : Vérifiez que vous avez copié le bon ID
- **Projet n'existe pas** : Créez-le d'abord dans Cloudflare Pages (étape 4)

---

**Temps estimé** : 5 minutes  
**Difficulté** : ⭐⭐ Moyen

