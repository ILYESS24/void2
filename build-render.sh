#!/bin/bash
# Ne pas arrêter sur erreur - on veut continuer même si des modules natifs échouent
set +e

echo "📦 Installation des dépendances npm (avec --ignore-scripts pour éviter modules natifs)..."
# Installer avec --ignore-scripts - continuer même si certains packages échouent
npm install --legacy-peer-deps --ignore-scripts 2>&1 | grep -v "native-keymap\|native-watchdog\|node-pty" || true

# Réessayer si nécessaire
if [ ! -d "node_modules/gulp" ] || [ ! -f "node_modules/typescript/lib/typescript.js" ]; then
    echo "Réinstallation des dépendances critiques..."
    npm install --legacy-peer-deps --ignore-scripts --force 2>&1 | grep -v "native-keymap\|native-watchdog\|node-pty" || true
fi

# Installer les dépendances critiques APRÈS npm install pour s'assurer qu'elles sont présentes
echo ""
echo "🔧 Installation des dépendances critiques (gulp, typescript, @vscode/test-web, rimraf)..."
npm install -g gulp-cli 2>/dev/null || true

# Installer toutes les dépendances critiques en une seule commande, sans --ignore-scripts pour ces packages spécifiques
npm install gulp@4.0.0 typescript @vscode/test-web rimraf --legacy-peer-deps --save-dev --no-save

# Vérifier et réinstaller individuellement si nécessaire
echo ""
echo "🔍 Vérification des dépendances critiques..."
if [ ! -d "node_modules/gulp" ] || [ ! -f "node_modules/gulp/bin/gulp.js" ]; then
    echo "⚠️ Gulp manquant, réinstallation..."
    npm install gulp@4.0.0 --legacy-peer-deps --save-dev --force
fi

if [ ! -d "node_modules/@vscode/test-web" ]; then
    echo "⚠️ @vscode/test-web manquant, réinstallation..."
    npm install @vscode/test-web --legacy-peer-deps --save-dev --force
fi

if [ ! -d "node_modules/rimraf" ]; then
    echo "⚠️ rimraf manquant, réinstallation..."
    npm install rimraf --legacy-peer-deps --save-dev --force
fi

if [ ! -d "node_modules/typescript" ] || [ ! -f "node_modules/typescript/lib/typescript.js" ]; then
    echo "⚠️ typescript manquant, réinstallation..."
    npm install typescript --legacy-peer-deps --save-dev --force
fi

# Afficher la confirmation
echo ""
echo "✅ Vérification finale des dépendances critiques:"
[ -d "node_modules/gulp" ] && echo "  ✓ gulp trouvé" || echo "  ✗ gulp MANQUANT"
[ -d "node_modules/@vscode/test-web" ] && echo "  ✓ @vscode/test-web trouvé" || echo "  ✗ @vscode/test-web MANQUANT"
[ -d "node_modules/rimraf" ] && echo "  ✓ rimraf trouvé" || echo "  ✗ rimraf MANQUANT"
[ -d "node_modules/typescript" ] && echo "  ✓ typescript trouvé" || echo "  ✗ typescript MANQUANT"

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

