#!/bin/bash
set -e

echo "📦 Installation des dépendances npm (sans scripts natifs)..."
# Installer avec --ignore-scripts pour éviter les modules natifs problématiques
# La version web n'a pas besoin de tous les modules natifs (native-keymap, etc.)
npm ci --legacy-peer-deps --ignore-scripts

echo ""
echo "🚀 Compilation web..."
npm run compile-web

echo ""
echo "📥 Téléchargement des extensions..."
npm run download-builtin-extensions

echo ""
echo "✅ Build terminé avec succès!"

