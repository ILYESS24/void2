#!/bin/bash
set -e

echo "📦 Installation des dépendances npm (sans scripts natifs)..."
npm install --legacy-peer-deps --ignore-scripts

echo ""
echo "✅ Installation explicite de gulp..."
# Installer gulp-cli globalement pour avoir la commande gulp
npm install -g gulp-cli 2>/dev/null || true

# Installer le package gulp localement SANS --ignore-scripts (gulp n'a pas de scripts natifs problématiques)
echo "Installation du package gulp..."
npm install gulp@4.0.0 --legacy-peer-deps --save-dev

# Vérifier que gulp est bien installé
if [ ! -d "node_modules/gulp" ]; then
    echo "⚠️ Gulp package non trouvé après installation, essai sans version..."
    npm install gulp --legacy-peer-deps --save-dev
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

