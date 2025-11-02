#!/bin/bash
set -e

echo "📦 Installation des dépendances npm (sans scripts natifs)..."
npm install --legacy-peer-deps --ignore-scripts

echo ""
echo "✅ Installation explicite de gulp..."
# Installer gulp globalement et localement pour être sûr
npm install -g gulp-cli 2>/dev/null || true
npm install gulp --legacy-peer-deps --ignore-scripts --save-dev --force

echo ""
echo "🔍 Vérification de gulp..."
which gulp || echo "Gulp CLI non trouvé globalement"
ls -la node_modules/.bin/gulp* 2>/dev/null || echo "Gulp bin non trouvé"
ls -la node_modules/gulp*/bin/gulp.js 2>/dev/null || echo "Gulp.js non trouvé"

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

