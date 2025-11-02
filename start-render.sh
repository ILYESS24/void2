#!/bin/bash
# Script de démarrage pour Render qui installe les dépendances critiques au runtime

echo "🚀 Démarrage du serveur Render..."
echo "📦 Installation des dépendances critiques au runtime..."

# Installer les dépendances critiques si elles ne sont pas présentes
# Utiliser --ignore-scripts pour éviter la compilation des modules natifs
echo "Vérification de @vscode/test-web..."
if ! node -e "require.resolve('@vscode/test-web')" 2>/dev/null; then
    echo "⚠️ @vscode/test-web manquant, installation..."
    
    # Vérifier si le dossier existe avant installation
    if [ -d "node_modules/@vscode/test-web" ]; then
        echo "   📁 Dossier existe mais ne peut pas être résolu, nettoyage..."
        rm -rf node_modules/@vscode/test-web
    fi
    
    # Installer avec plus de verbosité
    echo "   📦 Installation en cours..."
    npm install @vscode/test-web --legacy-peer-deps --no-save --force --ignore-scripts 2>&1 | tail -20 || {
        echo "⚠️ Installation avec erreurs, mais on continue..."
    }
    
    # Vérifier si installé après
    echo "   🔍 Vérification post-installation..."
    if [ -d "node_modules/@vscode/test-web" ]; then
        echo "   ✓ Dossier créé: node_modules/@vscode/test-web"
        ls -la node_modules/@vscode/test-web/ | head -5
    else
        echo "   ✗ Dossier toujours absent après installation"
        echo "   📋 Contenu de node_modules/@vscode:"
        ls node_modules/@vscode/ 2>/dev/null || echo "      (vide ou n'existe pas)"
    fi
    
    # Essayer de nettoyer le cache npm et réinstaller
    if ! node -e "require.resolve('@vscode/test-web')" 2>/dev/null; then
        echo "   🔄 Nettoyage du cache npm et nouvelle tentative..."
        npm cache clean --force 2>/dev/null || true
        npm install @vscode/test-web --legacy-peer-deps --no-save --force --ignore-scripts 2>&1 | tail -10 || true
    fi
    
    # Attendre un peu pour que npm termine
    sleep 3
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

