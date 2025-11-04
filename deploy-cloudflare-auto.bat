@echo off
setlocal enabledelayedexpansion

echo 🚀 Déploiement automatique sur Cloudflare Workers...
echo.

REM Vérifier que wrangler est installé
where wrangler >nul 2>&1
if %errorlevel% neq 0 (
    if not exist "node_modules\.bin\wrangler.cmd" (
        echo 📦 Installation de Wrangler...
        call npm install wrangler --save-dev
    )
)

set WRANGLER_CMD=
where wrangler >nul 2>&1
if %errorlevel% equ 0 (
    set WRANGLER_CMD=wrangler
) else if exist "node_modules\.bin\wrangler.cmd" (
    set WRANGLER_CMD=node_modules\.bin\wrangler.cmd
) else (
    set WRANGLER_CMD=npx wrangler
)

echo ✅ Wrangler trouvé: %WRANGLER_CMD%
echo.

REM Vérifier l'authentification
echo 🔐 Vérification de l'authentification Cloudflare...
%WRANGLER_CMD% whoami >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  Non authentifié. Démarrage de l'authentification...
    %WRANGLER_CMD% login
    echo.
)

echo ✅ Authentifié
echo.

REM Build
echo 🔨 Build de l'application...
call npm run build:cloudflare
if %errorlevel% neq 0 (
    echo ❌ Erreur lors du build
    exit /b 1
)
echo ✅ Build terminé
echo.

REM Déployer
echo 🚀 Déploiement du worker sur Cloudflare...
%WRANGLER_CMD% deploy
if %errorlevel% neq 0 (
    echo ❌ Erreur lors du déploiement
    exit /b 1
)

echo.
echo ✅ Déploiement réussi!
echo.
echo 💡 Prochaines étapes:
echo    1. Vérifiez que BACKEND_URL pointe vers votre serveur backend
echo    2. Testez l'URL du worker dans votre navigateur
echo    3. Configurez CORS dans votre backend si nécessaire

