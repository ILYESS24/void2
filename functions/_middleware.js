/**
 * Cloudflare Pages Functions Middleware
 * Gère les routes API et WebSockets si nécessaire
 */

export function onRequest(context) {
	const { request, next } = context;
	const url = new URL(request.url);
	const pathname = url.pathname;

	// Gérer les requêtes OPTIONS (CORS)
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

	// Pour tout le reste, laisser Pages servir les fichiers statiques
	return next();
}

