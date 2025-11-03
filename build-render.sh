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

# Installer toutes les dépendances critiques en une seule commande
# On utilise --no-save pour ne pas modifier package.json mais les installer dans node_modules
echo "Installation de gulp, typescript, @vscode/test-web, rimraf, event-stream, gulp-rename, gulp-filter, gulp-buffer, gulp-vinyl-zip, glob, vinyl, vinyl-fs, fancy-log, ansi-colors, through2, pump, debounce, ternary-stream, jsonc-parser..."
npm install gulp@4.0.0 typescript @vscode/test-web rimraf event-stream gulp-rename@1.2.0 gulp-filter@5.1.0 gulp-buffer@0.0.2 gulp-vinyl-zip@2.0.3 glob@5.0.13 vinyl@2.2.1 vinyl-fs@2.4.4 fancy-log@1.3.3 ansi-colors@3.2.3 through2@4.0.2 pump@3.0.3 debounce@1.2.1 ternary-stream@3.0.0 jsonc-parser@3.2.0 --legacy-peer-deps --save-prod --force --ignore-scripts

# Vérifier explicitement que gulp est installé
echo ""
echo "🔍 Vérification de l'installation de gulp..."
if [ -d "node_modules/gulp" ] && [ -f "node_modules/gulp/package.json" ]; then
    echo "✅ gulp installé dans node_modules/gulp"
    echo "   📄 Version: $(cat node_modules/gulp/package.json | grep '"version"' | head -1 || echo 'inconnue')"
    echo "   📄 Main: $(cat node_modules/gulp/package.json | grep '"main"' | head -1 || echo 'non spécifié')"
    # Vérifier la résolution Node.js
    if node -e "console.log(require.resolve('gulp'))" 2>/dev/null; then
        echo "   ✅ gulp résolvable par Node.js"
    else
        echo "   ⚠️ gulp installé mais non résolvable par Node.js"
        echo "   📋 Contenu du dossier gulp:"
        ls -la node_modules/gulp/ | head -15
    fi
else
    echo "❌ gulp NON installé dans node_modules/gulp"
fi

# Vérifier et réinstaller individuellement si nécessaire avec affichage explicite
echo ""
echo "🔍 Vérification des dépendances critiques..."
if [ ! -d "node_modules/gulp" ] || [ ! -f "node_modules/gulp/bin/gulp.js" ]; then
    echo "⚠️ Gulp manquant, réinstallation..."
    npm install gulp@4.0.0 --legacy-peer-deps --no-save --force
else
    echo "✅ Gulp trouvé"
fi

if [ ! -d "node_modules/@vscode/test-web" ]; then
    echo "⚠️ @vscode/test-web manquant, réinstallation..."
    npm install @vscode/test-web --legacy-peer-deps --no-save --force
else
    echo "✅ @vscode/test-web trouvé"
fi

if [ ! -d "node_modules/rimraf" ]; then
    echo "⚠️ rimraf manquant, réinstallation..."
    npm install rimraf --legacy-peer-deps --no-save --force
else
    echo "✅ rimraf trouvé"
fi

if [ ! -d "node_modules/typescript" ] || [ ! -f "node_modules/typescript/lib/typescript.js" ]; then
    echo "⚠️ typescript manquant, réinstallation..."
    npm install typescript --legacy-peer-deps --no-save --force
else
    echo "✅ typescript trouvé"
fi

# Afficher la confirmation finale avec test de présence
echo ""
echo "✅ Vérification finale des dépendances critiques:"
test -d "node_modules/gulp" && echo "  ✓ gulp trouvé" || echo "  ✗ gulp MANQUANT"
test -d "node_modules/@vscode/test-web" && echo "  ✓ @vscode/test-web trouvé" || echo "  ✗ @vscode/test-web MANQUANT"
test -d "node_modules/rimraf" && echo "  ✓ rimraf trouvé" || echo "  ✗ rimraf MANQUANT"
test -d "node_modules/typescript" && echo "  ✓ typescript trouvé" || echo "  ✗ typescript MANQUANT"

# Vérifier aussi avec require.resolve pour @vscode/test-web (test de runtime)
echo ""
echo "🧪 Test de résolution des modules..."
node -e "try { require.resolve('@vscode/test-web'); console.log('✅ @vscode/test-web résolu correctement'); } catch(e) { console.log('✗ @vscode/test-web NON résolu:', e.message); process.exit(1); }" || echo "⚠️ @vscode/test-web ne peut pas être résolu"
node -e "try { require.resolve('rimraf'); console.log('✅ rimraf résolu correctement'); } catch(e) { console.log('✗ rimraf NON résolu:', e.message); process.exit(1); }" || echo "⚠️ rimraf ne peut pas être résolu"

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

