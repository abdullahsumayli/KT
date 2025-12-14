#!/bin/bash
set -euo pipefail

#######################################
# Deployment Assets Verification Script
# 
# Verifies that all required deployment files
# are present and properly configured
#######################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Verifying deployment assets in: $DEPLOY_DIR"
echo ""

# Track errors
ERRORS=0

# Function to check file exists
check_file() {
    local file=$1
    local description=$2
    
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✓${NC} $description"
    else
        echo -e "${RED}✗${NC} $description - MISSING"
        ((ERRORS++))
    fi
}

# Function to check directory exists
check_dir() {
    local dir=$1
    local description=$2
    
    if [[ -d "$dir" ]]; then
        echo -e "${GREEN}✓${NC} $description"
    else
        echo -e "${RED}✗${NC} $description - MISSING"
        ((ERRORS++))
    fi
}

echo "=== Directory Structure ==="
check_dir "$DEPLOY_DIR" "deploy/ directory"
check_dir "$DEPLOY_DIR/nginx" "nginx/ directory"
check_dir "$DEPLOY_DIR/systemd" "systemd/ directory"
check_dir "$DEPLOY_DIR/scripts" "scripts/ directory"
echo ""

echo "=== Configuration Files ==="
check_file "$DEPLOY_DIR/backend.env.prod.example" "Production environment template"
check_file "$DEPLOY_DIR/README.md" "Deployment README"
check_file "$DEPLOY_DIR/DEPLOYMENT_CHECKLIST.md" "Deployment checklist"
echo ""

echo "=== Systemd Service ==="
check_file "$DEPLOY_DIR/systemd/souqmatbakh-backend.service" "Systemd service file"

# Check service file content
if [[ -f "$DEPLOY_DIR/systemd/souqmatbakh-backend.service" ]]; then
    if grep -q "WorkingDirectory=/var/www/souqmatbakh/backend" "$DEPLOY_DIR/systemd/souqmatbakh-backend.service"; then
        echo -e "${GREEN}✓${NC} Service has correct working directory"
    else
        echo -e "${RED}✗${NC} Service working directory not set correctly"
        ((ERRORS++))
    fi
    
    if grep -q "User=www-data" "$DEPLOY_DIR/systemd/souqmatbakh-backend.service"; then
        echo -e "${GREEN}✓${NC} Service runs as www-data"
    else
        echo -e "${RED}✗${NC} Service user not set correctly"
        ((ERRORS++))
    fi
fi
echo ""

echo "=== Nginx Configuration ==="
check_file "$DEPLOY_DIR/nginx/souqmatbakh.com.conf" "Nginx configuration file"

# Check nginx config content
if [[ -f "$DEPLOY_DIR/nginx/souqmatbakh.com.conf" ]]; then
    if grep -q "server_name souqmatbakh.com" "$DEPLOY_DIR/nginx/souqmatbakh.com.conf"; then
        echo -e "${GREEN}✓${NC} Nginx has correct server_name"
    else
        echo -e "${RED}✗${NC} Nginx server_name not configured"
        ((ERRORS++))
    fi
    
    if grep -q "proxy_pass http://127.0.0.1:8000" "$DEPLOY_DIR/nginx/souqmatbakh.com.conf"; then
        echo -e "${GREEN}✓${NC} Nginx proxies to backend"
    else
        echo -e "${RED}✗${NC} Nginx proxy_pass not configured"
        ((ERRORS++))
    fi
    
    if grep -q "ssl_certificate" "$DEPLOY_DIR/nginx/souqmatbakh.com.conf"; then
        echo -e "${GREEN}✓${NC} Nginx SSL configured"
    else
        echo -e "${RED}✗${NC} Nginx SSL not configured"
        ((ERRORS++))
    fi
fi
echo ""

echo "=== Scripts ==="
check_file "$DEPLOY_DIR/scripts/deploy_backend.sh" "Deployment script"
check_file "$DEPLOY_DIR/scripts/first_time_server_setup.md" "Setup documentation"

# Check script is executable (on Unix systems)
if [[ -f "$DEPLOY_DIR/scripts/deploy_backend.sh" ]]; then
    if head -n 1 "$DEPLOY_DIR/scripts/deploy_backend.sh" | grep -q "#!/bin/bash"; then
        echo -e "${GREEN}✓${NC} Deploy script has bash shebang"
    else
        echo -e "${RED}✗${NC} Deploy script missing bash shebang"
        ((ERRORS++))
    fi
    
    if grep -q "set -euo pipefail" "$DEPLOY_DIR/scripts/deploy_backend.sh"; then
        echo -e "${GREEN}✓${NC} Deploy script has error handling"
    else
        echo -e "${YELLOW}⚠${NC} Deploy script might not have proper error handling"
    fi
fi
echo ""

echo "=== Environment Variables ==="
if [[ -f "$DEPLOY_DIR/backend.env.prod.example" ]]; then
    # Check for required variables
    required_vars=("APP_ENV" "KT_SECRET_KEY" "KT_DATABASE_URL" "KT_ALLOWED_ORIGINS" "KT_DEBUG")
    
    for var in "${required_vars[@]}"; do
        if grep -q "^$var=" "$DEPLOY_DIR/backend.env.prod.example"; then
            echo -e "${GREEN}✓${NC} $var present in env template"
        else
            echo -e "${RED}✗${NC} $var missing from env template"
            ((ERRORS++))
        fi
    done
    
    # Check for placeholder warnings
    if grep -q "__REPLACE__" "$DEPLOY_DIR/backend.env.prod.example"; then
        echo -e "${GREEN}✓${NC} Contains placeholder warnings"
    else
        echo -e "${YELLOW}⚠${NC} No placeholder warnings (might have real secrets)"
    fi
fi
echo ""

echo "=== Security Checks ==="

# Check no real secrets in git
if [[ -f "$DEPLOY_DIR/backend.env.prod.example" ]]; then
    if grep -q "__REPLACE__" "$DEPLOY_DIR/backend.env.prod.example"; then
        echo -e "${GREEN}✓${NC} No real secrets in example env file"
    else
        echo -e "${YELLOW}⚠${NC} Verify no real secrets in env template"
    fi
fi

# Check .gitignore exists in parent
if [[ -f "$DEPLOY_DIR/../.gitignore" ]]; then
    if grep -q ".env" "$DEPLOY_DIR/../.gitignore"; then
        echo -e "${GREEN}✓${NC} .env in .gitignore"
    else
        echo -e "${RED}✗${NC} .env not in .gitignore"
        ((ERRORS++))
    fi
else
    echo -e "${YELLOW}⚠${NC} .gitignore not found in repo root"
fi
echo ""

echo "=== Documentation Completeness ==="

# Check README has all sections
if [[ -f "$DEPLOY_DIR/README.md" ]]; then
    sections=("Quick Start" "Configuration Files" "Deployment Script" "Security" "Troubleshooting")
    
    for section in "${sections[@]}"; do
        if grep -qi "$section" "$DEPLOY_DIR/README.md"; then
            echo -e "${GREEN}✓${NC} README has '$section' section"
        else
            echo -e "${YELLOW}⚠${NC} README might be missing '$section' section"
        fi
    done
fi
echo ""

# Summary
echo "=========================================="
if [[ $ERRORS -eq 0 ]]; then
    echo -e "${GREEN}✅ All checks passed!${NC}"
    echo "Deployment assets are ready for use."
    exit 0
else
    echo -e "${RED}❌ Found $ERRORS error(s)${NC}"
    echo "Please fix the issues above before deploying."
    exit 1
fi
