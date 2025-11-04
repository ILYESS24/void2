#!/bin/bash
# Script pour simuler le build Render localement

set -e  # Arrête en cas d'erreur

echo "🔍 Simulation du build Render..."
echo "================================"

# Variables d'environnement comme Render
export NODE_ENV=production
export HOST=0.0.0.0
export PORT=${PORT:-10000}
export NODE_OPTIONS="--max-old-space-size=4096"

echo "📦 Étape 1/3: Installation des dépendances..."
echo "Commande: npm ci --legacy-peer-deps"
npm ci --legacy-peer-deps

echo ""
echo "🔨 Étape 2/3: Compilation web..."
echo "Commande: npm run compile-web"
npm run compile-web

echo ""
echo "📥 Étape 3/3: Téléchargement des extensions..."
echo "Commande: npm run download-builtin-extensions"
npm run download-builtin-extensions

echo ""
echo "✅ Build terminé avec succès!"
echo ""
echo "🚀 Pour tester le serveur, exécutez:"
echo "   PORT=${PORT} node server.js"
echo ""
echo "🌐 Puis ouvrez: http://localhost:${PORT}"

