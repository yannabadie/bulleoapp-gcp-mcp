# Configuration MCP pour BulleoApp

## 🚀 Guide d'installation rapide

### Prérequis
1. **Firebase CLI** installé et configuré
2. **Compte de service GCP** avec les permissions nécessaires
3. **Claude Desktop** ou autre client MCP compatible

### Étape 1 : Authentification Firebase

```bash
# Si vous n'êtes pas déjà connecté
firebase login

# Vérifier votre connexion
firebase projects:list
```

### Étape 2 : Configuration du compte de service GCP

1. Allez dans [Google Cloud Console](https://console.cloud.google.com)
2. Naviguez vers "IAM & Admin" > "Service Accounts"
3. Créez ou sélectionnez un compte de service avec les rôles :
   - `Firebase Admin`
   - `Cloud Storage Admin`
   - `Vertex AI User`
   - `Cloud Healthcare API Admin` (pour conformité HDS)

4. Téléchargez la clé JSON et sauvegardez-la en sécurité

### Étape 3 : Configuration Claude Desktop

1. Ouvrez Claude Desktop
2. Allez dans **Settings** > **Developer** > **Edit Config**
3. Remplacez le contenu par celui de `claude_desktop_config.json`
4. Modifiez les chemins selon votre environnement :
   - `/Users/VOTRE_USER/projects/bulleoapp` → Votre dossier projet
   - `/path/to/your/service-account-key.json` → Chemin de votre clé GCP

### Étape 4 : Vérification

Dans Claude, tapez :
```
Peux-tu vérifier que tu as accès aux outils Firebase et GCP pour BulleoApp ?
```

## 📋 Outils disponibles

### Firebase MCP (Officiel)
- **Auth** : Gestion utilisateurs, custom claims
- **Firestore** : CRUD documents, requêtes
- **Storage** : Upload/download fichiers, URLs signées
- **Functions** : Déploiement, logs, configuration
- **Hosting** : Déploiement sites statiques

### GCP Vertex AI (si configuré)
- **Gemini** : Génération de contenu IA
- **Vision API** : Analyse d'images (couches, médicaments)
- **Speech-to-Text** : Transcription journal vocal
- **Healthcare API** : Conformité FHIR/HL7

## 🔧 Configuration avancée

### Limiter les outils exposés

```json
"--only", "firestore,auth,storage"
```

### Utiliser un projet spécifique

```json
"--dir", "/absolute/path/to/bulleoapp",
"--project", "bulleoapp-production"
```

### Mode debug

```json
"env": {
  "DEBUG": "firebase:*",
  "FIREBASE_DEBUG": "true"
}
```

## 🛡️ Sécurité

### Bonnes pratiques
1. **Ne jamais** commiter les clés de service dans Git
2. Utiliser des comptes de service avec permissions minimales
3. Activer l'audit logging dans GCP
4. Renouveler les clés régulièrement

### Variables d'environnement

```bash
# .env.local (ne pas commiter)
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/key.json"
export FIREBASE_PROJECT_ID="bulleoapp-prod"
export GCP_REGION="europe-west1"
```

## 🔍 Troubleshooting

### Erreur "Not authenticated"
```bash
firebase login --reauth
```

### Erreur "Project not found"
```bash
firebase use --add
# Sélectionnez votre projet BulleoApp
```

### Erreur "Permission denied"
Vérifiez les rôles IAM de votre compte de service dans GCP Console

## 📚 Ressources

- [Documentation Firebase MCP](https://firebase.google.com/docs/cli/mcp-server)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)
- [GCP IAM Documentation](https://cloud.google.com/iam/docs)
- [Model Context Protocol Spec](https://modelcontextprotocol.io)

## 💡 Cas d'usage BulleoApp

### Exemple 1 : Créer un utilisateur test
```
Crée un utilisateur test dans Firebase Auth pour BulleoApp avec l'email test@bulleoapp.com
```

### Exemple 2 : Analyser une image de couche
```
Récupère l'image 'diaper_sample.jpg' depuis Cloud Storage et analyse-la avec Vision API
```

### Exemple 3 : Requête Firestore
```
Liste tous les suivis de grossesse actifs dans la collection 'pregnancies' où status='active'
```