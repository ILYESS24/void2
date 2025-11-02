#!/bin/bash
# Ne pas arrêter sur erreur - on veut continuer même si des modules natifs échouent
set +e

echo "📦 Installation de gulp, typescript et @vscode/test-web d'abord..."
# Installer les dépendances critiques AVANT npm install --ignore-scripts
npm install -g gulp-cli 2>/dev/null || true
npm install gulp@4.0.0 typescript @vscode/test-web rimraf --legacy-peer-deps --save-dev

echo ""
echo "📦 Installation des autres dépendances npm (avec --ignore-scripts pour éviter modules natifs)..."
# Installer avec --ignore-scripts - continuer même si certains packages échouent
npm install --legacy-peer-deps --ignore-scripts 2>&1 | grep -v "native-keymap\|native-watchdog\|node-pty" || true

# Réessayer si nécessaire
if [ ! -d "node_modules/gulp" ] || [ ! -f "node_modules/typescript/lib/typescript.js" ]; then
    echo "Réinstallation des dépendances critiques..."
    npm install --legacy-peer-deps --ignore-scripts --force 2>&1 | grep -v "native-keymap\|native-watchdog\|node-pty" || true
fi

# Vérifier et réinstaller les dépendances critiques si manquantes après npm install
echo "🔍 Vérification des dépendances critiques..."
if [ ! -d "node_modules/gulp" ]; then
    echo "⚠️ Gulp perdu après npm install, réinstallation..."
    npm install gulp@4.0.0 --legacy-peer-deps --save-dev --force
fi

if [ ! -d "node_modules/@vscode/test-web" ]; then
    echo "⚠️ @vscode/test-web perdu après npm install, réinstallation..."
    npm install @vscode/test-web --legacy-peer-deps --save-dev --force
fi

if [ ! -d "node_modules/rimraf" ]; then
    echo "⚠️ rimraf perdu après npm install, réinstallation..."
    npm install rimraf --legacy-peer-deps --save-dev --force
fi

if [ ! -d "node_modules/typescript" ]; then
    echo "⚠️ typescript perdu après npm install, réinstallation..."
    npm install typescript --legacy-peer-deps --save-dev --force
fi

# Nettoyer les modules natifs qui ont échoué (optionnel, pour éviter les erreurs plus tard)
echo "🧹 Nettoyage des modules natifs problématiques..."
rm -rf node_modules/native-keymap 2>/dev/null || true
rm -rf node_modules/native-watchdog 2>/dev/null || true

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

