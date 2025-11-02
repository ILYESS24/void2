#!/bin/bash
# Script de démarrage pour Render qui installe les dépendances critiques au runtime

echo "🚀 Démarrage du serveur Render..."
echo "📦 Installation des dépendances critiques au runtime..."

# Installer les dépendances critiques si elles ne sont pas présentes
if [ ! -d "node_modules/@vscode/test-web" ]; then
    echo "⚠️ @vscode/test-web manquant, installation..."
    npm install @vscode/test-web --legacy-peer-deps --no-save --force
fi

if [ ! -d "node_modules/rimraf" ]; then
    echo "⚠️ rimraf manquant, installation..."
    npm install rimraf --legacy-peer-deps --no-save --force
fi

# Vérification finale
echo "✅ Vérification des dépendances critiques:"
[ -d "node_modules/@vscode/test-web" ] && echo "  ✓ @vscode/test-web" || echo "  ✗ @vscode/test-web MANQUANT"
[ -d "node_modules/rimraf" ] && echo "  ✓ rimraf" || echo "  ✗ rimraf MANQUANT"

# Démarrer le serveur
echo ""
echo "🌐 Démarrage du serveur Node.js..."
exec node server.js

