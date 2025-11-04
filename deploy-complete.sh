#!/bin/bash
set -e

echo "🚀 DÉPLOIEMENT COMPLET CLOUDFLARE PAGES"
echo "========================================"
echo ""

# Nettoyer
echo "🧹 Nettoyage..."
rm -rf dist
mkdir -p dist

# Build
echo "🔨 Build en cours..."
npm run build:cloudflare

# Vérifier que dist existe et contient des fichiers
if [ ! -d "dist" ] || [ -z "$(ls -A dist)" ]; then
    echo "❌ Erreur: dist/ est vide ou n'existe pas"
    exit 1
fi

echo "✅ Build terminé!"
echo ""

# Déployer
echo "🚀 Déploiement sur Cloudflare Pages..."
wrangler pages deploy dist --project-name=void-code --commit-dirty=true

echo ""
echo "✅ DÉPLOIEMENT TERMINÉ!"
echo "🌐 URL: https://void-code.pages.dev"

