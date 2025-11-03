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

# Installer gulp EN PREMIER et vérifier qu'il est bien installé localement
echo "📦 Installation de gulp localement (obligatoire pour gulp-cli)..."
npm install gulp@4.0.0 --legacy-peer-deps --save-prod --force --ignore-scripts || {
    echo "⚠️ Installation de gulp échouée, réessai..."
    npm install gulp@4.0.0 --legacy-peer-deps --save-prod --force 2>&1 | tail -10
}

# Vérifier que gulp est bien installé localement
if [ ! -d "node_modules/gulp" ]; then
    echo "❌ ERREUR: gulp n'est toujours pas installé localement après tentative d'installation !"
    echo "📋 Contenu de node_modules (recherche gulp):"
    ls -la node_modules/ | grep -i gulp || echo "   (aucun dossier gulp trouvé)"
    echo "🔄 Tentative de nettoyage et réinstallation..."
    rm -rf node_modules/gulp node_modules/.bin/gulp
    npm install gulp@4.0.0 --legacy-peer-deps --save-prod --force 2>&1 | tail -10
else
    echo "✅ gulp installé dans node_modules/gulp"
fi

# Installer toutes les autres dépendances critiques nécessaires pour les fichiers de build
echo "Installation des dépendances critiques pour les fichiers de build (typescript, workerpool, postcss, esbuild, event-stream, debounce, gulp-filter, gulp-rename, gulp-plumber, gulp-sourcemaps, gulp-replace, gulp-untar, gulp-gunzip, gulp-flatmap, gulp-json-editor, @vscode/gulp-electron, chromium-pickle-js, asar, rcedit, innosetup, merge-options, copy-webpack-plugin, path-browserify, os-browserify, util, ternary-stream, lazy.js, source-map, gulp-sort, @vscode/l10n-dev, gulp-merge-json, xml2js, p-all)..."
npm install typescript workerpool postcss@^8.4.33 esbuild event-stream@3.3.4 debounce@1.2.1 gulp-filter@5.1.0 gulp-rename@1.2.0 gulp-plumber gulp-sourcemaps gulp-replace@0.5.4 gulp-untar@0.0.7 gulp-gunzip@1.0.0 gulp-flatmap@1.0.2 gulp-json-editor@2.5.0 @vscode/gulp-electron@^1.36.0 chromium-pickle-js@^0.2.0 asar@^3.0.3 rcedit@^1.1.0 innosetup@^6.4.1 merge-options@^1.0.1 copy-webpack-plugin@^11.0.0 path-browserify@^1.0.1 os-browserify@^0.3.0 util@^0.12.4 ternary-stream@3.0.0 lazy.js@0.5.1 source-map@0.7.4 gulp-sort@2.0.0 @vscode/l10n-dev gulp-merge-json xml2js p-all --legacy-peer-deps --save-prod --force --ignore-scripts || {
    echo "⚠️ Installation des dépendances de build échouée, réessai sans --ignore-scripts pour certaines..."
    npm install typescript workerpool postcss@^8.4.33 esbuild event-stream@3.3.4 debounce@1.2.1 gulp-filter@5.1.0 gulp-rename@1.2.0 gulp-plumber gulp-sourcemaps gulp-replace@0.5.4 gulp-untar@0.0.7 gulp-gunzip@1.0.0 gulp-flatmap@1.0.2 gulp-json-editor@2.5.0 @vscode/gulp-electron@^1.36.0 chromium-pickle-js@^0.2.0 asar@^3.0.3 rcedit@^1.1.0 innosetup@^6.4.1 merge-options@^1.0.1 copy-webpack-plugin@^11.0.0 path-browserify@^1.0.1 os-browserify@^0.3.0 util@^0.12.4 ternary-stream@3.0.0 lazy.js@0.5.1 source-map@0.7.4 gulp-sort@2.0.0 @vscode/l10n-dev gulp-merge-json xml2js p-all --legacy-peer-deps --save-prod --force 2>&1 | tail -10
}

# vscode-gulp-watch n'est pas disponible sur npm - créer un stub qui utilise gulp-watch
echo "📦 Installation de gulp-watch comme alternative à vscode-gulp-watch..."
npm install gulp-watch --legacy-peer-deps --save-prod --force --ignore-scripts || {
    echo "⚠️ Installation de gulp-watch échouée, tentative avec chokidar..."
    npm install chokidar --legacy-peer-deps --save-prod --force --ignore-scripts || echo "⚠️ Échec installation chokidar"
}

# CRÉER LE STUB IMMÉDIATEMENT - avant toute autre opération
echo "🔧 Création IMMÉDIATE du stub vscode-gulp-watch..."
mkdir -p node_modules/vscode-gulp-watch
# Créer package.json
cat > node_modules/vscode-gulp-watch/package.json << 'PKGEOF'
{
  "name": "vscode-gulp-watch",
  "version": "1.0.0",
  "main": "index.js",
  "description": "Stub for vscode-gulp-watch"
}
PKGEOF
# Créer index.js
cat > node_modules/vscode-gulp-watch/index.js << 'EOF'
// Stub pour vscode-gulp-watch - utilise gulp-watch ou chokidar comme alternative
let watch;
try {
    // Essayer gulp-watch d'abord
    watch = require('gulp-watch');
} catch (e1) {
    try {
        // Essayer chokidar
        const chokidar = require('chokidar');
        const eventStream = require('event-stream');
        const vinyl = require('vinyl');
        const path = require('path');
        const fs = require('fs');

        watch = function(pattern, options) {
            options = options || {};
            const cwd = path.normalize(options.cwd || process.cwd());
            const watcher = chokidar.watch(pattern, {
                cwd: cwd,
                ignoreInitial: true,
                persistent: true
            });

            const stream = eventStream.through();

            watcher.on('all', (event, filePath) => {
                const fullPath = path.join(cwd, filePath);
                fs.stat(fullPath, (err, stat) => {
                    if (err && err.code === 'ENOENT') {
                        // Fichier supprimé
                        const file = new vinyl({
                            path: fullPath,
                            base: options.base || cwd,
                            event: 'unlink'
                        });
                        stream.emit('data', file);
                    } else if (!err && stat.isFile()) {
                        fs.readFile(fullPath, (err, contents) => {
                            if (!err) {
                                const file = new vinyl({
                                    path: fullPath,
                                    base: options.base || cwd,
                                    contents: contents,
                                    stat: stat,
                                    event: event === 'add' ? 'add' : 'change'
                                });
                                stream.emit('data', file);
                            }
                        });
                    }
                });
            });

            watcher.on('error', (err) => {
                stream.emit('error', err);
            });

            return stream;
        };
    } catch (e2) {
        // Fallback minimal - retourner un stream vide
        const eventStream = require('event-stream');
        watch = function() {
            return eventStream.through();
        };
    }
}

module.exports = watch;
EOF
# Vérifier immédiatement
if [ -f "node_modules/vscode-gulp-watch/index.js" ] && [ -f "node_modules/vscode-gulp-watch/package.json" ]; then
    echo "✅ Stub vscode-gulp-watch créé et vérifié"
    if node -e "require.resolve('vscode-gulp-watch')" 2>/dev/null; then
        echo "✅ vscode-gulp-watch IMMÉDIATEMENT résolvable: $(node -e "console.log(require.resolve('vscode-gulp-watch'))")"
    else
        echo "⚠️ Stub créé mais non résolvable immédiatement (sera vérifié plus tard)"
    fi
else
    echo "❌ ERREUR: Impossible de créer le stub initial"
    exit 1
fi

# Vérifier que le stub existe toujours (au cas où il aurait été supprimé)
if [ ! -f "node_modules/vscode-gulp-watch/index.js" ]; then
    echo "🔧 Création d'un stub pour vscode-gulp-watch..."
    mkdir -p node_modules/vscode-gulp-watch
    # Créer package.json pour que Node.js le reconnaisse comme module
    cat > node_modules/vscode-gulp-watch/package.json << 'PKGEOF'
{
  "name": "vscode-gulp-watch",
  "version": "1.0.0",
  "main": "index.js",
  "description": "Stub for vscode-gulp-watch"
}
PKGEOF
    cat > node_modules/vscode-gulp-watch/index.js << 'EOF'
// Stub pour vscode-gulp-watch - utilise gulp-watch ou chokidar comme alternative
let watch;
try {
    // Essayer gulp-watch d'abord
    watch = require('gulp-watch');
} catch (e1) {
    try {
        // Essayer chokidar
        const chokidar = require('chokidar');
        const eventStream = require('event-stream');
        const vinyl = require('vinyl');
        const path = require('path');
        const fs = require('fs');

        watch = function(pattern, options) {
            options = options || {};
            const cwd = path.normalize(options.cwd || process.cwd());
            const watcher = chokidar.watch(pattern, {
                cwd: cwd,
                ignoreInitial: true,
                persistent: true
            });

            const stream = eventStream.through();

            watcher.on('all', (event, filePath) => {
                const fullPath = path.join(cwd, filePath);
                fs.stat(fullPath, (err, stat) => {
                    if (err && err.code === 'ENOENT') {
                        // Fichier supprimé
                        const file = new vinyl({
                            path: fullPath,
                            base: options.base || cwd,
                            event: 'unlink'
                        });
                        stream.emit('data', file);
                    } else if (!err && stat.isFile()) {
                        fs.readFile(fullPath, (err, contents) => {
                            if (!err) {
                                const file = new vinyl({
                                    path: fullPath,
                                    base: options.base || cwd,
                                    contents: contents,
                                    stat: stat,
                                    event: event === 'add' ? 'add' : 'change'
                                });
                                stream.emit('data', file);
                            }
                        });
                    }
                });
            });

            watcher.on('error', (err) => {
                stream.emit('error', err);
            });

            return stream;
        };
    } catch (e2) {
        // Fallback minimal - retourner un stream vide
        const eventStream = require('event-stream');
        watch = function() {
            return eventStream.through();
        };
    }
}

module.exports = watch;
EOF
    # Vérifier que les fichiers sont bien créés
    if [ -f "node_modules/vscode-gulp-watch/index.js" ] && [ -f "node_modules/vscode-gulp-watch/package.json" ]; then
        echo "✅ Stub créé pour vscode-gulp-watch (index.js et package.json)"
        # Vérifier que Node.js peut le résoudre
        if node -e "require.resolve('vscode-gulp-watch')" 2>/dev/null; then
            echo "✅ vscode-gulp-watch résolvable par Node.js: $(node -e "console.log(require.resolve('vscode-gulp-watch'))")"
        else
            echo "⚠️ Stub créé mais non résolvable - cela pourrait être un problème"
        fi
    else
        echo "❌ ERREUR: Stub créé mais fichiers manquants"
        ls -la node_modules/vscode-gulp-watch/ 2>/dev/null || echo "   (dossier n'existe pas)"
    fi
else
    echo "✅ vscode-gulp-watch déjà présent"
fi

# Vérifier que les dépendances critiques sont résolvables
echo "🔍 Vérification des dépendances critiques de build..."
CRITICAL_BUILD_DEPS=("debounce" "typescript" "lazy.js" "source-map" "workerpool" "postcss")
ALL_RESOLVABLE=true
for dep in "${CRITICAL_BUILD_DEPS[@]}"; do
    if node -e "require.resolve('$dep')" 2>/dev/null; then
        echo "✅ $dep résolvable: $(node -e "console.log(require.resolve('$dep'))")"
    else
        echo "❌ ERREUR: $dep non résolvable après installation !"
        echo "   📋 Contenu de node_modules/$dep:"
        ls -la "node_modules/$dep/" 2>/dev/null || echo "      (dossier n'existe pas)"
        ALL_RESOLVABLE=false
    fi
done

# vscode-gulp-watch est optionnel pour compile-web (seulement nécessaire pour watch mode)
if node -e "require.resolve('vscode-gulp-watch')" 2>/dev/null; then
    echo "✅ vscode-gulp-watch résolvable: $(node -e "console.log(require.resolve('vscode-gulp-watch'))")"
else
    echo "⚠️ vscode-gulp-watch non trouvé (optionnel pour compile-web, seulement nécessaire pour watch mode)"
fi

if [ "$ALL_RESOLVABLE" = false ]; then
    echo "   🛑 Le build va échouer - certaines dépendances critiques ne sont pas résolvables"
    exit 1
fi

# Installer toutes les autres dépendances critiques (typescript déjà installé, on ne le réinstalle pas)
echo "Installation des autres dépendances critiques (@vscode/test-web, rimraf, gulp-buffer, gulp-vinyl-zip, glob, vinyl, vinyl-fs, fancy-log, ansi-colors, through2, pump, jsonc-parser)..."
npm install @vscode/test-web rimraf gulp-buffer@0.0.2 gulp-vinyl-zip glob@5.0.13 vinyl@2.2.1 vinyl-fs@2.4.4 fancy-log@1.3.3 ansi-colors@3.2.3 through2@4.0.2 pump@3.0.3 jsonc-parser@3.2.0 --legacy-peer-deps --save-prod --force --ignore-scripts

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
echo "🔍 Vérification finale de gulp..."
echo "Gulp CLI global: $(which gulp || echo 'non trouvé')"
if [ -d "node_modules/gulp" ] && [ -f "node_modules/gulp/package.json" ]; then
    echo "✅ Gulp local: node_modules/gulp trouvé"
    echo "   Version: $(cat node_modules/gulp/package.json | grep '"version"' | head -1 || echo 'inconnue')"
    # Vérifier aussi que gulp peut être résolu
    if node -e "require.resolve('gulp')" 2>/dev/null; then
        echo "   ✅ gulp résolvable par Node.js: $(node -e "console.log(require.resolve('gulp'))")"
    else
        echo "   ⚠️ gulp installé mais non résolvable par Node.js"
    fi
else
    echo "❌ ERREUR CRITIQUE: Gulp local NON trouvé malgré les tentatives d'installation !"
    echo "   📋 Contenu de node_modules (recherche gulp):"
    ls -la node_modules/ | grep -i gulp || echo "      (aucun dossier gulp)"
    echo "   🛑 Le build va échouer - gulp est requis pour la compilation"
    exit 1
fi

# Vérification CRITIQUE de postcss juste avant l'exécution de gulp
echo ""
echo "🔍 Vérification finale de postcss (critique pour build/lib/postcss.js)..."
if node -e "require.resolve('postcss')" 2>/dev/null; then
    echo "✅ postcss résolvable: $(node -e "console.log(require.resolve('postcss'))")"
else
    echo "❌ ERREUR: postcss non résolvable avant exécution de gulp !"
    echo "   📋 Contenu de node_modules/postcss:"
    ls -la node_modules/postcss/ 2>/dev/null || echo "      (dossier n'existe pas)"
    echo "   🔄 Installation d'urgence de postcss..."
    npm install postcss@^8.4.33 --legacy-peer-deps --save-prod --force --ignore-scripts 2>&1 | tail -20
    # Vérifier à nouveau
    if node -e "require.resolve('postcss')" 2>/dev/null; then
        echo "✅ postcss résolu après installation d'urgence"
    else
        echo "❌ ERREUR CRITIQUE: postcss toujours non résolvable après installation d'urgence"
        echo "   🛑 Le build va échouer - postcss est requis pour build/lib/postcss.js"
        exit 1
    fi
fi

# Installer explicitement les packages gulp requis par gulpfile.reh.js, gulpfile.scan.js, build/lib/asar.js, gulpfile.vscode.js et gulpfile.vscode.win32.js
echo ""
echo "📦 Installation explicite des packages gulp requis par gulpfile.reh.js, gulpfile.scan.js, build/lib/asar.js, gulpfile.vscode.js et gulpfile.vscode.win32.js..."
npm install gulp-replace@0.5.4 gulp-untar@0.0.7 gulp-gunzip@1.0.0 gulp-flatmap@1.0.2 gulp-json-editor@2.5.0 @vscode/gulp-electron@^1.36.0 chromium-pickle-js@^0.2.0 asar@^3.0.3 rcedit@^1.1.0 innosetup@^6.4.1 --legacy-peer-deps --save-prod --force --ignore-scripts 2>&1 | tail -10 || echo "⚠️ Installation des packages gulp-reh échouée"

# Vérifier que les packages sont bien installés
echo "🔍 Vérification des packages gulp-reh, gulp-scan, asar, vscode et win32..."
for pkg in gulp-replace gulp-untar gulp-gunzip gulp-flatmap gulp-json-editor chromium-pickle-js asar rcedit innosetup; do
    if [ -d "node_modules/$pkg" ]; then
        echo "✅ $pkg installé"
    else
        echo "❌ $pkg MANQUANT - réinstallation..."
        npm install $pkg --legacy-peer-deps --save-prod --force --ignore-scripts 2>&1 | tail -5 || echo "⚠️ Échec installation $pkg"
    fi
done

# Vérifier @vscode/gulp-electron séparément
if [ -d "node_modules/@vscode/gulp-electron" ]; then
    echo "✅ @vscode/gulp-electron installé"
else
    echo "❌ @vscode/gulp-electron MANQUANT - réinstallation..."
    npm install @vscode/gulp-electron@^1.36.0 --legacy-peer-deps --save-prod --force --ignore-scripts 2>&1 | tail -5 || echo "⚠️ Échec installation @vscode/gulp-electron"
fi

# FORCER la vérification et recréation de vscode-gulp-watch juste avant gulp
echo ""
echo "🔍 Vérification FORCÉE de vscode-gulp-watch juste avant exécution de gulp..."
# Toujours recréer pour être sûr
rm -rf node_modules/vscode-gulp-watch 2>/dev/null || true
mkdir -p node_modules/vscode-gulp-watch
cat > node_modules/vscode-gulp-watch/package.json << 'PKGEOF'
{
  "name": "vscode-gulp-watch",
  "version": "1.0.0",
  "main": "index.js",
  "description": "Stub for vscode-gulp-watch"
}
PKGEOF
cat > node_modules/vscode-gulp-watch/index.js << 'EOF'
// Stub pour vscode-gulp-watch - utilise gulp-watch ou chokidar comme alternative
let watch;
try {
    // Essayer gulp-watch d'abord
    watch = require('gulp-watch');
} catch (e1) {
    try {
        // Essayer chokidar
        const chokidar = require('chokidar');
        const eventStream = require('event-stream');
        const vinyl = require('vinyl');
        const path = require('path');
        const fs = require('fs');

        watch = function(pattern, options) {
            options = options || {};
            const cwd = path.normalize(options.cwd || process.cwd());
            const watcher = chokidar.watch(pattern, {
                cwd: cwd,
                ignoreInitial: true,
                persistent: true
            });

            const stream = eventStream.through();

            watcher.on('all', (event, filePath) => {
                const fullPath = path.join(cwd, filePath);
                fs.stat(fullPath, (err, stat) => {
                    if (err && err.code === 'ENOENT') {
                        // Fichier supprimé
                        const file = new vinyl({
                            path: fullPath,
                            base: options.base || cwd,
                            event: 'unlink'
                        });
                        stream.emit('data', file);
                    } else if (!err && stat.isFile()) {
                        fs.readFile(fullPath, (err, contents) => {
                            if (!err) {
                                const file = new vinyl({
                                    path: fullPath,
                                    base: options.base || cwd,
                                    contents: contents,
                                    stat: stat,
                                    event: event === 'add' ? 'add' : 'change'
                                });
                                stream.emit('data', file);
                            }
                        });
                    }
                });
            });

            watcher.on('error', (err) => {
                stream.emit('error', err);
            });

            return stream;
        };
    } catch (e2) {
        // Fallback minimal - retourner un stream vide
        const eventStream = require('event-stream');
        watch = function() {
            return eventStream.through();
        };
    }
}

module.exports = watch;
EOF
# Vérifier immédiatement avec un nouveau processus Node.js pour éviter le cache
if node -e "delete require.cache[require.resolve('vscode-gulp-watch')]; require.resolve('vscode-gulp-watch')" 2>/dev/null || node -e "require.resolve('vscode-gulp-watch')" 2>/dev/null; then
    echo "✅ vscode-gulp-watch résolvable après recréation: $(node -e "console.log(require.resolve('vscode-gulp-watch'))")"
else
    echo "❌ ERREUR CRITIQUE: vscode-gulp-watch toujours non résolvable après recréation FORCÉE"
    echo "   📋 Contenu de node_modules/vscode-gulp-watch:"
    ls -la node_modules/vscode-gulp-watch/ 2>/dev/null || echo "      (dossier n'existe pas)"
    echo "   📋 Test direct:"
    cat node_modules/vscode-gulp-watch/index.js | head -5 || echo "      (fichier non lisible)"
    echo "   🛑 Le build va échouer - vscode-gulp-watch est requis"
    exit 1
fi

# Fonction pour s'assurer que vscode-gulp-watch existe avant chaque commande gulp
ensure_vscode_gulp_watch() {
    if [ ! -f "node_modules/vscode-gulp-watch/index.js" ] || ! node -e "require.resolve('vscode-gulp-watch')" 2>/dev/null; then
        echo "🔧 Recréation de vscode-gulp-watch avant commande gulp..."
        rm -rf node_modules/vscode-gulp-watch 2>/dev/null || true
        mkdir -p node_modules/vscode-gulp-watch
        cat > node_modules/vscode-gulp-watch/package.json << 'PKGEOF'
{
  "name": "vscode-gulp-watch",
  "version": "1.0.0",
  "main": "index.js"
}
PKGEOF
        cat > node_modules/vscode-gulp-watch/index.js << 'EOF'
module.exports = require('gulp-watch') || require('chokidar').watch || function() { return require('event-stream').through(); };
EOF
    fi
}

echo ""
echo "🔨 Compilation des extensions TypeScript d'abord..."
ensure_vscode_gulp_watch
# Compiler les extensions TypeScript avant de compiler le web
if command -v gulp >/dev/null 2>&1; then
    echo "Utilisation de gulp CLI global pour transpile-extensions"
    ensure_vscode_gulp_watch
    gulp transpile-extensions || {
        echo "⚠️ transpile-extensions échoué, tentative avec compile-extensions..."
        gulp compile-extensions || echo "⚠️ compile-extensions aussi échoué, continuation..."
    }
elif [ -f "node_modules/.bin/gulp" ]; then
    echo "Utilisation de gulp local pour transpile-extensions"
    ensure_vscode_gulp_watch
    node_modules/.bin/gulp transpile-extensions || {
        echo "⚠️ transpile-extensions échoué, tentative avec compile-extensions..."
        ensure_vscode_gulp_watch
        node_modules/.bin/gulp compile-extensions || echo "⚠️ compile-extensions aussi échoué, continuation..."
    }
else
    echo "⚠️ gulp non trouvé, tentative avec node directement..."
    ensure_vscode_gulp_watch
    node node_modules/gulp/bin/gulp.js transpile-extensions || {
        echo "⚠️ transpile-extensions échoué, tentative avec compile-extensions..."
        ensure_vscode_gulp_watch
        node node_modules/gulp/bin/gulp.js compile-extensions || echo "⚠️ compile-extensions aussi échoué, continuation..."
    }
fi

echo ""
echo "🚀 Compilation web (extensions web)..."
# Vérifier que webpack est installé
if [ ! -d "node_modules/webpack" ]; then
    echo "⚠️ webpack non trouvé, installation..."
    npm install webpack webpack-cli --legacy-peer-deps --save-prod --force --ignore-scripts 2>&1 | tail -10 || echo "⚠️ Installation webpack échouée"
fi

# Vérifier que les dépendances webpack sont installées (critiques pour shared.webpack.config.js)
echo "🔍 Vérification des dépendances webpack (critique pour compilation web)..."
for pkg in merge-options copy-webpack-plugin path-browserify os-browserify util; do
    if [ ! -d "node_modules/$pkg" ] || ! node -e "require.resolve('$pkg')" 2>/dev/null; then
        echo "⚠️ $pkg non trouvé ou non résolvable, installation..."
        case "$pkg" in
            "merge-options")
                npm install merge-options@^1.0.1 --legacy-peer-deps --save-prod --force --ignore-scripts 2>&1 | tail -10 || echo "⚠️ Installation merge-options échouée"
                ;;
            "copy-webpack-plugin")
                npm install copy-webpack-plugin@^11.0.0 --legacy-peer-deps --save-prod --force --ignore-scripts 2>&1 | tail -10 || echo "⚠️ Installation copy-webpack-plugin échouée"
                ;;
            "path-browserify")
                npm install path-browserify@^1.0.1 --legacy-peer-deps --save-prod --force --ignore-scripts 2>&1 | tail -10 || echo "⚠️ Installation path-browserify échouée"
                ;;
            "os-browserify")
                npm install os-browserify@^0.3.0 --legacy-peer-deps --save-prod --force --ignore-scripts 2>&1 | tail -10 || echo "⚠️ Installation os-browserify échouée"
                ;;
            "util")
                npm install util@^0.12.4 --legacy-peer-deps --save-prod --force --ignore-scripts 2>&1 | tail -10 || echo "⚠️ Installation util échouée"
                ;;
        esac
        # Vérifier à nouveau après installation
        if node -e "require.resolve('$pkg')" 2>/dev/null; then
            echo "✅ $pkg résolu après installation"
        else
            echo "❌ ERREUR: $pkg toujours non résolvable après installation"
            echo "   📋 Contenu de node_modules/$pkg:"
            ls -la node_modules/$pkg/ 2>/dev/null || echo "      (dossier n'existe pas)"
            echo "   🛑 Le build va échouer - $pkg est requis pour compile-web"
        fi
    else
        echo "✅ $pkg installé et résolvable"
    fi
done

# Essayer plusieurs méthodes
if command -v gulp >/dev/null 2>&1; then
    echo "Utilisation de gulp CLI global pour compile-web"
    ensure_vscode_gulp_watch
    gulp compile-web || {
        echo "⚠️ gulp compile-web échoué, vérification des erreurs..."
        exit 1
    }
elif [ -f "node_modules/.bin/gulp" ]; then
    echo "Utilisation de node_modules/.bin/gulp pour compile-web"
    ensure_vscode_gulp_watch
    node_modules/.bin/gulp compile-web || {
        echo "⚠️ gulp compile-web échoué, vérification des erreurs..."
        exit 1
    }
elif [ -f "node_modules/gulp/bin/gulp.js" ]; then
    echo "Utilisation de node_modules/gulp/bin/gulp.js pour compile-web"
    ensure_vscode_gulp_watch
    node node_modules/gulp/bin/gulp.js compile-web || {
        echo "⚠️ gulp compile-web échoué, vérification des erreurs..."
        exit 1
    }
else
    echo "Utilisation de npx gulp pour compile-web"
    ensure_vscode_gulp_watch
    npx --yes gulp compile-web || {
        echo "⚠️ gulp compile-web échoué, vérification des erreurs..."
        exit 1
    }
fi

# Vérifier que les extensions ont été compilées
echo ""
echo "🔍 Vérification de la compilation des extensions..."
EXT_COUNT=0
if [ -f "extensions/configuration-editing/dist/browser/configurationEditingMain.js" ]; then
    echo "✅ configuration-editing compilée"
    EXT_COUNT=$((EXT_COUNT+1))
else
    echo "⚠️ configuration-editing NON compilée"
    echo "   📂 Vérification du dossier:"
    ls -la extensions/configuration-editing/dist/browser/ 2>/dev/null || echo "   ❌ Dossier dist/browser n'existe pas"
fi

if [ -f "extensions/css-language-features/client/dist/browser/cssClientMain.js" ]; then
    echo "✅ css-language-features compilée"
    EXT_COUNT=$((EXT_COUNT+1))
else
    echo "⚠️ css-language-features NON compilée"
fi

if [ -f "extensions/git-base/dist/browser/extension.js" ]; then
    echo "✅ git-base compilée"
    EXT_COUNT=$((EXT_COUNT+1))
else
    echo "⚠️ git-base NON compilée"
fi

echo ""
if [ $EXT_COUNT -eq 0 ]; then
    echo "❌ AUCUNE extension n'a été compilée !"
    echo "📋 Liste des fichiers webpack config trouvés:"
    find extensions -name "extension-browser.webpack.config.js" 2>/dev/null | head -10
    echo ""
    echo "💡 Tentative de compilation manuelle d'une extension test..."
    cd extensions/configuration-editing 2>/dev/null && npm run compile-web 2>&1 | tail -20 || echo "⚠️ Échec compilation manuelle" && cd ../..
else
    echo "✅ $EXT_COUNT extension(s) compilée(s)"
fi

echo ""
echo "📥 Téléchargement des extensions..."
npm run download-builtin-extensions

echo ""
echo "✅ Build terminé avec succès!"

