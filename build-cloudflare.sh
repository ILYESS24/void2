#!/bin/bash
set -e

echo "🚀 Build pour Cloudflare Pages/Workers..."
echo "⚠️  Si le build échoue localement, connectez GitHub à Cloudflare Pages pour builder sur leurs serveurs"

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "package.json" ]; then
    echo "❌ Erreur: package.json non trouvé. Exécutez ce script depuis la racine du projet."
    exit 1
fi

# Installer les dépendances (seulement si pas déjà installées)
if [ ! -d "node_modules" ] || [ -z "$(ls -A node_modules)" ]; then
    echo "📦 Installation des dépendances..."
    npm ci --legacy-peer-deps || npm install --legacy-peer-deps
else
    echo "✅ Dépendances déjà installées, passage au build..."
fi

# Compiler le code source principal
echo "🔨 Compilation du code source principal..."
if command -v gulp >/dev/null 2>&1; then
    gulp compile-client || gulp transpile-client || echo "⚠️ compile-client échoué"
elif [ -f "node_modules/.bin/gulp" ]; then
    node_modules/.bin/gulp compile-client || node_modules/.bin/gulp transpile-client || echo "⚠️ compile-client échoué"
fi

# Compiler les extensions web
echo "🔨 Compilation des extensions web..."
if command -v gulp >/dev/null 2>&1; then
    gulp compile-web || echo "⚠️ compile-web échoué"
elif [ -f "node_modules/.bin/gulp" ]; then
    node_modules/.bin/gulp compile-web || echo "⚠️ compile-web échoué"
fi

# Créer le dossier dist pour Cloudflare Pages
echo "📁 Préparation du dossier dist..."
mkdir -p dist

# Copier les fichiers nécessaires pour le web
echo "📋 Copie des fichiers web..."

# Copier le workbench HTML
if [ -f "src/vs/code/browser/workbench/workbench.html" ]; then
    mkdir -p dist/vs/code/browser/workbench
    cp src/vs/code/browser/workbench/workbench.html dist/vs/code/browser/workbench/
    echo "✅ workbench.html copié"
fi

# Copier les fichiers compilés (out/)
if [ -d "out" ]; then
    echo "📦 Copie du dossier out/..."
    cp -r out dist/ || echo "⚠️ Erreur lors de la copie de out/"
fi

# Copier les extensions compilées
if [ -d "extensions" ]; then
    echo "📦 Copie des extensions compilées..."
    mkdir -p dist/extensions
    # Copier uniquement les extensions avec dist/browser
    find extensions -type d -path "*/dist/browser" -exec mkdir -p dist/{} \; 2>/dev/null || true
    find extensions -path "*/dist/browser/*" -type f -exec cp --parents {} dist/ \; 2>/dev/null || true
    echo "✅ Extensions copiées"
fi

# Créer un index.html de base
echo "📄 Création de index.html..."
cat > dist/index.html << 'EOF'
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Void Code - Cloudflare</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #1e1e1e;
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
        }
        .container {
            text-align: center;
            max-width: 600px;
            padding: 2rem;
        }
        h1 { margin: 0 0 1rem 0; }
        p { color: #ccc; line-height: 1.6; }
        .warning {
            background: #ff6b6b;
            color: white;
            padding: 1rem;
            border-radius: 8px;
            margin: 1rem 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Void Code</h1>
        <div class="warning">
            <strong>⚠️ Limitations Cloudflare</strong><br>
            VS Code Web nécessite un serveur Node.js pour les WebSockets et les extensions.
            Cloudflare Pages peut servir les fichiers statiques, mais le backend doit être hébergé ailleurs.
        </div>
        <p>
            Pour une utilisation complète, hébergez le serveur sur Render, Railway, ou un autre service Node.js,
            et configurez Cloudflare Pages pour servir uniquement les fichiers statiques.
        </p>
        <p>
            <strong>Note:</strong> Cette page est servie depuis Cloudflare Pages.
            Les fichiers statiques sont disponibles dans le dossier <code>dist/</code>.
        </p>
    </div>
</body>
</html>
EOF

echo "✅ Build terminé! Le dossier dist/ est prêt pour Cloudflare Pages."
echo ""
echo "📋 Prochaines étapes:"
echo "   1. Exécutez: wrangler pages deploy dist"
echo "   2. Ou connectez votre repo GitHub à Cloudflare Pages"
echo ""
echo "⚠️  Important: Le serveur backend doit être hébergé séparément (Render, Railway, etc.)"

