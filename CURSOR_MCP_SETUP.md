# 🚀 Configuration Render MCP Server pour Cursor

## Qu'est-ce que Render MCP Server ?

Le **Render MCP Server** permet de gérer votre infrastructure Render directement depuis Cursor en utilisant des commandes en langage naturel. Vous pouvez :

- ✅ Créer de nouveaux services
- ✅ Consulter vos bases de données
- ✅ Analyser les métriques et logs
- ✅ Lister vos services Render
- ✅ Déployer des applications

**Source** : [Documentation officielle Render MCP](https://render.com/docs/mcp-server)

---

## 📋 Étapes de configuration

### Étape 1 : Créer une clé API Render

1. Allez sur [render.com](https://render.com) et connectez-vous
2. Cliquez sur votre profil → **Account Settings**
3. Dans la section **API Keys**, cliquez sur **Create API Key**
4. **⚠️ IMPORTANT** : Les clés API Render ont un large périmètre - elles donnent accès à tous vos workspaces et services
5. **Copiez la clé** (elle ne sera affichée qu'une seule fois !)

**📍 URL** : `https://dashboard.render.com/account/api-keys`

---

### Étape 2 : Configurer Cursor

1. **Localiser le fichier de configuration Cursor** :
   - **Windows** : `C:\Users\VOTRE_NOM\.cursor\mcp.json`
   - **macOS/Linux** : `~/.cursor/mcp.json`

2. **Créer le fichier s'il n'existe pas** :
   ```bash
   # Windows PowerShell
   New-Item -Path "$env:USERPROFILE\.cursor\mcp.json" -ItemType File -Force

   # macOS/Linux
   mkdir -p ~/.cursor
   touch ~/.cursor/mcp.json
   ```

3. **Ajouter la configuration suivante** :
   ```json
   {
     "mcpServers": {
       "render": {
         "url": "https://mcp.render.com/mcp",
         "headers": {
           "Authorization": "Bearer <VOTRE_CLE_API>"
         }
       }
     }
   }
   ```

   **Remplacez `<VOTRE_CLE_API>` par votre vraie clé API.**

   **Exemple complet** :
   ```json
   {
     "mcpServers": {
       "render": {
         "url": "https://mcp.render.com/mcp",
         "headers": {
           "Authorization": "Bearer rnd_abc123xyz789..."
         }
       }
     }
   }
   ```

4. **Redémarrer Cursor** pour que la configuration soit prise en compte.

---

### Étape 3 : Définir votre workspace Render

Une fois Cursor redémarré, vous devez définir le workspace Render à utiliser :

**Dans Cursor, tapez** :
```
Set my Render workspace to [NOM_DU_WORKSPACE]
```

Ou si vous ne connaissez pas le nom :
```
List my Render workspaces
```

**Si vous ne définissez pas le workspace**, Cursor vous demandera de le faire quand vous utiliserez des commandes MCP.

---

## 🎯 Exemples de commandes dans Cursor

Une fois configuré, vous pouvez utiliser ces commandes dans Cursor :

### Services
```
List my Render services
```

```
Create a new web service named "void-editor" using the repository ILYESS24/void2
```

```
Show me details about my void-editor service
```

### Déploiements
```
Show me the deploy history for void-editor
```

### Logs
```
Pull the most recent error-level logs for my void-editor service
```

### Métriques
```
What was the busiest traffic day for my service this month?
```

### Bases de données
```
Create a new Postgres database named user-db with 5 GB storage
```

```
Query my database for daily signup counts for the last 30 days
```

---

## 🔒 Sécurité

**⚠️ IMPORTANT - Avertissements de sécurité** :

1. **Périmètre large** : Les clés API Render donnent accès à **tous vos workspaces et services**
2. **Informations sensibles** : Le serveur MCP essaie de minimiser l'exposition d'informations sensibles, mais Render ne **garantit pas** qu'elles ne seront pas exposées
3. **Opérations destructives** : Le serveur MCP ne supporte actuellement qu'une seule opération destructrice : **modifier les variables d'environnement d'un service existant**

**Recommandations** :
- ✅ Ne partagez jamais votre clé API
- ✅ Utilisez des clés API avec précaution
- ✅ Révoquez les clés si elles sont compromises

---

## 📊 Limitations actuelles

D'après la [documentation officielle](https://render.com/docs/mcp-server) :

### ✅ Supporté
- Web services
- Static sites
- Bases de données Postgres Render
- Instances Key Value (Redis)
- Consultation de logs, métriques, déploiements

### ❌ Non supporté
- **Instances gratuites** (free tier)
- **Services privés**
- **Background workers**
- **Cron jobs**
- **Options avancées** (IP allowlists, services basés sur images, etc.)

### ⚠️ Modifications limitées
- ✅ Modifier les variables d'environnement d'un service
- ❌ Modifier ou supprimer d'autres ressources (utilisez le Dashboard ou l'API REST)
- ❌ Déclencher des déploiements
- ❌ Modifier les paramètres de scaling

---

## 🛠️ Dépannage

### Le serveur MCP ne fonctionne pas

1. **Vérifiez la syntaxe JSON** :
   ```bash
   # Valider le JSON
   cat ~/.cursor/mcp.json | python -m json.tool
   ```

2. **Vérifiez que la clé API est correcte** :
   - Format : `Bearer rnd_...`
   - Pas d'espaces supplémentaires

3. **Redémarrez Cursor complètement**

4. **Vérifiez les logs Cursor** pour plus d'informations

### "Workspace not set"

- Utilisez : `Set my Render workspace to [NOM]`
- Ou : `List my Render workspaces` pour voir les disponibles

---

## 📚 Ressources

- **Documentation officielle** : https://render.com/docs/mcp-server
- **GitHub du projet** : https://github.com/render-oss/render-mcp-server
- **API Render** : https://api.render.com

---

## ✅ Checklist de configuration

- [ ] Clé API Render créée
- [ ] Fichier `~/.cursor/mcp.json` créé
- [ ] Configuration JSON ajoutée avec votre clé API
- [ ] Cursor redémarré
- [ ] Workspace Render défini
- [ ] Test avec une commande simple : `List my Render services`

---

**🎉 Une fois configuré, vous pouvez gérer Render directement depuis Cursor avec des commandes en langage naturel !**

