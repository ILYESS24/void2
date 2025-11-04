/**
 * Script pour connecter GitHub à Cloudflare Pages via API
 * Note: Cloudflare Pages nécessite une connexion manuelle via Dashboard
 */

console.log('📋 Instructions pour connecter GitHub à Cloudflare Pages:');
console.log('');
console.log('1. Allez sur: https://dash.cloudflare.com/');
console.log('2. Workers & Pages → void-code');
console.log('3. Cliquez sur "Connect to Git"');
console.log('4. Sélectionnez votre repo: ILYESS24/void2');
console.log('5. Configurez:');
console.log('   - Production branch: main');
console.log('   - Build command: npm run build:cloudflare');
console.log('   - Build output directory: dist');
console.log('   - Root directory: /');
console.log('   - Node version: 20');
console.log('   - Environment variables:');
console.log('     * NPM_FLAGS: --legacy-peer-deps');
console.log('6. Save and Deploy');
console.log('');
console.log('✅ Cloudflare va builder automatiquement sur leurs serveurs !');
console.log('🌐 URL: https://void-code.pages.dev');

