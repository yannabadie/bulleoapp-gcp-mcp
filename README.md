# BulleoApp GCP/Firebase MCP Configuration

## 🎯 Objectif

Ce repository contient la configuration MCP (Model Context Protocol) pour intégrer BulleoApp avec Google Cloud Platform et Firebase, permettant une interaction directe avec les services cloud via Claude ou d'autres clients MCP.

## 🏗️ Architecture

BulleoApp utilise les MCP officiels de Firebase et Google Cloud pour une intégration stable et maintenue.

## ✨ Fonctionnalités

### Via Firebase MCP (Officiel)
- ✅ Gestion complète des utilisateurs (Auth)
- ✅ Base de données temps réel (Firestore)
- ✅ Stockage de fichiers (Cloud Storage) 
- ✅ Déploiement de fonctions (Cloud Functions)
- ✅ Hosting pour l'app web

### Via GCP MCP (Extensions)
- 🤖 IA générative avec Gemini
- 👁️ Analyse d'images (Vision API)
- 🎤 Transcription vocale (Speech-to-Text)
- 🏥 Conformité santé (Healthcare API)

## 🚀 Installation rapide

1. **Cloner le repo**
```bash
git clone https://github.com/yannabadie/bulleoapp-gcp-mcp.git
cd bulleoapp-gcp-mcp
```

2. **Configurer Firebase**
```bash
firebase login
firebase use --add
# Sélectionner votre projet BulleoApp
```

3. **Configurer Claude Desktop**
- Copier le contenu de `mcp-config/claude_desktop_config.json`
- L'ajouter dans Claude Desktop Settings > Developer > Edit Config
- Ajuster les chemins selon votre environnement

4. **Tester**
```
Dans Claude : "Liste tous les utilisateurs Firebase de BulleoApp"
```

## 📁 Structure du projet

```
bulleoapp-gcp-mcp/
├── mcp-config/
│   ├── claude_desktop_config.json    # Config Claude Desktop
│   ├── setup-instructions.md         # Guide installation
│   ├── example-workflows.md          # Cas d'usage BulleoApp
│   └── .env.example                  # Variables environnement
├── scripts/
│   ├── setup.sh                     # Script installation auto
│   └── test-connection.js           # Test connectivité
└── README.md
```

## 🔒 Sécurité

- **Jamais** de clés dans le code
- Utiliser des comptes de service avec permissions minimales
- Activer l'audit logging GCP
- Chiffrement des données sensibles
- Conformité RGPD/HDS

## 📚 Documentation

- [Setup détaillé](mcp-config/setup-instructions.md)
- [Workflows BulleoApp](mcp-config/example-workflows.md)
- [Firebase MCP Docs](https://firebase.google.com/docs/cli/mcp-server)
- [MCP Protocol Spec](https://modelcontextprotocol.io)

## 🤝 Support

Pour toute question sur la configuration MCP de BulleoApp :
- Ouvrir une issue sur ce repo
- Contacter l'équipe technique BulleoApp

## 📄 License

MIT - Voir [LICENSE](LICENSE) pour plus de détails.

---

*Développé avec ❤️ pour accompagner les femmes dans leur parcours de maternité*