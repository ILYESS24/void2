/**
 * Script pour uploader les fichiers statiques vers Cloudflare KV
 *
 * Usage:
 *   node upload-assets-to-kv.js
 *
 * Prérequis:
 *   1. Créer un KV namespace: wrangler kv:namespace create "STATIC_ASSETS"
 *   2. Ajouter l'ID dans wrangler.toml
 *   3. Installer: npm install wrangler
 */

import { execSync } from 'child_process';
import { readdir, stat, readFile } from 'fs/promises';
import { join, relative } from 'path';
import { createHash } from 'crypto';

const DIST_DIR = './dist';
const KV_NAMESPACE = 'STATIC_ASSETS';

/**
 * Hash un fichier pour vérifier les changements
 */
function hashFile(content) {
	return createHash('md5').update(content).digest('hex');
}

/**
 * Upload un fichier vers KV
 */
async function uploadToKV(filePath, key) {
	try {
		const content = await readFile(filePath);
		const hash = hashFile(content);

		console.log(`📤 Upload: ${key} (${(content.length / 1024).toFixed(2)} KB)`);

		// Utiliser wrangler pour uploader
		execSync(`npx wrangler kv:key put "${key}" --path "${filePath}" --binding ${KV_NAMESPACE}`, {
			stdio: 'inherit',
			cwd: process.cwd(),
		});

		return true;
	} catch (error) {
		console.error(`❌ Erreur upload ${key}:`, error.message);
		return false;
	}
}

/**
 * Parcourt récursivement un dossier et upload les fichiers
 */
async function uploadDirectory(dir, baseDir = dir) {
	const files = await readdir(dir);

	for (const file of files) {
		const filePath = join(dir, file);
		const stats = await stat(filePath);

		if (stats.isDirectory()) {
			await uploadDirectory(filePath, baseDir);
		} else {
			const key = '/' + relative(baseDir, filePath).replace(/\\/g, '/');
			await uploadToKV(filePath, key);
		}
	}
}

/**
 * Main
 */
async function main() {
	console.log('🚀 Upload des fichiers statiques vers Cloudflare KV...\n');

	if (!await stat(DIST_DIR).catch(() => null)) {
		console.error(`❌ Le dossier ${DIST_DIR} n'existe pas!`);
		console.log('💡 Exécutez d\'abord: npm run build:cloudflare');
		process.exit(1);
	}

	console.log(`📁 Dossier source: ${DIST_DIR}`);
	console.log(`🔑 KV Namespace: ${KV_NAMESPACE}\n`);

	await uploadDirectory(DIST_DIR);

	console.log('\n✅ Upload terminé!');
	console.log('\n💡 Prochaines étapes:');
	console.log('   1. Déployez le worker: npx wrangler deploy');
	console.log('   2. Les fichiers statiques seront servis depuis KV');
}

main().catch(console.error);

