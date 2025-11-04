@echo off
REM Script pour tester le serveur (simulation Render - Windows)

echo 🚀 Test du serveur (simulation Render)...
echo ==========================================

REM Variables d'environnement comme Render
set NODE_ENV=production
set HOST=0.0.0.0
set PORT=10000
set NODE_OPTIONS=--max-old-space-size=4096

REM Exporter les variables pour Node.js
call set "NODE_ENV=production"
call set "HOST=0.0.0.0"
call set "PORT=10000"
call set "NODE_OPTIONS=--max-old-space-size=4096"

echo.
echo 📋 Configuration:
echo    NODE_ENV=%NODE_ENV%
echo    HOST=%HOST%
echo    PORT=%PORT%
echo    NODE_OPTIONS=%NODE_OPTIONS%
echo.

REM Vérifier que les fichiers compilés existent
if not exist "out" (
    echo ❌ Erreur: Le dossier 'out' n'existe pas.
    echo    Exécutez d'abord: test-render-build.bat
    pause
    exit /b 1
)

echo ✅ Fichiers compilés trouvés
echo.
echo 🌐 Démarrage du serveur...
echo    URL: http://localhost:%PORT%
echo.
echo    Appuyez sur Ctrl+C pour arrêter
echo.

node server.js

