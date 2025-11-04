@echo off
REM Script pour simuler le build Render localement (Windows)

echo 🔍 Simulation du build Render...
echo ================================

REM Variables d'environnement comme Render
set NODE_ENV=production
set HOST=0.0.0.0
set PORT=10000
set NODE_OPTIONS=--max-old-space-size=4096

echo.
echo 📦 Étape 1/3: Installation des dépendances...
echo Commande: npm ci --legacy-peer-deps
call npm ci --legacy-peer-deps
if errorlevel 1 (
    echo ❌ Erreur lors de l'installation des dépendances
    exit /b 1
)

echo.
echo 🔨 Étape 2/3: Compilation web...
echo Commande: npm run compile-web
call npm run compile-web
if errorlevel 1 (
    echo ❌ Erreur lors de la compilation
    exit /b 1
)

echo.
echo 📥 Étape 3/3: Téléchargement des extensions...
echo Commande: npm run download-builtin-extensions
call npm run download-builtin-extensions
if errorlevel 1 (
    echo ❌ Erreur lors du téléchargement des extensions
    exit /b 1
)

echo.
echo ✅ Build terminé avec succès!
echo.
echo 🚀 Pour tester le serveur, exécutez:
echo    set PORT=10000 && node server.js
echo.
echo 🌐 Puis ouvrez: http://localhost:10000

pause

