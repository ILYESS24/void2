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
        mkdir -p node_modules/@vscode/test-web || true
        cd node_modules/@vscode/test-web || exit 1
        PACK_FILE=$(npm pack @vscode/test-web 2>&1 | grep "\.tgz$" | tail -1)
        if [ -f "$PACK_FILE" ]; then
            echo "   ✓ Fichier pack téléchargé: $PACK_FILE"
            echo "   📦 Extraction en cours..."
            tar -xzf "$PACK_FILE" --strip-components=1 2>&1 | head -5 || {
                echo "   ⚠️ Erreur lors de l'extraction tar"
            }
            rm -f "$PACK_FILE"
            if [ -f "package.json" ]; then
                echo "   ✓ Extraction réussie - package.json trouvé"
                echo "   📄 Contenu du package:"
                ls -la | head -10
            else
                echo "   ✗ package.json introuvable après extraction"
            fi
        else
            echo "   ✗ Fichier pack non trouvé: $PACK_FILE"
            echo "   📋 Liste des fichiers tgz:"
            ls -la *.tgz 2>/dev/null || echo "      (aucun fichier tgz)"
        fi
        cd "$OLDPWD" || cd - > /dev/null || true
    fi

    # Vérifier après extraction manuelle et forcer la résolution
    if [ -d "node_modules/@vscode/test-web" ] && [ -f "node_modules/@vscode/test-web/package.json" ]; then
        echo "   ✅ Installation manuelle réussie!"
        # Forcer la reconstruction du cache de modules Node.js
        echo "   🔄 Reconstruction du cache de résolution..."
        # Créer un lien symbolique si nécessaire ou forcer le refresh
        node -e "delete require.cache[require.resolve('module')]; console.log('Cache nettoyé')" 2>/dev/null || true
        # Vérifier avec require.resolve
        if node -e "require.resolve('@vscode/test-web')" 2>/dev/null; then
            echo "   ✅ Package résolu correctement après extraction"
        else
            echo "   ⚠️ Package installé mais ne peut pas être résolu - tentative de vérification directe..."
            # Vérifier le chemin direct
            if [ -f "node_modules/@vscode/test-web/dist/index.js" ] || [ -f "node_modules/@vscode/test-web/index.js" ]; then
                echo "   ✓ Fichier principal trouvé, package devrait fonctionner"
            else
                echo "   ✗ Fichier principal non trouvé"
                cat node_modules/@vscode/test-web/package.json | grep -E '"main"|"module"|"exports"' | head -3 || true
            fi
        fi
    fi

    # Attendre un peu pour que npm termine
    sleep 3
else
    echo "✅ @vscode/test-web déjà présent"
fi

echo "Vérification de rimraf..."
if ! node -e "require.resolve('rimraf')" 2>/dev/null; then
    echo "⚠️ rimraf manquant, installation..."
    npm install rimraf --legacy-peer-deps --save-prod --force --ignore-scripts 2>&1 | tail -10 || {
        echo "⚠️ Installation avec erreurs, mais on continue..."
    }
    sleep 1
else
    echo "✅ rimraf déjà présent"
fi

echo "Vérification de event-stream..."
if ! node -e "require.resolve('event-stream')" 2>/dev/null; then
    echo "⚠️ event-stream manquant, installation..."
    npm install event-stream@3.3.4 --legacy-peer-deps --save-prod --force --ignore-scripts 2>&1 | tail -10 || {
        echo "⚠️ Installation avec erreurs, mais on continue..."
    }
    # Attendre un peu pour que npm termine
    sleep 2
else
    echo "✅ event-stream déjà présent"
fi

echo "Vérification de gulp..."
if ! node -e "require.resolve('gulp')" 2>/dev/null; then
    echo "⚠️ gulp manquant, installation..."

    # Vérifier si le dossier existe avant installation
    if [ -d "node_modules/gulp" ]; then
        echo "   📁 Dossier existe mais ne peut pas être résolu, nettoyage..."
        rm -rf node_modules/gulp
    fi

    # Essayer d'abord l'installation npm normale
    echo "   📦 Tentative d'installation npm normale..."
    npm install gulp@4.0.0 --legacy-peer-deps --force --ignore-scripts --save-prod 2>&1 | tail -20 || true

    # Vérifier si installé après
    echo "   🔍 Vérification post-installation npm..."
    if [ -d "node_modules/gulp" ] && [ -f "node_modules/gulp/package.json" ]; then
        echo "   ✓ Dossier créé: node_modules/gulp"
        # Vérifier si résolvable maintenant
        if node -e "require.resolve('gulp')" 2>/dev/null; then
            echo "   ✅ gulp résolu après installation npm"
        else
            echo "   ⚠️ gulp installé mais non résolvable, essai réinstallation complète..."
            # Réinstaller gulp avec toutes ses dépendances
            rm -rf node_modules/gulp
            npm install gulp@4.0.0 --legacy-peer-deps --force --ignore-scripts --save-prod 2>&1 | tail -20 || {
                echo "   ⚠️ Réinstallation échouée, essai extraction manuelle..."
                # Fallback à l'extraction manuelle + installation des dépendances
                mkdir -p node_modules/gulp || true
                cd node_modules/gulp || exit 1
                echo "   📦 Téléchargement du package gulp..."
                PACK_OUTPUT=$(npm pack gulp@4.0.0 2>&1)
                echo "$PACK_OUTPUT"
                PACK_FILE=$(echo "$PACK_OUTPUT" | grep "\.tgz$" | tail -1 | xargs)
                if [ -n "$PACK_FILE" ] && [ -f "$PACK_FILE" ]; then
                    echo "   ✓ Fichier pack trouvé: $PACK_FILE"
                    echo "   📦 Extraction en cours..."
                    tar -xzf "$PACK_FILE" --strip-components=1 2>&1 | head -10 || {
                        echo "   ⚠️ Erreur lors de l'extraction tar"
                    }
                    rm -f "$PACK_FILE"
                    if [ -f "package.json" ]; then
                        echo "   ✓ Extraction réussie - package.json trouvé"
                        echo "   📦 Installation des dépendances de gulp..."
                        cd "$OLDPWD" || cd - > /dev/null || true
                        # Installer les dépendances de gulp
                        npm install --legacy-peer-deps --force --ignore-scripts --save-prod --package-lock-only 2>/dev/null || true
                        # Essayer d'installer les dépendances manuellement
                        if [ -f "node_modules/gulp/package.json" ]; then
                            DEPS=$(cat node_modules/gulp/package.json | grep -A 100 '"dependencies"' | grep -E '^\s*"' | head -20 | sed 's/.*"\([^"]*\)":.*/\1/' | tr '\n' ' ')
                            if [ -n "$DEPS" ]; then
                                echo "   📦 Installation des dépendances: $DEPS"
                                npm install $DEPS --legacy-peer-deps --force --ignore-scripts --save-prod 2>&1 | tail -10 || true
                            fi
                        fi
                    else
                        echo "   ✗ package.json introuvable après extraction"
                        cd "$OLDPWD" || cd - > /dev/null || true
                    fi
                else
                    echo "   ✗ Fichier pack non trouvé ou invalide"
                    cd "$OLDPWD" || cd - > /dev/null || true
                fi
            }
        fi
    else
        echo "   ✗ Dossier absent après installation npm"
        echo "   📋 Contenu de node_modules (recherche gulp):"
        ls -la node_modules/ | grep -i gulp || echo "      (aucun dossier gulp)"
        echo "   🔄 Essai réinstallation complète de gulp..."
        # Réinstaller avec npm pour avoir toutes les dépendances
        npm install gulp@4.0.0 --legacy-peer-deps --force --ignore-scripts --save-prod 2>&1 | tail -20 || true
    fi

    # Vérifier que les dépendances de gulp sont installées
    if [ -f "node_modules/gulp/package.json" ]; then
        echo "   🔍 Vérification des dépendances de gulp..."
        # Lire les dépendances de gulp en extrayant correctement les noms de packages
        # Utiliser jq si disponible, sinon parser avec sed/grep
        if command -v jq >/dev/null 2>&1; then
            GULP_DEPS=$(cat node_modules/gulp/package.json | jq -r '.dependencies | keys[]' 2>/dev/null || true)
        else
            # Parser manuellement en extrayant les noms entre guillemets
            GULP_DEPS=$(cat node_modules/gulp/package.json | grep -A 100 '"dependencies"' | grep -E '^\s*"[^"]+":' | sed 's/.*"\([^"]*\)":.*/\1/' | grep -v "^dependencies$" | head -20 || true)
        fi
        if [ -n "$GULP_DEPS" ]; then
            for DEP in $GULP_DEPS; do
                # Ignorer les chaînes invalides
                if [ -n "$DEP" ] && [ "$DEP" != "dependencies" ] && [ "$DEP" != "devDependencies" ] && echo "$DEP" | grep -qE '^[a-zA-Z0-9@/-]+$'; then
                    if ! node -e "require.resolve('$DEP')" 2>/dev/null; then
                        echo "   ⚠️ Dépendance manquante: $DEP"
                        npm install "$DEP" --legacy-peer-deps --force --ignore-scripts --save-prod 2>&1 | tail -5 || true
                    fi
                fi
            done
        fi
    fi

    # Vérification finale avec retry
    echo "   🔄 Vérification finale avec retry..."
    for i in 1 2 3; do
        if node -e "require.resolve('gulp')" 2>/dev/null; then
            echo "   ✅ gulp résolu avec succès (tentative $i)"
            # Vérifier aussi que gulp peut charger ses dépendances
            if node -e "const g = require('gulp'); console.log('OK')" 2>/dev/null; then
                echo "   ✅ gulp peut charger correctement"
            else
                echo "   ⚠️ gulp résolu mais ne peut pas charger (dépendances manquantes?)"
            fi
            break
        else
            if [ $i -lt 3 ]; then
                echo "   ⏳ Attente avant retry ($i/3)..."
                sleep 1
            else
                echo "   ⚠️ gulp toujours non résolvable après toutes les tentatives"
                # Dernière vérification : est-ce que le dossier existe ?
                if [ -d "node_modules/gulp" ] && [ -f "node_modules/gulp/package.json" ]; then
                    echo "   ✓ Dossier et package.json existent mais module non résolvable"
                fi
            fi
        fi
    done

    sleep 1
else
    echo "✅ gulp déjà présent"
fi

echo "Vérification de gulp-rename..."
if ! node -e "require.resolve('gulp-rename')" 2>/dev/null; then
    echo "⚠️ gulp-rename manquant, installation..."
    npm install gulp-rename@1.2.0 --legacy-peer-deps --no-save --force --ignore-scripts || {
        echo "⚠️ Installation avec erreurs, mais on continue..."
    }
    # Attendre un peu pour que npm termine
    sleep 2
else
    echo "✅ gulp-rename déjà présent"
fi

echo "Vérification de glob..."
if ! node -e "require.resolve('glob')" 2>/dev/null; then
    echo "⚠️ glob manquant, installation..."
    npm install glob@5.0.13 --legacy-peer-deps --save-prod --force --ignore-scripts 2>&1 | tail -10 || {
        echo "⚠️ Installation avec erreurs, mais on continue..."
    }
    sleep 1
else
    echo "✅ glob déjà présent"
fi

echo "Vérification de vinyl..."
if ! node -e "require.resolve('vinyl')" 2>/dev/null; then
    echo "⚠️ vinyl manquant, installation..."
    npm install vinyl@2.2.1 --legacy-peer-deps --save-prod --force --ignore-scripts 2>&1 | tail -10 || {
        echo "⚠️ Installation avec erreurs, mais on continue..."
    }
    sleep 1
else
    echo "✅ vinyl déjà présent"
fi

echo "Vérification de through2..."
if ! node -e "require.resolve('through2')" 2>/dev/null; then
    echo "⚠️ through2 manquant, installation..."
    npm install through2@4.0.2 --legacy-peer-deps --save-prod --force --ignore-scripts 2>&1 | tail -10 || {
        echo "⚠️ Installation avec erreurs, mais on continue..."
    }
    sleep 1
else
    echo "✅ through2 déjà présent"
fi

echo "Vérification de pump..."
if ! node -e "require.resolve('pump')" 2>/dev/null; then
    echo "⚠️ pump manquant, installation..."
    npm install pump@3.0.3 --legacy-peer-deps --save-prod --force --ignore-scripts 2>&1 | tail -10 || {
        echo "⚠️ Installation avec erreurs, mais on continue..."
    }
    sleep 1
else
    echo "✅ pump déjà présent"
fi

echo "Vérification de debounce..."
if ! node -e "require.resolve('debounce')" 2>/dev/null; then
    echo "⚠️ debounce manquant, installation..."
    npm install debounce@1.2.1 --legacy-peer-deps --save-prod --force --ignore-scripts 2>&1 | tail -10 || {
        echo "⚠️ Installation avec erreurs, mais on continue..."
    }
    sleep 1
else
    echo "✅ debounce déjà présent"
fi

echo "Vérification de gulp-filter..."
if ! node -e "require.resolve('gulp-filter')" 2>/dev/null; then
    echo "⚠️ gulp-filter manquant, installation..."
    npm install gulp-filter@5.1.0 --legacy-peer-deps --save-prod --force --ignore-scripts 2>&1 | tail -10 || {
        echo "⚠️ Installation avec erreurs, mais on continue..."
    }
    sleep 1
else
    echo "✅ gulp-filter déjà présent"
fi

echo "Vérification de gulp-buffer..."
if ! node -e "require.resolve('gulp-buffer')" 2>/dev/null; then
    echo "⚠️ gulp-buffer manquant, installation..."
    npm install gulp-buffer@0.0.2 --legacy-peer-deps --save-prod --force --ignore-scripts 2>&1 | tail -10 || {
        echo "⚠️ Installation avec erreurs, mais on continue..."
    }
    sleep 1
else
    echo "✅ gulp-buffer déjà présent"
fi

echo "Vérification de ternary-stream..."
if ! node -e "require.resolve('ternary-stream')" 2>/dev/null; then
    echo "⚠️ ternary-stream manquant, installation..."
    npm install ternary-stream@3.0.0 --legacy-peer-deps --save-prod --force --ignore-scripts 2>&1 | tail -10 || {
        echo "⚠️ Installation avec erreurs, mais on continue..."
    }
    sleep 1
else
    echo "✅ ternary-stream déjà présent"
fi

echo "Vérification de gulp-vinyl-zip..."
if ! node -e "require.resolve('gulp-vinyl-zip')" 2>/dev/null; then
    echo "⚠️ gulp-vinyl-zip manquant, installation..."
    npm install gulp-vinyl-zip@2.0.3 --legacy-peer-deps --save-prod --force --ignore-scripts 2>&1 | tail -10 || {
        echo "⚠️ Installation avec erreurs, mais on continue..."
    }
    sleep 1
else
    echo "✅ gulp-vinyl-zip déjà présent"
fi

echo "Vérification de jsonc-parser..."
if ! node -e "require.resolve('jsonc-parser')" 2>/dev/null; then
    echo "⚠️ jsonc-parser manquant, installation..."
    npm install jsonc-parser@3.2.0 --legacy-peer-deps --save-prod --force --ignore-scripts 2>&1 | tail -10 || {
        echo "⚠️ Installation avec erreurs, mais on continue..."
    }
    sleep 1
else
    echo "✅ jsonc-parser déjà présent"
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

if node -e "require.resolve('event-stream')" 2>/dev/null; then
    echo "  ✓ event-stream (résolu: $(node -e "console.log(require.resolve('event-stream'))"))"
else
    echo "  ✗ event-stream MANQUANT (ne peut pas être résolu)"
fi

if node -e "require.resolve('gulp')" 2>/dev/null; then
    echo "  ✓ gulp (résolu: $(node -e "console.log(require.resolve('gulp'))"))"
else
    echo "  ✗ gulp MANQUANT (ne peut pas être résolu)"
fi

if node -e "require.resolve('gulp-rename')" 2>/dev/null; then
    echo "  ✓ gulp-rename (résolu: $(node -e "console.log(require.resolve('gulp-rename'))"))"
else
    echo "  ✗ gulp-rename MANQUANT (ne peut pas être résolu)"
fi

if node -e "require.resolve('glob')" 2>/dev/null; then
    echo "  ✓ glob (résolu: $(node -e "console.log(require.resolve('glob'))"))"
else
    echo "  ✗ glob MANQUANT (ne peut pas être résolu)"
fi

if node -e "require.resolve('vinyl')" 2>/dev/null; then
    echo "  ✓ vinyl (résolu: $(node -e "console.log(require.resolve('vinyl'))"))"
else
    echo "  ✗ vinyl MANQUANT (ne peut pas être résolu)"
fi

if node -e "require.resolve('through2')" 2>/dev/null; then
    echo "  ✓ through2 (résolu: $(node -e "console.log(require.resolve('through2'))"))"
else
    echo "  ✗ through2 MANQUANT (ne peut pas être résolu)"
fi

if node -e "require.resolve('pump')" 2>/dev/null; then
    echo "  ✓ pump (résolu: $(node -e "console.log(require.resolve('pump'))"))"
else
    echo "  ✗ pump MANQUANT (ne peut pas être résolu)"
fi

if node -e "require.resolve('debounce')" 2>/dev/null; then
    echo "  ✓ debounce (résolu: $(node -e "console.log(require.resolve('debounce'))"))"
else
    echo "  ✗ debounce MANQUANT (ne peut pas être résolu)"
fi

if node -e "require.resolve('gulp-filter')" 2>/dev/null; then
    echo "  ✓ gulp-filter (résolu: $(node -e "console.log(require.resolve('gulp-filter'))"))"
else
    echo "  ✗ gulp-filter MANQUANT (ne peut pas être résolu)"
fi

if node -e "require.resolve('gulp-buffer')" 2>/dev/null; then
    echo "  ✓ gulp-buffer (résolu: $(node -e "console.log(require.resolve('gulp-buffer'))"))"
else
    echo "  ✗ gulp-buffer MANQUANT (ne peut pas être résolu)"
fi

if node -e "require.resolve('ternary-stream')" 2>/dev/null; then
    echo "  ✓ ternary-stream (résolu: $(node -e "console.log(require.resolve('ternary-stream'))"))"
else
    echo "  ✗ ternary-stream MANQUANT (ne peut pas être résolu)"
fi

if node -e "require.resolve('gulp-vinyl-zip')" 2>/dev/null; then
    echo "  ✓ gulp-vinyl-zip (résolu: $(node -e "console.log(require.resolve('gulp-vinyl-zip'))"))"
else
    echo "  ✗ gulp-vinyl-zip MANQUANT (ne peut pas être résolu)"
fi

if node -e "require.resolve('jsonc-parser')" 2>/dev/null; then
    echo "  ✓ jsonc-parser (résolu: $(node -e "console.log(require.resolve('jsonc-parser'))"))"
else
    echo "  ✗ jsonc-parser MANQUANT (ne peut pas être résolu)"
fi

# Démarrer le serveur
echo ""
echo "🌐 Démarrage du serveur Node.js..."
exec node server.js

