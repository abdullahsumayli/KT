#!/bin/bash
set -euo pipefail

#######################################
# KitchenTech Backend Deployment Script
# 
# This script should be executed on the server
# from within: /var/www/souqmatbakh/backend
#
# Usage: ./deploy/scripts/deploy_backend.sh
#######################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="/var/www/souqmatbakh/backend"
VENV_DIR="$PROJECT_DIR/.venv"
SERVICE_NAME="souqmatbakh-backend"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  KitchenTech Backend Deployment${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if running from correct directory
if [[ "$PWD" != "$PROJECT_DIR" ]]; then
    echo -e "${YELLOW}Warning: Not in project directory. Changing to $PROJECT_DIR${NC}"
    cd "$PROJECT_DIR"
fi

# Step 1: Pull latest code
echo -e "${GREEN}[1/6] Pulling latest code from git...${NC}"
if git pull origin main; then
    echo -e "${GREEN}✓ Code updated successfully${NC}"
else
    echo -e "${RED}✗ Git pull failed${NC}"
    exit 1
fi
echo ""

# Step 2: Create virtual environment if it doesn't exist
echo -e "${GREEN}[2/6] Checking Python virtual environment...${NC}"
if [[ ! -d "$VENV_DIR" ]]; then
    echo -e "${YELLOW}Virtual environment not found. Creating...${NC}"
    python3 -m venv "$VENV_DIR"
    echo -e "${GREEN}✓ Virtual environment created${NC}"
else
    echo -e "${GREEN}✓ Virtual environment exists${NC}"
fi
echo ""

# Step 3: Install/update dependencies
echo -e "${GREEN}[3/6] Installing Python dependencies...${NC}"
"$VENV_DIR/bin/pip" install --upgrade pip
"$VENV_DIR/bin/pip" install -r requirements.txt
"$VENV_DIR/bin/pip" install gunicorn

# Verify gunicorn installation
if "$VENV_DIR/bin/pip" show gunicorn > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Dependencies installed (including gunicorn)${NC}"
else
    echo -e "${RED}✗ Failed to install gunicorn${NC}"
    exit 1
fi
echo ""

# Step 4: Run database migrations
echo -e "${GREEN}[4/6] Running database migrations...${NC}"
if "$VENV_DIR/bin/alembic" upgrade head; then
    echo -e "${GREEN}✓ Migrations applied successfully${NC}"
else
    echo -e "${RED}✗ Migration failed${NC}"
    exit 1
fi
echo ""

# Step 5: Ensure media directory exists and has correct permissions
echo -e "${GREEN}[5/6] Setting up media directory...${NC}"
mkdir -p "$PROJECT_DIR/media/listings"
if [[ $(stat -c '%U' "$PROJECT_DIR/media") != "www-data" ]]; then
    echo -e "${YELLOW}Fixing media directory ownership...${NC}"
    sudo chown -R www-data:www-data "$PROJECT_DIR/media"
fi
echo -e "${GREEN}✓ Media directory configured${NC}"
echo ""

# Step 6: Restart systemd service
echo -e "${GREEN}[6/6] Restarting backend service...${NC}"
if sudo systemctl restart "$SERVICE_NAME"; then
    echo -e "${GREEN}✓ Service restarted${NC}"
else
    echo -e "${RED}✗ Service restart failed${NC}"
    echo -e "${YELLOW}Checking service status...${NC}"
    sudo systemctl status "$SERVICE_NAME" --no-pager
    echo ""
    echo -e "${YELLOW}Last 50 log lines:${NC}"
    sudo journalctl -u "$SERVICE_NAME" -n 50 --no-pager
    exit 1
fi

# Wait a moment for service to start
sleep 2

# Verify service is running
echo ""
echo -e "${GREEN}Verifying deployment...${NC}"
if sudo systemctl is-active --quiet "$SERVICE_NAME"; then
    echo -e "${GREEN}✓ Service is running${NC}"
    
    # Test health endpoint
    echo -e "${GREEN}Testing API endpoint...${NC}"
    if curl -f http://127.0.0.1:8000/api/ > /dev/null 2>&1; then
        echo -e "${GREEN}✓ API responding correctly${NC}"
    else
        echo -e "${YELLOW}⚠ API not responding (might need a moment to start)${NC}"
    fi
else
    echo -e "${RED}✗ Service failed to start${NC}"
    sudo systemctl status "$SERVICE_NAME" --no-pager
    exit 1
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Deployment completed successfully! ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Service status:"
sudo systemctl status "$SERVICE_NAME" --no-pager | head -n 10
echo ""
echo "View logs: sudo journalctl -u $SERVICE_NAME -f"
echo "API Docs: https://souqmatbakh.com/api/docs"
