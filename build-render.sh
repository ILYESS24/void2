#!/bin/bash
set -e

echo "📦 Installation des dépendances npm (sans scripts natifs)..."
npm install --legacy-peer-deps --ignore-scripts

echo ""
echo "✅ Installation explicite de gulp..."
# Installer gulp-cli globalement pour avoir la commande gulp
npm install -g gulp-cli 2>/dev/null || true

# Installer le package gulp localement (nécessaire pour que gulp CLI fonctionne)
npm install gulp@4.0.0 --legacy-peer-deps --ignore-scripts --save-dev --force

# Vérifier que gulp est bien installé
if [ ! -d "node_modules/gulp" ]; then
    echo "⚠️ Gulp package non trouvé, réinstallation..."
    npm install gulp@4.0.0 --legacy-peer-deps --ignore-scripts --save-dev
fi

echo ""
echo "🔍 Vérification de gulp..."
echo "Gulp CLI: $(which gulp || echo 'non trouvé')"
echo "Gulp local: $(ls -d node_modules/gulp 2>/dev/null || echo 'non trouvé')"
ls -la node_modules/gulp/package.json 2>/dev/null || echo "⚠️ Gulp package.json non trouvé"

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

