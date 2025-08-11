#!/usr/bin/env node

/**
 * Script de test de connexion pour BulleoApp MCP
 * Vérifie la connectivité avec Firebase et GCP
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// Couleurs pour l'affichage
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m'
};

const log = {
  info: (msg) => console.log(`${colors.blue}ℹ${colors.reset}  ${msg}`),
  success: (msg) => console.log(`${colors.green}✅${colors.reset} ${msg}`),
  warning: (msg) => console.log(`${colors.yellow}⚠️${colors.reset}  ${msg}`),
  error: (msg) => console.log(`${colors.red}❌${colors.reset} ${msg}`)
};

console.log('\n🧪 Test de connexion BulleoApp MCP\n');
console.log('═══════════════════════════════════\n');

// Test 1: Vérifier Firebase CLI
log.info('Test 1: Vérification Firebase CLI...');
try {
  const firebaseVersion = execSync('firebase --version', { encoding: 'utf8' }).trim();
  log.success(`Firebase CLI installé: ${firebaseVersion}`);
} catch (error) {
  log.error('Firebase CLI non trouvé');
  process.exit(1);
}

// Test 2: Vérifier l'authentification Firebase
log.info('\nTest 2: Vérification authentification Firebase...');
try {
  execSync('firebase projects:list', { stdio: 'ignore' });
  log.success('Authentifié avec Firebase');
} catch (error) {
  log.error('Non authentifié avec Firebase');
  log.warning('Exécutez: firebase login');
  process.exit(1);
}

// Test 3: Vérifier le projet actif
log.info('\nTest 3: Vérification projet Firebase actif...');
try {
  const projectInfo = execSync('firebase use', { encoding: 'utf8' });
  const match = projectInfo.match(/Active Project: ([^\s]+)/);
  if (match) {
    log.success(`Projet actif: ${match[1]}`);
  } else {
    log.warning('Aucun projet actif');
    log.info('Exécutez: firebase use --add');
  }
} catch (error) {
  log.error('Erreur lors de la vérification du projet');
}

// Test 4: Vérifier la configuration MCP
log.info('\nTest 4: Vérification configuration MCP...');
const configPaths = [
  path.join(process.cwd(), 'mcp-config', 'claude_desktop_config.json'),
  path.join(process.cwd(), 'mcp-config', 'claude_desktop_config_generated.json')
];

let configFound = false;
for (const configPath of configPaths) {
  if (fs.existsSync(configPath)) {
    log.success(`Configuration trouvée: ${path.basename(configPath)}`);
    configFound = true;
    
    // Vérifier le contenu
    try {
      const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
      if (config.mcpServers && config.mcpServers['firebase-bulleoapp']) {
        log.success('Configuration Firebase MCP valide');
      }
      if (config.mcpServers && config.mcpServers['gcp-vertex-ai']) {
        log.success('Configuration GCP MCP détectée');
      }
    } catch (error) {
      log.error('Configuration invalide');
    }
    break;
  }
}

if (!configFound) {
  log.warning('Aucune configuration MCP trouvée');
  log.info('Exécutez: ./scripts/setup.sh');
}

// Test 5: Vérifier les variables d'environnement (optionnel)
log.info('\nTest 5: Vérification variables d\'environnement...');
if (fs.existsSync('.env.local')) {
  log.success('Fichier .env.local trouvé');
  
  // Vérifier les variables clés
  const envContent = fs.readFileSync('.env.local', 'utf8');
  const requiredVars = ['FIREBASE_PROJECT_ID', 'GCP_PROJECT_ID'];
  
  requiredVars.forEach(varName => {
    if (envContent.includes(varName)) {
      log.success(`Variable ${varName} configurée`);
    } else {
      log.warning(`Variable ${varName} manquante`);
    }
  });
} else {
  log.warning('Fichier .env.local non trouvé');
  log.info('Copiez .env.example vers .env.local et configurez-le');
}

// Test 6: Vérifier la clé de service GCP (optionnel)
log.info('\nTest 6: Vérification compte de service GCP...');
if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  const keyPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (fs.existsSync(keyPath)) {
    log.success(`Clé de service trouvée: ${path.basename(keyPath)}`);
  } else {
    log.error(`Clé de service non trouvée: ${keyPath}`);
  }
} else {
  log.warning('GOOGLE_APPLICATION_CREDENTIALS non configuré');
  log.info('Optionnel pour les fonctionnalités GCP avancées');
}

// Test 7: Test de connexion Firebase (si possible)
log.info('\nTest 7: Test de connexion aux services Firebase...');
try {
  // Tenter de lister les fonctions (non bloquant si aucune)
  execSync('firebase functions:list', { stdio: 'ignore', timeout: 5000 });
  log.success('Connexion aux Cloud Functions réussie');
} catch (error) {
  // Ce n'est pas une erreur critique
  log.info('Cloud Functions non configurées ou non accessibles');
}

// Résumé
console.log('\n═══════════════════════════════════\n');
console.log('📊 Résumé des tests\n');

const allTestsPassed = configFound;

if (allTestsPassed) {
  console.log(`${colors.green}✅ Tous les tests essentiels sont passés!${colors.reset}`);
  console.log('\nVotre configuration MCP est prête à être utilisée.');
  console.log('\nPour utiliser avec Claude Desktop:');
  console.log('1. Copiez la configuration depuis mcp-config/');
  console.log('2. Collez dans Claude Desktop > Settings > Developer');
  console.log('3. Redémarrez Claude Desktop');
} else {
  console.log(`${colors.yellow}⚠️  Certains tests ont échoué${colors.reset}`);
  console.log('\nVeuillez corriger les problèmes ci-dessus.');
  console.log('Consultez la documentation: https://github.com/yannabadie/bulleoapp-gcp-mcp');
}

console.log('');
process.exit(allTestsPassed ? 0 : 1);