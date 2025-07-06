#!/bin/bash

# Script de setup spécialisé INDISUMai
set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# ASCII Art INDISUMai
echo -e "${PURPLE}"
cat << "EOF"
 _____ _   _ ____  ___ ____  _   _ __  __       _ 
|_   _| \ | |  _ \|_ _/ ___|| | | |  \/  | __ _(_)
  | | |  \| | | | || |\___ \| | | | |\/| |/ _` | |
  | | | |\  | |_| || | ___) | |_| | |  | | (_| | |
  |_| |_| \_|____/___|____/ \___/|_|  |_|\__,_|_|
                                                  
EOF
echo -e "${NC}"

echo -e "${GREEN}🚀 Configuration INDISUMai Landing Page${NC}"
echo -e "${BLUE}Intelligence Artificielle pour Coaching & Office Management${NC}"
echo ""

# Vérification du domaine
DOMAIN="indisumai.com"
echo -e "${YELLOW}🌐 Configuration pour le domaine: $DOMAIN${NC}"

# Vérification des prérequis
echo -e "${YELLOW}📋 Vérification des prérequis...${NC}"

# Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker n'est pas installé${NC}"
    echo "Installation de Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl start docker
    systemctl enable docker
    echo -e "${GREEN}✅ Docker installé${NC}"
else
    echo -e "${GREEN}✅ Docker disponible${NC}"
fi

# Docker Compose
if ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose n'est pas installé${NC}"
    echo "Installation de Docker Compose..."
    apt update
    apt install -y docker-compose-plugin
    echo -e "${GREEN}✅ Docker Compose installé${NC}"
else
    echo -e "${GREEN}✅ Docker Compose disponible${NC}"
fi

# Vérification DNS
echo -e "${YELLOW}🔍 Vérification DNS pour $DOMAIN...${NC}"
if nslookup $DOMAIN > /dev/null 2>&1; then
    echo -e "${GREEN}✅ DNS configuré${NC}"
else
    echo -e "${YELLOW}⚠️  DNS non résolu - configurez vos enregistrements A${NC}"
fi

# Création de la structure
echo -e "${YELLOW}📁 Création de la structure INDISUMai...${NC}"
mkdir -p ssl/{certs,private} logs/{nginx,beta} backups/{daily,weekly} reports/beta

# Fichiers .gitkeep
touch ssl/certs/.gitkeep ssl/private/.gitkeep logs/.gitkeep backups/.gitkeep

# Configuration .env
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚙️  Configuration .env${NC}"
    cp .env.example .env
    
    # Remplacement automatique du domaine
    sed -i "s/example.com/$DOMAIN/g" .env
    
    echo -e "${GREEN}✅ Fichier .env créé${NC}"
    echo -e "${RED}❗ IMPORTANT: Modifiez .env avec vos vraies valeurs${NC}"
    echo -e "${BLUE}nano .env${NC}"
else
    echo -e "${GREEN}✅ Fichier .env existe${NC}"
fi

# Permissions
echo -e "${YELLOW}🔒 Configuration des permissions...${NC}"
chmod +x scripts/*.sh
chmod 755 html/
chmod -R 644 html/* 2>/dev/null || true
chmod 700 ssl/private/
chmod 755 ssl/certs/

# Configuration Nginx spécialisée
echo -e "${YELLOW}🌐 Configuration Nginx pour INDISUMai...${NC}"
if [ -f "nginx/sites-available/default.conf" ]; then
    # Remplacement du domaine dans la config Nginx
    sed -i "s/example\.com/$DOMAIN/g" nginx/sites-available/default.conf
    echo -e "${GREEN}✅ Configuration Nginx adaptée${NC}"
fi

# Test de la configuration Docker
echo -e "${YELLOW}🧪 Test de la configuration...${NC}"
if docker compose config > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Configuration Docker Compose valide${NC}"
else
    echo -e "${RED}❌ Erreur dans la configuration Docker Compose${NC}"
    exit 1
fi

# Vérification spécifique INDISUMai
echo -e "${YELLOW}🎯 Vérifications spécifiques INDISUMai...${NC}"

# Vérification du formulaire Beta
if grep -q "profile.*solution.*challenge" html/index.html; then
    echo -e "${GREEN}✅ Formulaire Beta présent${NC}"
else
    echo -e "${RED}❌ Formulaire Beta manquant${NC}"
fi

# Vérification des solutions IA
if grep -q "Coaching.*Management" html/index.html; then
    echo -e "${GREEN}✅ Solutions IA décrites${NC}"
else
    echo -e "${YELLOW}⚠️  Descriptions solutions à vérifier${NC}"
fi

# Configuration monitoring Beta
echo -e "${YELLOW}📊 Configuration monitoring Beta...${NC}"
cat > /etc/cron.daily/indisumai-beta-report << 'EOF'
#!/bin/bash
/var/www/indisumai-landing/scripts/beta-analytics.sh
EOF
chmod +x /etc/cron.daily/indisumai-beta-report

# Installation de outils monitoring
apt update && apt install -y bc curl jq

echo -e "${GREEN}🎉 Configuration INDISUMai terminée !${NC}"
echo ""
echo -e "${BLUE}📋 Prochaines étapes:${NC}"
echo -e "${YELLOW}1.${NC} Modifiez le fichier .env avec vos valeurs"
echo -e "${YELLOW}2.${NC} Vérifiez la configuration DNS"
echo -e "${YELLOW}3.${NC} Lancez: docker compose up -d"
echo -e "${YELLOW}4.${NC} Testez: curl -I https://$DOMAIN"
echo ""
echo -e "${PURPLE}🚀 INDISUMai - L'IA qui révolutionne le coaching et l'office management${NC}"
echo -e "${BLUE}Beta Program: https://$DOMAIN#contact${NC}"
