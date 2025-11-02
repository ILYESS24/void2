#!/bin/bash
set -e

echo "📦 Installation de gulp en premier (avant --ignore-scripts)..."
# Installer gulp AVANT npm install --ignore-scripts pour éviter les problèmes
npm install -g gulp-cli 2>/dev/null || true
npm install gulp@4.0.0 --legacy-peer-deps --save-dev

echo ""
echo "📦 Installation des autres dépendances npm (sans scripts natifs)..."
npm install --legacy-peer-deps --ignore-scripts

# Vérifier que gulp est toujours là après npm install
if [ ! -d "node_modules/gulp" ]; then
    echo "⚠️ Gulp perdu après npm install, réinstallation..."
    npm install gulp@4.0.0 --legacy-peer-deps --save-dev --force
fi

# Forcer la création du lien .bin si nécessaire
if [ ! -f "node_modules/.bin/gulp" ] && [ -d "node_modules/gulp" ]; then
    echo "Création du lien .bin pour gulp..."
    mkdir -p node_modules/.bin
    ln -s ../gulp/bin/gulp.js node_modules/.bin/gulp 2>/dev/null || true
fi

echo ""
echo "🔍 Vérification de gulp..."
echo "Gulp CLI: $(which gulp || echo 'non trouvé')"
if [ -d "node_modules/gulp" ]; then
    echo "✅ Gulp local: node_modules/gulp trouvé"
    ls -la node_modules/gulp/package.json
else
    echo "❌ Gulp local: non trouvé"
    echo "Contenu de node_modules (premiers fichiers):"
    ls node_modules/ | head -10
fi

echo ""
echo "🚀 Compilation web..."
# Essayer plusieurs méthodes
if command -v gulp >/dev/null 2>&1; then
    echo "Utilisation de gulp CLI global"
    gulp compile-web
elif [ -f "node_modules/.bin/gulp" ]; then
    echo "Utilisation de node_modules/.bin/gulp"
    node_modules/.bin/gulp compile-web
elif [ -f "node_modules/gulp/bin/gulp.js" ]; then
    echo "Utilisation de node_modules/gulp/bin/gulp.js"
    node node_modules/gulp/bin/gulp.js compile-web
else
    echo "Utilisation de npx gulp"
    npx --yes gulp compile-web
fi

echo ""
echo "📥 Téléchargement des extensions..."
npm run download-builtin-extensions

echo ""
echo "✅ Build terminé avec succès!"

