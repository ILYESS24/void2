/**
 * Script de déploiement simplifié pour Cloudflare Workers
 * Déploie directement le worker sans build complet
 */

import { execSync } from 'child_process';
import fs from 'fs';
import path from 'path';

console.log('🚀 Déploiement simplifié sur Cloudflare Workers...\n');

// Vérifier que wrangler est installé
let wranglerCmd = 'npx wrangler';
const isWindows = process.platform === 'win32';

try {
    if (fs.existsSync('node_modules/.bin/wrangler') || fs.existsSync('node_modules/.bin/wrangler.cmd')) {
        wranglerCmd = isWindows ? 'npx wrangler' : 'node_modules/.bin/wrangler';
    } else {
        console.log('📦 Installation de wrangler...');
        execSync('npm install wrangler --save-dev --legacy-peer-deps', { stdio: 'ignore' });
    }
} catch (e) {
    console.log('⚠️  Utilisation de npx wrangler...');
}

// Vérifier l'authentification
console.log('🔐 Vérification de l\'authentification...');
try {
    execSync(`${wranglerCmd} whoami`, { stdio: 'pipe' });
    console.log('✅ Authentifié\n');
} catch (e) {
    console.log('⚠️  Non authentifié. Lancement de l\'authentification...');
    execSync(`${wranglerCmd} login`, { stdio: 'inherit' });
}

// Vérifier que worker/index.js existe
if (!fs.existsSync('worker/index.js')) {
    console.error('❌ worker/index.js non trouvé!');
    process.exit(1);
}

// Déployer directement
console.log('🚀 Déploiement du worker...\n');
try {
    execSync(`${wranglerCmd} deploy`, { stdio: 'inherit' });
    console.log('\n✅ Déploiement réussi!');
    console.log('\n💡 Note: Assurez-vous que BACKEND_URL est configuré dans wrangler.toml');
} catch (e) {
    console.error('\n❌ Erreur lors du déploiement');
    process.exit(1);
}

