/*---------------------------------------------------------------------------------------------
 * Serveur Render pour Void
 *--------------------------------------------------------------------------------------------*/

import { spawn, execSync } from 'child_process';
import { createRequire } from 'module';
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import { existsSync } from 'fs';

const require = createRequire(import.meta.url);
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const APP_ROOT = __dirname;

// Fonction pour installer une dépendance si elle est manquante
function ensureDependency(packageName) {
	const nodeModulesPath = `${APP_ROOT}/node_modules/${packageName}`;
	if (!existsSync(nodeModulesPath)) {
		console.log(`⚠️ ${packageName} manquant, installation...`);
		try {
			execSync(`npm install ${packageName} --legacy-peer-deps --no-save --force`, {
				stdio: 'inherit',
				cwd: APP_ROOT
			});
			console.log(`✅ ${packageName} installé avec succès`);
		} catch (error) {
			console.error(`❌ Erreur lors de l'installation de ${packageName}:`, error.message);
			process.exit(1);
		}
	}
}

// Vérifier et installer les dépendances critiques au démarrage
console.log('🔍 Vérification des dépendances critiques...');
ensureDependency('@vscode/test-web');

// Maintenant on peut résoudre le module
let testWebLocation;
try {
	testWebLocation = require.resolve('@vscode/test-web');
	console.log(`✅ @vscode/test-web trouvé: ${testWebLocation}`);
} catch (error) {
	console.error('❌ Impossible de résoudre @vscode/test-web:', error.message);
	process.exit(1);
}

// Render utilise le port depuis la variable d'environnement PORT
const HOST = process.env.HOST || '0.0.0.0';
const PORT = process.env.PORT || 10000;

console.log(`🚀 Starting Void web server on ${HOST}:${PORT}...`);

const serverArgs = [
	'--host', HOST,
	'--port', PORT.toString(),
	'--browserType', 'none', // Pas d'ouverture automatique du navigateur
	'--sourcesPath', APP_ROOT
];

// Ajouter les extensions si spécifié
if (process.env.EXTENSION_PATH) {
	serverArgs.push('--extensionPath', process.env.EXTENSION_PATH);
}

if (process.env.FOLDER_URI) {
	serverArgs.push('--folder-uri', process.env.FOLDER_URI);
}

console.log(`📦 Starting @vscode/test-web`);
console.log(`📍 Location: ${testWebLocation}`);
console.log(`⚙️  Arguments: ${serverArgs.join(' ')}`);

const proc = spawn(process.execPath, [testWebLocation, ...serverArgs], {
	env: { ...process.env },
	stdio: 'inherit'
});

proc.on('exit', (code) => {
	console.log(`❌ Server exited with code ${code}`);
	process.exit(code || 0);
});

process.on('SIGINT', () => {
	console.log('🛑 Received SIGINT, shutting down...');
	proc.kill();
	process.exit(128 + 2);
});

process.on('SIGTERM', () => {
	console.log('🛑 Received SIGTERM, shutting down...');
	proc.kill();
	process.exit(128 + 15);
});

// Gestion des erreurs
proc.on('error', (error) => {
	console.error('❌ Failed to start server:', error);
	process.exit(1);
});

console.log(`✅ Server process started (PID: ${proc.pid})`);

