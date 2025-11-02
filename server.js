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

	// Vérifier d'abord avec require.resolve (plus fiable)
	let canResolve = false;
	try {
		require.resolve(packageName);
		canResolve = true;
	} catch { }

	if (!canResolve && !existsSync(nodeModulesPath)) {
		console.log(`⚠️ ${packageName} manquant, installation...`);
		try {
			// Utiliser --ignore-scripts pour éviter la compilation des modules natifs
			console.log(`📦 Exécution: npm install ${packageName} --legacy-peer-deps --no-save --force --ignore-scripts`);
			execSync(`npm install ${packageName} --legacy-peer-deps --no-save --force --ignore-scripts`, {
				stdio: 'inherit',
				cwd: APP_ROOT,
				env: { ...process.env }
			});

			// Vérifier après installation
			if (existsSync(nodeModulesPath)) {
				console.log(`✅ ${packageName} installé avec succès (dossier trouvé)`);
			} else {
				console.log(`⚠️ ${packageName} : dossier non trouvé après installation`);
				// Essayer de nettoyer le cache et réinstaller
				console.log(`🔄 Nettoyage du cache npm et nouvelle tentative...`);
				try {
					execSync('npm cache clean --force', { stdio: 'ignore', cwd: APP_ROOT });
					execSync(`npm install ${packageName} --legacy-peer-deps --no-save --force --ignore-scripts`, {
						stdio: 'inherit',
						cwd: APP_ROOT
					});
				} catch (retryError) {
					console.error(`❌ Échec de la réinstallation: ${retryError.message}`);
				}
			}
		} catch (error) {
			console.error(`❌ Erreur lors de l'installation de ${packageName}:`, error.message);
			// Ne pas arrêter immédiatement, essayer de continuer
			console.log(`⚠️ Tentative de continuation malgré l'erreur...`);
		}
	} else if (canResolve) {
		console.log(`✅ ${packageName} déjà disponible`);
	}
}

// Vérifier et installer les dépendances critiques au démarrage
console.log('🔍 Vérification des dépendances critiques...');

// Essayer de résoudre d'abord, installer seulement si nécessaire
let testWebLocation;
try {
	testWebLocation = require.resolve('@vscode/test-web');
	console.log(`✅ @vscode/test-web déjà présent: ${testWebLocation}`);
} catch (error) {
	console.log('⚠️ @vscode/test-web non résolu, tentative d\'installation...');
	ensureDependency('@vscode/test-web');

	// Attendre un peu pour que npm termine (utiliser une boucle de retry)
	let resolved = false;
	for (let i = 0; i < 5; i++) {
		try {
			testWebLocation = require.resolve('@vscode/test-web');
			console.log(`✅ @vscode/test-web trouvé après installation: ${testWebLocation}`);
			resolved = true;
			break;
		} catch (err) {
			if (i < 4) {
				console.log(`⏳ Tentative ${i + 1}/5, attente...`);
				execSync('sleep 1', { stdio: 'ignore' });
			}
		}
	}

	if (!resolved) {
		console.error('❌ Impossible de résoudre @vscode/test-web après installation');
		console.error('💡 Vérification du contenu de node_modules/@vscode...');
		try {
			const fs = require('fs');
			const vscodeDir = `${APP_ROOT}/node_modules/@vscode`;
			if (existsSync(vscodeDir)) {
				const files = fs.readdirSync(vscodeDir);
				console.error(`   Contenu de node_modules/@vscode: ${files.join(', ')}`);
			} else {
				console.error(`   node_modules/@vscode n'existe pas`);
			}
			
			// Essayer d'installer manuellement avec extraction directe
			console.error('🔄 Tentative d\'installation manuelle finale...');
			const testWebDir = `${APP_ROOT}/node_modules/@vscode/test-web`;
			if (!existsSync(testWebDir)) {
				fs.mkdirSync(testWebDir, { recursive: true });
			}
			
			// Utiliser une commande shell pour extraire le package
			const { execSync } = require('child_process');
			try {
				process.chdir(testWebDir);
				const packOutput = execSync('npm pack @vscode/test-web', { encoding: 'utf8', stdio: 'pipe' });
				const packFile = packOutput.trim().split('\n').pop();
				if (packFile && packFile.endsWith('.tgz')) {
					execSync(`tar -xzf ${packFile} --strip-components=1`, { stdio: 'inherit' });
					fs.unlinkSync(packFile);
					console.error(`   ✅ Package extrait manuellement`);
					
					// Réessayer la résolution
					testWebLocation = require.resolve('@vscode/test-web');
					console.log(`✅ @vscode/test-web trouvé après extraction manuelle: ${testWebLocation}`);
					resolved = true;
				}
			} catch (manualError) {
				console.error(`   ❌ Échec de l'extraction manuelle: ${manualError.message}`);
			} finally {
				process.chdir(APP_ROOT);
			}
		} catch (e) {
			console.error(`   Erreur lors de la vérification: ${e.message}`);
		}
		
		if (!resolved) {
			process.exit(1);
		}
	}
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

