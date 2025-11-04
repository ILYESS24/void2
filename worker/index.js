/**
 * Cloudflare Worker pour Void Code
 *
 * Ce worker sert les fichiers statiques de VS Code Web.
 * Note: Le backend (server.js) doit être hébergé séparément car
 * Cloudflare Workers ne peut pas exécuter un serveur Node.js complet.
 */

// Liste des fichiers statiques à servir
const STATIC_PATHS = [
	'/out/',
	'/extensions/',
	'/resources/',
	'/static/',
	'/node_modules/',
];

// Extensions MIME types
const MIME_TYPES = {
	'.html': 'text/html',
	'.js': 'application/javascript',
	'.mjs': 'application/javascript',
	'.css': 'text/css',
	'.json': 'application/json',
	'.png': 'image/png',
	'.jpg': 'image/jpeg',
	'.jpeg': 'image/jpeg',
	'.gif': 'image/gif',
	'.svg': 'image/svg+xml',
	'.ico': 'image/x-icon',
	'.woff': 'font/woff',
	'.woff2': 'font/woff2',
	'.ttf': 'font/ttf',
	'.eot': 'application/vnd.ms-fontobject',
	'.map': 'application/json',
	'.wasm': 'application/wasm',
};

// Backend URL (à configurer via variable d'environnement)
const BACKEND_URL = 'BACKEND_URL'; // Exemple: 'https://votre-app.onrender.com'

/**
 * Obtient le type MIME d'un fichier
 */
function getMimeType(pathname) {
	const ext = pathname.substring(pathname.lastIndexOf('.'));
	return MIME_TYPES[ext.toLowerCase()] || 'application/octet-stream';
}

/**
 * Vérifie si un chemin est une route statique
 */
function isStaticPath(pathname) {
	return STATIC_PATHS.some(prefix => pathname.startsWith(prefix));
}

/**
 * Gère les requêtes WebSocket (proxying vers le backend)
 */
async function handleWebSocket(request, backendUrl) {
	const upgradeHeader = request.headers.get('Upgrade');
	if (upgradeHeader !== 'websocket') {
		return new Response('Expected Upgrade: websocket', { status: 426 });
	}

	// Proxy WebSocket vers le backend
	const backendWsUrl = new URL(request.url);
	backendWsUrl.host = new URL(backendUrl).host;
	backendWsUrl.protocol = new URL(backendUrl).protocol === 'https:' ? 'wss:' : 'ws:';

	return fetch(backendWsUrl.toString(), {
		headers: request.headers,
		method: request.method,
		body: request.body,
	});
}

/**
 * Proxy les requêtes vers le backend (reverse proxy transparent)
 */
async function proxyToBackend(request, backendUrl, pathname) {
	try {
		const backendUrlObj = new URL(backendUrl);
		// Construire l'URL complète du backend
		const targetUrl = new URL(pathname + (new URL(request.url).search || ''), backendUrl);

		// Copier les headers mais modifier ceux nécessaires
		const headers = new Headers(request.headers);

		// Ne pas transférer le Host original (le backend verra le worker comme client)
		headers.delete('Host');
		headers.set('Host', backendUrlObj.host);

		// Préserver l'origine pour les requêtes CORS si nécessaire
		const origin = request.headers.get('Origin');
		if (origin) {
			headers.set('Origin', origin);
		} else {
			headers.set('Origin', backendUrlObj.origin);
		}

		// Forward le X-Forwarded-* headers pour le backend
		const forwardedHost = new URL(request.url).host;
		headers.set('X-Forwarded-Host', forwardedHost);
		headers.set('X-Forwarded-Proto', new URL(request.url).protocol.slice(0, -1));
		headers.set('X-Forwarded-For', request.headers.get('CF-Connecting-IP') || 'unknown');

		// Faire la requête vers le backend
		const response = await fetch(targetUrl.toString(), {
			method: request.method,
			headers: headers,
			body: request.method !== 'GET' && request.method !== 'HEAD' ? request.body : null,
		});

		// Créer une nouvelle réponse en préservant les headers du backend
		const newHeaders = new Headers(response.headers);

		// Ajouter/modifier les headers CORS pour que tout fonctionne depuis la même origine
		newHeaders.set('Access-Control-Allow-Origin', '*');
		newHeaders.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS, PATCH');
		newHeaders.set('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
		newHeaders.set('Access-Control-Allow-Credentials', 'true');

		// Supprimer les headers qui pourraient causer des problèmes
		newHeaders.delete('X-Frame-Options');
		newHeaders.delete('Content-Security-Policy');

		const newResponse = new Response(response.body, {
			status: response.status,
			statusText: response.statusText,
			headers: newHeaders,
		});

		return newResponse;
	} catch (error) {
		console.error('Proxy error:', error);
		return new Response(`Proxy error: ${error.message}`, {
			status: 502,
			headers: {
				'Content-Type': 'text/plain',
				'Access-Control-Allow-Origin': '*',
			},
		});
	}
}

/**
 * Gère les requêtes principales
 */
export default {
	async fetch(request, env, ctx) {
		const url = new URL(request.url);
		const pathname = url.pathname;

		// Gérer les requêtes OPTIONS (CORS preflight)
		if (request.method === 'OPTIONS') {
			return new Response(null, {
				headers: {
					'Access-Control-Allow-Origin': '*',
					'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
					'Access-Control-Allow-Headers': 'Content-Type, Authorization',
					'Access-Control-Max-Age': '86400',
				},
			});
		}

		// TOUT EST SUR CLOUDFLARE - Plus de proxy vers Render !
		// Le worker sert directement les fichiers statiques depuis KV

		// Servir depuis KV Storage (fichiers statiques compilés)
		if (env.STATIC_ASSETS) {
			const key = pathname === '/' ? '/index.html' : pathname;

			// Essayer la clé exacte
			let asset = await env.STATIC_ASSETS.get(key);

			// Si pas trouvé et que c'est un fichier statique, essayer avec le chemin complet
			if (!asset && isStaticPath(pathname)) {
				asset = await env.STATIC_ASSETS.get(pathname);
			}

			if (asset) {
				return new Response(asset, {
					headers: {
						'Content-Type': getMimeType(key),
						'Cache-Control': 'public, max-age=31536000',
						'Access-Control-Allow-Origin': '*',
					},
				});
			}
		}

		// Dernier recours: fallback HTML (ne devrait jamais arriver si backend est configuré)
		if (pathname === '/' || pathname === '/index.html') {
			return new Response(getWorkbenchHTML(url.origin), {
				headers: {
					'Content-Type': 'text/html',
					'Cache-Control': 'public, max-age=3600',
					'Access-Control-Allow-Origin': '*',
				},
			});
		}

		// 404 si rien ne correspond
		return new Response('Backend not configured or file not found', {
			status: 404,
			headers: {
				'Content-Type': 'text/plain',
				'Access-Control-Allow-Origin': '*',
			},
		});
	},
};

/**
 * Génère le HTML du workbench avec la bonne configuration
 */
function getWorkbenchHTML(origin) {
	const baseUrl = origin;

	return `<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8" />
	<meta name="mobile-web-app-capable" content="yes" />
	<meta name="apple-mobile-web-app-capable" content="yes" />
	<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no">

	<meta id="vscode-workbench-web-configuration" data-settings='{"remoteAuthority":"${origin}","webviewResourceRoot":"${baseUrl}","webviewCspSource":"${origin}","_wrapWebviewExtHostInIframe":true,"serverBasePath":"${baseUrl}"}'>

	<link rel="icon" href="${baseUrl}/resources/server/favicon.ico" type="image/x-icon" />
	<link rel="stylesheet" href="${baseUrl}/out/vs/code/browser/workbench/workbench.css">

	<script>
		const baseUrl = new URL('${baseUrl}', window.location.origin).toString();
		globalThis._VSCODE_FILE_ROOT = baseUrl + '/out/';
	</script>
	<script type="module" src="${baseUrl}/out/vs/code/browser/workbench/workbench.js"></script>
</head>
<body aria-label=""></body>
</html>`;
}

