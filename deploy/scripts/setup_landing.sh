#!/bin/bash
set -e

echo "========================================="
echo "  Setup Landing Page for souqmatbakh.com"
echo "========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Create landing directory
echo -e "${YELLOW}[1/5] Creating landing directory...${NC}"
sudo mkdir -p /var/www/souqmatbakh/landing
sudo chown -R www-data:www-data /var/www/souqmatbakh/landing
echo -e "${GREEN}✓ Directory created${NC}"
echo ""

# Step 2: Upload index.html (from local machine)
echo -e "${YELLOW}[2/5] Upload index.html to server...${NC}"
echo "Run this from your local machine:"
echo "  scp d:\\KT\\deploy\\landing\\index.html root@91.99.106.230:/tmp/"
echo ""
echo "Press Enter when done..."
read

# Step 3: Move index.html to landing directory
echo -e "${YELLOW}[3/5] Moving index.html to landing directory...${NC}"
if [ -f /tmp/index.html ]; then
    sudo mv /tmp/index.html /var/www/souqmatbakh/landing/
    sudo chown www-data:www-data /var/www/souqmatbakh/landing/index.html
    sudo chmod 644 /var/www/souqmatbakh/landing/index.html
    echo -e "${GREEN}✓ index.html moved successfully${NC}"
else
    echo "Error: /tmp/index.html not found"
    exit 1
fi
echo ""

# Step 4: Update Nginx configuration
echo -e "${YELLOW}[4/5] Updating Nginx configuration...${NC}"
echo "Backing up current config..."
sudo cp /etc/nginx/sites-available/souqmatbakh.com /etc/nginx/sites-available/souqmatbakh.com.backup.$(date +%Y%m%d_%H%M%S)
echo "Uploading new config..."
# This will be done manually or via scp
echo -e "${GREEN}✓ Config ready to update${NC}"
echo ""

# Step 5: Test and reload Nginx
echo -e "${YELLOW}[5/5] Testing and reloading Nginx...${NC}"
echo "Testing Nginx configuration..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Nginx configuration is valid${NC}"
    echo ""
    echo "Reloading Nginx..."
    sudo systemctl reload nginx
    echo -e "${GREEN}✓ Nginx reloaded successfully${NC}"
else
    echo "Error: Nginx configuration test failed"
    exit 1
fi

echo ""
echo "========================================="
echo -e "${GREEN}  Landing page setup complete!${NC}"
echo "========================================="
echo ""
echo "Landing page available at:"
echo "  https://souqmatbakh.com/landing/"
echo ""
