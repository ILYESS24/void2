# Script PowerShell pour configurer Render MCP Server dans Cursor
# Usage: .\setup-cursor-mcp.ps1

Write-Host "Configuration Render MCP Server pour Cursor" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Chemin du fichier de configuration
$mcpPath = "$env:USERPROFILE\.cursor\mcp.json"
$cursorDir = Split-Path $mcpPath

# Creer le dossier .cursor s'il n'existe pas
if (-not (Test-Path $cursorDir)) {
    Write-Host "Creation du dossier .cursor..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $cursorDir -Force | Out-Null
    Write-Host "Dossier cree: $cursorDir" -ForegroundColor Green
}

# Demander la cle API
Write-Host ""
Write-Host "Etape 1: Cle API Render" -ForegroundColor Cyan
Write-Host "----------------------" -ForegroundColor Cyan
Write-Host "1. Allez sur: https://dashboard.render.com/account/api-keys" -ForegroundColor Yellow
Write-Host "2. Creez une nouvelle cle API" -ForegroundColor Yellow
Write-Host "3. Copiez-la (elle ne sera affichee qu'une fois!)" -ForegroundColor Yellow
Write-Host ""
$apiKey = Read-Host "Collez votre cle API Render ici"

if ([string]::IsNullOrWhiteSpace($apiKey)) {
    Write-Host "Erreur: La cle API est vide" -ForegroundColor Red
    exit 1
}

# Configuration JSON
$config = @{
    mcpServers = @{
        render = @{
            url = "https://mcp.render.com/mcp"
            headers = @{
                Authorization = "Bearer $apiKey"
            }
        }
    }
} | ConvertTo-Json -Depth 10

# Ecrire le fichier
Write-Host ""
Write-Host "Ecriture de la configuration..." -ForegroundColor Yellow
try {
    [System.IO.File]::WriteAllText($mcpPath, $config, [System.Text.Encoding]::UTF8)
    Write-Host "Configuration sauvegardee: $mcpPath" -ForegroundColor Green
} catch {
    Write-Host "Erreur lors de l'ecriture: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Configuration terminee!" -ForegroundColor Green
Write-Host ""
Write-Host "Prochaines etapes:" -ForegroundColor Cyan
Write-Host "   1. Redemarrez Cursor completement" -ForegroundColor Yellow
Write-Host "   2. Dans Cursor, definissez votre workspace:" -ForegroundColor Yellow
Write-Host "      Set my Render workspace to [NOM_DU_WORKSPACE]" -ForegroundColor White
Write-Host ""
Write-Host "Commandes de test:" -ForegroundColor Cyan
Write-Host "   - List my Render services" -ForegroundColor White
Write-Host "   - List my Render workspaces" -ForegroundColor White
Write-Host ""
Write-Host "Documentation: https://render.com/docs/mcp-server" -ForegroundColor Cyan
