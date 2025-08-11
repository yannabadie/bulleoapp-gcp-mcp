#!/bin/bash

# Script d'installation automatique pour BulleoApp MCP
# =======================================================

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     BulleoApp MCP Setup - Installation  ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""

# Vérification des prérequis
echo -e "${YELLOW}📋 Vérification des prérequis...${NC}"

# Vérifier Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js n'est pas installé${NC}"
    echo "Veuillez installer Node.js depuis https://nodejs.org/"
    exit 1
fi
echo -e "${GREEN}✅ Node.js installé ($(node -v))${NC}"

# Vérifier npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm n'est pas installé${NC}"
    exit 1
fi
echo -e "${GREEN}✅ npm installé ($(npm -v))${NC}"

# Vérifier Firebase CLI
if ! command -v firebase &> /dev/null; then
    echo -e "${YELLOW}📦 Installation de Firebase CLI...${NC}"
    npm install -g firebase-tools
fi
echo -e "${GREEN}✅ Firebase CLI installé${NC}"

# Vérifier gcloud CLI (optionnel)
if command -v gcloud &> /dev/null; then
    echo -e "${GREEN}✅ Google Cloud SDK installé${NC}"
else
    echo -e "${YELLOW}ℹ️  Google Cloud SDK non détecté (optionnel)${NC}"
fi

echo ""
echo -e "${YELLOW}🔐 Configuration Firebase...${NC}"

# Authentification Firebase
if firebase projects:list &> /dev/null; then
    echo -e "${GREEN}✅ Déjà connecté à Firebase${NC}"
else
    echo -e "${YELLOW}Connexion à Firebase requise...${NC}"
    firebase login
fi

# Sélection du projet
echo ""
echo -e "${YELLOW}📁 Sélection du projet Firebase...${NC}"
echo "Projets disponibles:"
firebase projects:list

read -p "Entrez l'ID de votre projet BulleoApp: " PROJECT_ID

if [ -z "$PROJECT_ID" ]; then
    echo -e "${RED}❌ ID de projet requis${NC}"
    exit 1
fi

firebase use $PROJECT_ID
echo -e "${GREEN}✅ Projet $PROJECT_ID sélectionné${NC}"

# Configuration des chemins
echo ""
echo -e "${YELLOW}📍 Configuration des chemins...${NC}"

PROJECT_PATH=$(pwd)
echo "Chemin du projet: $PROJECT_PATH"

# Créer le fichier de configuration Claude Desktop
echo ""
echo -e "${YELLOW}⚙️  Génération de la configuration Claude Desktop...${NC}"

CONFIG_FILE="mcp-config/claude_desktop_config_generated.json"

cat > $CONFIG_FILE << EOF
{
  "mcpServers": {
    "firebase-bulleoapp": {
      "command": "npx",
      "args": [
        "-y",
        "firebase-tools@latest",
        "experimental:mcp",
        "--dir", "$PROJECT_PATH",
        "--only", "firestore,auth,storage,functions,hosting"
      ]
    }
  }
}
EOF

echo -e "${GREEN}✅ Configuration générée dans $CONFIG_FILE${NC}"

# Configuration du compte de service GCP (optionnel)
echo ""
read -p "Voulez-vous configurer un compte de service GCP ? (y/n): " SETUP_GCP

if [[ $SETUP_GCP == "y" || $SETUP_GCP == "Y" ]]; then
    echo -e "${YELLOW}🔑 Configuration du compte de service GCP...${NC}"
    
    read -p "Chemin vers votre fichier de clé JSON: " KEY_PATH
    
    if [ -f "$KEY_PATH" ]; then
        # Ajouter la configuration GCP
        cat > $CONFIG_FILE << EOF
{
  "mcpServers": {
    "firebase-bulleoapp": {
      "command": "npx",
      "args": [
        "-y",
        "firebase-tools@latest",
        "experimental:mcp",
        "--dir", "$PROJECT_PATH",
        "--only", "firestore,auth,storage,functions,hosting"
      ]
    },
    "gcp-vertex-ai": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-gcp",
        "vertex-ai"
      ],
      "env": {
        "GOOGLE_APPLICATION_CREDENTIALS": "$KEY_PATH",
        "GCP_PROJECT_ID": "$PROJECT_ID",
        "GCP_REGION": "europe-west1"
      }
    }
  }
}
EOF
        echo -e "${GREEN}✅ Configuration GCP ajoutée${NC}"
    else
        echo -e "${RED}❌ Fichier de clé non trouvé${NC}"
    fi
fi

# Créer le fichier .env local
echo ""
echo -e "${YELLOW}📝 Création du fichier .env.local...${NC}"

cp mcp-config/.env.example .env.local
sed -i "" "s/bulleoapp-prod/$PROJECT_ID/g" .env.local 2>/dev/null || sed -i "s/bulleoapp-prod/$PROJECT_ID/g" .env.local

echo -e "${GREEN}✅ Fichier .env.local créé${NC}"

# Test de connexion
echo ""
echo -e "${YELLOW}🧪 Test de connexion...${NC}"

if node scripts/test-connection.js; then
    echo -e "${GREEN}✅ Test de connexion réussi${NC}"
else
    echo -e "${YELLOW}⚠️  Test de connexion échoué (vérifiez votre configuration)${NC}"
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        Installation terminée ! 🎉       ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}📋 Prochaines étapes:${NC}"
echo "1. Copiez le contenu de $CONFIG_FILE"
echo "2. Collez-le dans Claude Desktop > Settings > Developer > Edit Config"
echo "3. Redémarrez Claude Desktop"
echo "4. Testez avec: 'Liste les collections Firestore de BulleoApp'"
echo ""
echo -e "${GREEN}Documentation:${NC} https://github.com/yannabadie/bulleoapp-gcp-mcp"
echo ""