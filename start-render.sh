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

    # Installer directement dans node_modules sans --no-save
    echo "   📦 Installation FORCÉE (sans --no-save)..."
    npm install @vscode/test-web --legacy-peer-deps --force --ignore-scripts --save-dev 2>&1 | tail -20 || {
        echo "⚠️ Installation avec erreurs, tentative alternative..."
        # Si ça échoue, essayer avec npm ci pour forcer
        npm install @vscode/test-web@latest --legacy-peer-deps --force --ignore-scripts 2>&1 | tail -10 || true
    }
    
    # Vérifier si installé après
    echo "   🔍 Vérification post-installation..."
    if [ -d "node_modules/@vscode/test-web" ]; then
        echo "   ✓ Dossier créé: node_modules/@vscode/test-web"
        echo "   📄 Contenu du dossier:"
        ls -la node_modules/@vscode/test-web/ | head -10
        echo "   📦 package.json du package:"
        cat node_modules/@vscode/test-web/package.json | grep -E '"name"|"main"|"version"' | head -3 || true
    else
        echo "   ✗ Dossier toujours absent après installation"
        echo "   📋 Contenu de node_modules/@vscode:"
        ls -la node_modules/@vscode/ 2>/dev/null | head -20 || echo "      (vide ou n'existe pas)"
        echo "   🔄 Essai d'installation MANUELLE dans node_modules/@vscode/test-web..."
        mkdir -p node_modules/@vscode/test-web
        cd node_modules/@vscode/test-web
        npm pack @vscode/test-web 2>/dev/null && tar -xzf *.tgz --strip-components=1 2>/dev/null && rm -f *.tgz || true
        cd - > /dev/null
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

