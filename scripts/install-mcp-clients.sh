#!/bin/bash

# Script d'installation des clients MCP pour BulleoApp
# ======================================================

set -e

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Installation des Clients MCP BulleoApp ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""

# Détection du système d'exploitation
OS="Unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    OS="Windows"
fi

echo -e "${GREEN}Système détecté: $OS${NC}"
echo ""

# Claude Desktop
echo -e "${YELLOW}1. Claude Desktop${NC}"
if [[ "$OS" == "macOS" ]]; then
    if [ -d "/Applications/Claude.app" ]; then
        echo -e "${GREEN}✅ Claude Desktop installé${NC}"
        
        # Chemin de configuration Claude Desktop sur macOS
        CONFIG_PATH="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
        
        if [ -f "$CONFIG_PATH" ]; then
            echo "Configuration existante détectée"
            read -p "Voulez-vous sauvegarder la configuration actuelle? (y/n): " BACKUP
            if [[ $BACKUP == "y" ]]; then
                cp "$CONFIG_PATH" "$CONFIG_PATH.backup.$(date +%Y%m%d_%H%M%S)"
                echo -e "${GREEN}✅ Sauvegarde créée${NC}"
            fi
        fi
        
        echo "Ajout de la configuration BulleoApp MCP..."
        # Créer le dossier si nécessaire
        mkdir -p "$(dirname "$CONFIG_PATH")"
        
        # Copier notre configuration
        if [ -f "mcp-config/claude_desktop_config_generated.json" ]; then
            cp "mcp-config/claude_desktop_config_generated.json" "$CONFIG_PATH"
            echo -e "${GREEN}✅ Configuration MCP installée pour Claude Desktop${NC}"
        else
            echo -e "${YELLOW}⚠️  Configuration générée non trouvée. Exécutez d'abord ./scripts/setup.sh${NC}"
        fi
    else
        echo "Claude Desktop non installé"
        echo "Téléchargez depuis: https://claude.ai/download"
    fi
elif [[ "$OS" == "Windows" ]]; then
    CONFIG_PATH="$APPDATA/Claude/claude_desktop_config.json"
    echo "Configuration Windows: $CONFIG_PATH"
elif [[ "$OS" == "Linux" ]]; then
    CONFIG_PATH="$HOME/.config/Claude/claude_desktop_config.json"
    echo "Configuration Linux: $CONFIG_PATH"
fi

echo ""

# VS Code avec Continue
echo -e "${YELLOW}2. VS Code avec Continue${NC}"
if command -v code &> /dev/null; then
    echo -e "${GREEN}✅ VS Code installé${NC}"
    
    # Vérifier si Continue est installé
    if code --list-extensions | grep -q "Continue.continue"; then
        echo -e "${GREEN}✅ Extension Continue installée${NC}"
    else
        echo "Installation de l'extension Continue..."
        code --install-extension Continue.continue
        echo -e "${GREEN}✅ Extension Continue installée${NC}"
    fi
    
    # Configuration Continue pour MCP
    CONTINUE_CONFIG="$HOME/.continue/config.json"
    if [ -f "$CONTINUE_CONFIG" ]; then
        echo "Configuration Continue existante détectée"
    else
        mkdir -p "$HOME/.continue"
        cat > "$CONTINUE_CONFIG" << 'EOF'
{
  "models": [
    {
      "title": "Claude 3.5 Sonnet",
      "provider": "anthropic",
      "model": "claude-3-5-sonnet-20241022"
    }
  ],
  "mcpServers": {
    "firebase-bulleoapp": {
      "command": "npx",
      "args": ["-y", "firebase-tools@latest", "experimental:mcp"]
    }
  }
}
EOF
        echo -e "${GREEN}✅ Configuration Continue créée${NC}"
    fi
else
    echo "VS Code non installé"
    echo "Téléchargez depuis: https://code.visualstudio.com/"
fi

echo ""

# Cursor
echo -e "${YELLOW}3. Cursor${NC}"
if [[ "$OS" == "macOS" ]] && [ -d "/Applications/Cursor.app" ]; then
    echo -e "${GREEN}✅ Cursor installé${NC}"
    
    # Configuration Cursor MCP
    CURSOR_CONFIG="$HOME/Library/Application Support/Cursor/User/mcp_settings.json"
    mkdir -p "$(dirname "$CURSOR_CONFIG")"
    
    if [ -f "mcp-config/claude_desktop_config_generated.json" ]; then
        cp "mcp-config/claude_desktop_config_generated.json" "$CURSOR_CONFIG"
        echo -e "${GREEN}✅ Configuration MCP installée pour Cursor${NC}"
    fi
else
    echo "Cursor non détecté"
    echo "Téléchargez depuis: https://cursor.sh/"
fi

echo ""

# Cline (VS Code)
echo -e "${YELLOW}4. Cline (VS Code Extension)${NC}"
if command -v code &> /dev/null; then
    if code --list-extensions | grep -q "saoudrizwan.claude-dev"; then
        echo -e "${GREEN}✅ Extension Cline installée${NC}"
    else
        echo "Installation de l'extension Cline..."
        code --install-extension saoudrizwan.claude-dev
        echo -e "${GREEN}✅ Extension Cline installée${NC}"
    fi
    
    # Configuration Cline MCP
    CLINE_CONFIG="$HOME/.cline/mcp_settings.json"
    mkdir -p "$(dirname "$CLINE_CONFIG")"
    
    if [ -f "mcp-config/claude_desktop_config_generated.json" ]; then
        cp "mcp-config/claude_desktop_config_generated.json" "$CLINE_CONFIG"
        echo -e "${GREEN}✅ Configuration MCP installée pour Cline${NC}"
    fi
fi

echo ""

# Résumé
echo -e "${BLUE}═══════════════════════════════════${NC}"
echo -e "${BLUE}📊 Résumé de l'installation${NC}"
echo -e "${BLUE}═══════════════════════════════════${NC}"
echo ""

echo "Clients MCP configurés:"
echo "• Claude Desktop: $([[ -f "$CONFIG_PATH" ]] && echo '✅' || echo '❌')" 
echo "• VS Code Continue: $([[ -f "$CONTINUE_CONFIG" ]] && echo '✅' || echo '❌')"
echo "• Cursor: $([[ -f "$CURSOR_CONFIG" ]] && echo '✅' || echo '❌')"
echo "• Cline: $([[ -f "$CLINE_CONFIG" ]] && echo '✅' || echo '❌')"

echo ""
echo -e "${GREEN}Installation terminée!${NC}"
echo ""
echo "Pour activer les configurations:"
echo "1. Redémarrez les applications concernées"
echo "2. Testez avec une commande comme: 'Liste les projets Firebase'"
echo ""
echo "Documentation: https://github.com/yannabadie/bulleoapp-gcp-mcp"