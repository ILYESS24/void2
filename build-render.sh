#!/bin/bash
set -e

echo "📦 Installation des dépendances npm (sans scripts natifs)..."
# Installer avec --ignore-scripts pour éviter les modules natifs problématiques
npm install --legacy-peer-deps --ignore-scripts

echo ""
echo "✅ Vérification de gulp..."
# Vérifier si gulp est installé, sinon l'installer
if [ ! -f "node_modules/.bin/gulp" ] && [ ! -f "node_modules/gulp/bin/gulp.js" ]; then
    echo "⚠️ Gulp non trouvé, installation..."
    npm install gulp --legacy-peer-deps --ignore-scripts --save-dev
fi

echo ""
echo "🚀 Compilation web..."
# Utiliser npx gulp directement
npx gulp compile-web || node node_modules/gulp/bin/gulp.js compile-web || npm run compile-web

echo ""
echo "📥 Téléchargement des extensions..."
npm run download-builtin-extensions

echo ""
echo "✅ Build terminé avec succès!"

