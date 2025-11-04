@echo off
setlocal enabledelayedexpansion

echo 🚀 DÉPLOIEMENT COMPLET CLOUDFLARE PAGES
echo ========================================
echo.

REM Nettoyer
echo 🧹 Nettoyage...
if exist dist rmdir /s /q dist
mkdir dist

REM Build
echo 🔨 Build en cours...
call npm run build:cloudflare
if %errorlevel% neq 0 (
    echo ❌ Erreur lors du build
    exit /b 1
)

REM Vérifier dist
if not exist dist (
    echo ❌ Erreur: dist/ n'existe pas
    exit /b 1
)

echo ✅ Build terminé!
echo.

REM Déployer
echo 🚀 Déploiement sur Cloudflare Pages...
wrangler pages deploy dist --project-name=void-code --commit-dirty=true
if %errorlevel% neq 0 (
    echo ❌ Erreur lors du déploiement
    exit /b 1
)

echo.
echo ✅ DÉPLOIEMENT TERMINÉ!
echo 🌐 URL: https://void-code.pages.dev

