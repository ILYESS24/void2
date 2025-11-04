/**
 * Backend Worker pour Void Code sur Cloudflare
 * Remplace server.js pour fonctionner sur Cloudflare Workers
 */

// Configuration
const WORKBENCH_CONFIG = {
	remoteAuthority: 'cloudflare',
	webviewResourceRoot: '/',
	webviewCspSource: '/',
	wrapWebviewExtHostInIframe: true,
};

/**
 * Gère les requêtes WebSocket pour les extensions
 */
async function handleWebSocket(request) {
	// Cloudflare Workers supporte WebSockets nativement
	const upgradeHeader = request.headers.get('Upgrade');
	if (upgradeHeader !== 'websocket') {
		return new Response('Expected Upgrade: websocket', { status: 426 });
	}

	// Créer une paire WebSocket
	const webSocketPair = new WebSocketPair();
	const [client, server] = Object.values(webSocketPair);

	// Accepter la connexion WebSocket
	server.accept();

	// Gérer les messages (simplifié - nécessite une implémentation complète)
	server.addEventListener('message', (event) => {
		// Echo pour l'instant - à implémenter avec la logique d'extensions
		server.send(event.data);
	});

	return new Response(null, {
		status: 101,
		webSocket: client,
	});
}

/**
 * Gère les requêtes API
 */
async function handleAPI(request, pathname) {
	// Routes API basiques
	if (pathname === '/api/health') {
		return new Response(JSON.stringify({ status: 'ok', platform: 'cloudflare' }), {
			headers: { 'Content-Type': 'application/json' },
		});
	}

	// Pour les autres routes, retourner 404 ou une réponse par défaut
	return new Response('API endpoint not implemented', { status: 404 });
}

/**
 * Gère les requêtes de ressources
 */
async function handleResource(request, pathname, env) {
	// Essayer de charger depuis KV
	if (env.STATIC_ASSETS) {
		const asset = await env.STATIC_ASSETS.get(pathname);
		if (asset) {
			return new Response(asset, {
				headers: {
					'Content-Type': getMimeType(pathname),
					'Cache-Control': 'public, max-age=31536000',
				},
			});
		}
	}

	return new Response('Resource not found', { status: 404 });
}

/**
 * Obtient le type MIME
 */
function getMimeType(pathname) {
	const ext = pathname.substring(pathname.lastIndexOf('.'));
	const mimeTypes = {
		'.html': 'text/html',
		'.js': 'application/javascript',
		'.css': 'text/css',
		'.json': 'application/json',
		'.png': 'image/png',
		'.svg': 'image/svg+xml',
		'.woff': 'font/woff',
		'.woff2': 'font/woff2',
	};
	return mimeTypes[ext.toLowerCase()] || 'application/octet-stream';
}

export default {
	async fetch(request, env, ctx) {
		const url = new URL(request.url);
		const pathname = url.pathname;

		// Gérer les requêtes OPTIONS
		if (request.method === 'OPTIONS') {
			return new Response(null, {
				headers: {
					'Access-Control-Allow-Origin': '*',
					'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
					'Access-Control-Allow-Headers': 'Content-Type, Authorization',
				},
			});
		}

		// WebSocket
		if (request.headers.get('Upgrade') === 'websocket') {
			return handleWebSocket(request);
		}

		// Routes API
		if (pathname.startsWith('/api/')) {
			return handleAPI(request, pathname);
		}

		// Routes de ressources
		if (pathname.startsWith('/out/') || pathname.startsWith('/extensions/') || pathname.startsWith('/resources/')) {
			return handleResource(request, pathname, env);
		}

		// Route racine - servir le workbench HTML
		if (pathname === '/' || pathname === '/index.html') {
			return new Response(getWorkbenchHTML(url.origin), {
				headers: {
					'Content-Type': 'text/html',
					'Cache-Control': 'public, max-age=3600',
				},
			});
		}

		// Par défaut, essayer de servir depuis KV
		return handleResource(request, pathname, env);
	},
};

/**
 * Génère le HTML du workbench
 */
function getWorkbenchHTML(origin) {
	const config = JSON.stringify({
		...WORKBENCH_CONFIG,
		remoteAuthority: origin,
		webviewResourceRoot: origin,
		webviewCspSource: origin,
	});

	return `<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8" />
	<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no">
	<meta id="vscode-workbench-web-configuration" data-settings='${config}'>
	<link rel="stylesheet" href="${origin}/out/vs/code/browser/workbench/workbench.css">
	<script>
		const baseUrl = new URL('${origin}', window.location.origin).toString();
		globalThis._VSCODE_FILE_ROOT = baseUrl + '/out/';
	</script>
	<script type="module" src="${origin}/out/vs/code/browser/workbench/workbench.js"></script>
</head>
<body aria-label=""></body>
</html>`;
}

