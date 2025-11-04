#!/bin/bash
set -e

echo "🚀 Déploiement automatique sur Cloudflare Workers..."
echo ""

# Vérifier que wrangler est installé
if ! command -v wrangler &> /dev/null && [ ! -f "node_modules/.bin/wrangler" ]; then
    echo "📦 Installation de Wrangler..."
    npm install wrangler --save-dev
fi

WRANGLER_CMD=""
if command -v wrangler &> /dev/null; then
    WRANGLER_CMD="wrangler"
elif [ -f "node_modules/.bin/wrangler" ]; then
    WRANGLER_CMD="node_modules/.bin/wrangler"
else
    WRANGLER_CMD="npx wrangler"
fi

echo "✅ Wrangler trouvé: $WRANGLER_CMD"
echo ""

# Vérifier l'authentification
echo "🔐 Vérification de l'authentification Cloudflare..."
if ! $WRANGLER_CMD whoami &> /dev/null; then
    echo "⚠️  Non authentifié. Démarrage de l'authentification..."
    $WRANGLER_CMD login
    echo ""
fi

echo "✅ Authentifié"
echo ""

# Vérifier le BACKEND_URL
echo "🔍 Vérification de la configuration BACKEND_URL..."
BACKEND_URL=$(grep -A 1 "BACKEND_URL" wrangler.toml | grep -v "^#" | grep "=" | head -1 | sed 's/.*= *"\(.*\)".*/\1/' || echo "")

if [ -z "$BACKEND_URL" ] || [ "$BACKEND_URL" = "https://votre-backend.onrender.com" ]; then
    echo "⚠️  BACKEND_URL non configuré ou utilise la valeur par défaut"
    echo "💡 Pour configurer, éditiez wrangler.toml et remplacez:"
    echo "   BACKEND_URL = \"https://votre-backend.onrender.com\""
    echo "   par l'URL de votre serveur backend (ex: Render, Railway)"
    echo ""
    read -p "Voulez-vous continuer quand même? (o/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[OoYy]$ ]]; then
        echo "❌ Déploiement annulé"
        exit 1
    fi
else
    echo "✅ BACKEND_URL configuré: $BACKEND_URL"
fi
echo ""

# Build
echo "🔨 Build de l'application..."
npm run build:cloudflare || {
    echo "❌ Erreur lors du build"
    exit 1
}
echo "✅ Build terminé"
echo ""

# Vérifier si KV namespace existe
echo "🔍 Vérification du KV namespace..."
KV_NAMESPACE_ID=$(grep -A 1 "kv_namespaces" wrangler.toml | grep "id" | head -1 | sed 's/.*id = *"\(.*\)".*/\1/' || echo "")

if [ -n "$KV_NAMESPACE_ID" ] && [ "$KV_NAMESPACE_ID" != "votre-kv-namespace-id" ]; then
    echo "📦 KV namespace détecté, upload des assets..."
    npm run upload:kv || {
        echo "⚠️  Erreur lors de l'upload KV (continuation du déploiement)"
    }
    echo ""
else
    echo "ℹ️  KV namespace non configuré (optionnel)"
    echo "   Les fichiers statiques seront servis depuis le worker directement"
    echo ""
fi

# Déployer
echo "🚀 Déploiement du worker sur Cloudflare..."
$WRANGLER_CMD deploy || {
    echo "❌ Erreur lors du déploiement"
    exit 1
}

echo ""
echo "✅ Déploiement réussi!"
echo ""
echo "📋 URL du worker:"
$WRANGLER_CMD deployments list 2>/dev/null | head -5 || echo "   Vérifiez dans le dashboard Cloudflare"
echo ""
echo "💡 Prochaines étapes:"
echo "   1. Vérifiez que BACKEND_URL pointe vers votre serveur backend"
echo "   2. Testez l'URL du worker dans votre navigateur"
echo "   3. Configurez CORS dans votre backend si nécessaire"

