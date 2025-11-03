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
 * Proxy les requêtes API vers le backend
 */
async function proxyToBackend(request, backendUrl, pathname) {
	const backendUrlObj = new URL(backendUrl);
	const targetUrl = new URL(pathname, backendUrl);
	
	// Copier les headers
	const headers = new Headers(request.headers);
	headers.set('Host', backendUrlObj.host);
	
	return fetch(targetUrl.toString(), {
		method: request.method,
		headers: headers,
		body: request.method !== 'GET' && request.method !== 'HEAD' ? request.body : null,
	});
}

/**
 * Gère les requêtes principales
 */
export default {
	async fetch(request, env, ctx) {
		const url = new URL(request.url);
		const pathname = url.pathname;

		// Routes API et WebSocket → proxy vers le backend
		if (pathname.startsWith('/api/') || 
		    pathname.startsWith('/vscode-remote-resource') ||
		    pathname.startsWith('/callback') ||
		    request.headers.get('Upgrade') === 'websocket') {
			const backendUrl = env.BACKEND_URL || BACKEND_URL;
			if (backendUrl && backendUrl !== 'BACKEND_URL') {
				if (request.headers.get('Upgrade') === 'websocket') {
					return handleWebSocket(request, backendUrl);
				}
				return proxyToBackend(request, backendUrl, pathname);
			}
			return new Response('Backend URL not configured', { status: 503 });
		}

		// Routes statiques → servir depuis KV ou assets
		if (isStaticPath(pathname) || pathname === '/' || pathname === '/index.html') {
			// Essayer de charger depuis KV Storage (si configuré)
			if (env.STATIC_ASSETS) {
				const key = pathname === '/' ? '/index.html' : pathname;
				const asset = await env.STATIC_ASSETS.get(key);
				if (asset) {
					return new Response(asset, {
						headers: {
							'Content-Type': getMimeType(key),
							'Cache-Control': 'public, max-age=31536000',
						},
					});
				}
			}

			// Fallback: servir depuis le workbench HTML
			if (pathname === '/' || pathname === '/index.html') {
				return new Response(getWorkbenchHTML(url.origin), {
					headers: {
						'Content-Type': 'text/html',
						'Cache-Control': 'public, max-age=3600',
					},
				});
			}

			// Autres fichiers statiques - retourner 404 si pas dans KV
			return new Response('File not found', { status: 404 });
		}

		// Route par défaut: servir le workbench
		return new Response(getWorkbenchHTML(url.origin), {
			headers: {
				'Content-Type': 'text/html',
				'Cache-Control': 'public, max-age=3600',
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
	
	<meta id="vscode-workbench-web-configuration" data-settings='{"remoteAuthority":"${origin}","webviewResourceRoot":"${baseUrl}","webviewCspSource":"${origin}","_wrapWebviewExtHostInIframe":true}'>
	
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

