#!/bin/bash
# Script de démarrage pour Render qui installe les dépendances critiques au runtime

echo "🚀 Démarrage du serveur Render..."
echo "📦 Installation des dépendances critiques au runtime..."

# Installer les dépendances critiques si elles ne sont pas présentes
# Utiliser --ignore-scripts pour éviter la compilation des modules natifs
echo "Vérification de @vscode/test-web..."
if ! node -e "require.resolve('@vscode/test-web')" 2>/dev/null; then
    echo "⚠️ @vscode/test-web manquant, installation..."
    npm install @vscode/test-web --legacy-peer-deps --no-save --force --ignore-scripts || {
        echo "⚠️ Installation avec erreurs, mais on continue..."
    }
    # Attendre un peu pour que npm termine
    sleep 2
else
    echo "✅ @vscode/test-web déjà présent"
fi

echo "Vérification de rimraf..."
if ! node -e "require.resolve('rimraf')" 2>/dev/null; then
    echo "⚠️ rimraf manquant, installation..."
    npm install rimraf --legacy-peer-deps --no-save --force --ignore-scripts || {
        echo "⚠️ Installation avec erreurs, mais on continue..."
    }
    # Attendre un peu pour que npm termine
    sleep 2
else
    echo "✅ rimraf déjà présent"
fi

# Vérification finale avec require.resolve (plus fiable que vérifier le dossier)
echo ""
echo "✅ Vérification finale des dépendances critiques:"
if node -e "require.resolve('@vscode/test-web')" 2>/dev/null; then
    echo "  ✓ @vscode/test-web (résolu: $(node -e "console.log(require.resolve('@vscode/test-web'))"))"
else
    echo "  ✗ @vscode/test-web MANQUANT (ne peut pas être résolu)"
fi

if node -e "require.resolve('rimraf')" 2>/dev/null; then
    echo "  ✓ rimraf (résolu: $(node -e "console.log(require.resolve('rimraf'))"))"
else
    echo "  ✗ rimraf MANQUANT (ne peut pas être résolu)"
fi

# Démarrer le serveur
echo ""
echo "🌐 Démarrage du serveur Node.js..."
exec node server.js

