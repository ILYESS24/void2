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

	if (!canResolve) {
		console.log(`⚠️ ${packageName} manquant, installation...`);
		try {
			// Nettoyer d'abord si le dossier existe mais n'est pas résolvable
			if (existsSync(nodeModulesPath)) {
				console.log(`🗑️ Nettoyage du dossier existant mais non résolvable...`);
				try {
					execSync(`rm -rf "${nodeModulesPath}"`, { stdio: 'ignore', cwd: APP_ROOT });
				} catch (cleanError) {
					console.log(`⚠️ Nettoyage partiel seulement`);
				}
			}

			// Utiliser --save-prod pour s'assurer que le package est bien installé
			console.log(`📦 Exécution: npm install ${packageName} --legacy-peer-deps --save-prod --force --ignore-scripts`);
			execSync(`npm install ${packageName} --legacy-peer-deps --save-prod --force --ignore-scripts`, {
				stdio: 'pipe',
				cwd: APP_ROOT,
				env: { ...process.env },
				maxBuffer: 10 * 1024 * 1024
			});

			// Forcer Node.js à recharger les chemins de modules
			try {
				// Nettoyer le cache de module
				const Module = require('module');
				// Réinitialiser le cache de résolution pour ce package
				const paths = Module._nodeModulePaths(APP_ROOT);
				// Ajouter explicitement le chemin si le dossier existe
				if (existsSync(nodeModulesPath)) {
					// Le package est installé, forcer la résolution via le chemin direct
					const path = require('path');
					const packageJsonPath = path.join(nodeModulesPath, 'package.json');
					if (existsSync(packageJsonPath)) {
						// Essayer de résoudre via le chemin parent
						const parentPath = path.dirname(nodeModulesPath);
						Module._resolveLookupPaths = function (request, parent, newReturn) {
							const paths = Module._nodeModulePaths(parent.filename || parent);
							return [packageName].includes(request) ? [[parentPath], paths] : [paths];
						};
					}
				}
			} catch (cacheError) {
				// Ignorer les erreurs de cache
			}

			// Attendre un peu pour que npm termine complètement
			execSync('sleep 1', { stdio: 'ignore' });

			// Vérifier après installation
			const exists = existsSync(nodeModulesPath);
			let canResolveNow = false;
			try {
				// Nettoyer le cache de require avant de réessayer
				delete require.cache[require.resolve('module')];
				require.resolve(packageName);
				canResolveNow = true;
			} catch { }

			if (exists || canResolveNow) {
				if (exists && canResolveNow) {
					console.log(`✅ ${packageName} installé avec succès (dossier ET résolution OK)`);
				} else if (exists) {
					console.log(`⚠️ ${packageName} : dossier trouvé mais non résolvable - tentative de résolution manuelle...`);
					// Essayer de forcer la résolution en ajoutant le chemin explicitement
					try {
						const packageJsonPath = require('path').join(nodeModulesPath, 'package.json');
						if (existsSync(packageJsonPath)) {
							const packageJson = require(packageJsonPath);
							const mainFile = packageJson.main || 'index.js';
							const mainPath = require('path').join(nodeModulesPath, mainFile);
							if (existsSync(mainPath)) {
								console.log(`✅ ${packageName} trouvé manuellement à ${mainPath}`);
								canResolveNow = true;
							}
						}
					} catch (manualError) {
						console.log(`⚠️ Résolution manuelle échouée: ${manualError.message}`);
					}
				} else if (canResolveNow) {
					console.log(`✅ ${packageName} installé avec succès (résolvable même sans dossier visible)`);
				}
			} else {
				console.log(`⚠️ ${packageName} : ni dossier ni résolution après installation`);
				console.log(`⚠️ Continuation malgré l'erreur - le package pourrait être disponible plus tard`);
			}
		} catch (error) {
			console.error(`❌ Erreur lors de l'installation de ${packageName}:`, error.message);
			// Ne pas arrêter immédiatement, essayer de continuer
			console.log(`⚠️ Tentative de continuation malgré l'erreur...`);
		}
	} else {
		console.log(`✅ ${packageName} déjà disponible`);
	}
}

// Vérifier et installer les dépendances critiques au démarrage
console.log('🔍 Vérification des dépendances critiques...');

// Liste des dépendances critiques nécessaires au runtime
const CRITICAL_DEPS = [
	'@vscode/test-web',
	'rimraf',
	'event-stream',
	'gulp',
	'gulp-rename',
	'gulp-filter',
	'gulp-buffer',
	'glob',
	'vinyl',
	'vinyl-fs',
	'through2',
	'pump',
	'fancy-log',
	'ansi-colors',
	'debounce',
	'ternary-stream',
	'gulp-vinyl-zip',
	'jsonc-parser'
];

// Vérifier et installer toutes les dépendances critiques
console.log(`📋 Liste des dépendances à vérifier: ${CRITICAL_DEPS.join(', ')}`);
for (const dep of CRITICAL_DEPS) {
	try {
		const location = require.resolve(dep);
		console.log(`✅ ${dep} déjà présent (${location})`);
	} catch (error) {
		console.log(`⚠️ ${dep} manquant (erreur: ${error.message}), installation...`);
		ensureDependency(dep);

		// Retry avec attente (réduit pour éviter les timeouts)
		let resolved = false;
		for (let i = 0; i < 3; i++) {
			try {
				// Nettoyer le cache avant chaque tentative
				delete require.cache[require.resolve('module')];
				const location = require.resolve(dep);
				console.log(`✅ ${dep} trouvé après installation (${location})`);
				resolved = true;
				break;
			} catch (err) {
				if (i < 2) {
					console.log(`⏳ Tentative ${i + 1}/3 pour ${dep}, attente...`);
					execSync('sleep 1', { stdio: 'ignore' });
				} else {
					console.error(`⚠️ ${dep} toujours non résolvable après ${i + 1} tentatives - continuation...`);
				}
			}
		}
		if (!resolved) {
			console.error(`⚠️ ${dep} non résolvable après installation - le serveur continuera mais pourrait échouer plus tard`);
		}
	}
}

// Vérifier et installer jsonc-parser explicitement (requis par build/lib/extensions.js)
console.log('🔍 Vérification finale de jsonc-parser...');
try {
	require.resolve('jsonc-parser');
	console.log(`✅ jsonc-parser déjà présent: ${require.resolve('jsonc-parser')}`);
} catch (error) {
	console.log('⚠️ jsonc-parser manquant, installation finale...');
	try {
		execSync('npm install jsonc-parser@3.2.0 --legacy-peer-deps --save-prod --force --ignore-scripts', {
			stdio: 'pipe',
			cwd: APP_ROOT,
			env: { ...process.env },
			maxBuffer: 10 * 1024 * 1024
		});
		execSync('sleep 1', { stdio: 'ignore' });
		// Vérifier après installation
		try {
			require.resolve('jsonc-parser');
			console.log(`✅ jsonc-parser installé avec succès`);
		} catch (err) {
			console.error(`⚠️ jsonc-parser toujours non résolvable après installation: ${err.message}`);
		}
	} catch (installError) {
		console.error(`❌ Erreur lors de l'installation de jsonc-parser: ${installError.message}`);
	}
}

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

