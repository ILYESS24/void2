#!/bin/bash
# Script pour tester le serveur comme Render

echo "🚀 Test du serveur (simulation Render)..."
echo "=========================================="

# Variables d'environnement comme Render
export NODE_ENV=production
export HOST=0.0.0.0
export PORT=${PORT:-10000}
export NODE_OPTIONS="--max-old-space-size=4096"

echo "📋 Configuration:"
echo "   NODE_ENV=$NODE_ENV"
echo "   HOST=$HOST"
echo "   PORT=$PORT"
echo "   NODE_OPTIONS=$NODE_OPTIONS"
echo ""

# Vérifier que les fichiers compilés existent
if [ ! -d "out" ]; then
    echo "❌ Erreur: Le dossier 'out' n'existe pas."
    echo "   Exécutez d'abord: ./test-render-build.sh"
    exit 1
fi

echo "✅ Fichiers compilés trouvés"
echo ""
echo "🌐 Démarrage du serveur..."
echo "   URL: http://localhost:$PORT"
echo ""
echo "   Appuyez sur Ctrl+C pour arrêter"
echo ""

node server.js

