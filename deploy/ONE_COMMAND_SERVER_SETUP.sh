#!/bin/bash
set -euo pipefail

#############################################
# KitchenTech One-Command Server Setup
# 
# Complete automated setup for Hetzner Ubuntu server
# Safe to run multiple times (idempotent)
#
# Prerequisites:
# - Ubuntu 22.04+
# - PostgreSQL installed and running
# - SSL certificate installed (certbot/Let's Encrypt)
# - DNS pointing to server
#
# Usage:
# 1. Edit REPO_URL below with your GitHub repo
# 2. Run: sudo bash deploy/ONE_COMMAND_SERVER_SETUP.sh
#############################################

# ============================================
# CONFIGURATION VARIABLES
# ============================================

DOMAIN="souqmatbakh.com"
REPO_URL="https://github.com/abdullahsumayli/KT.git"
APP_DIR="/var/www/souqmatbakh"
BACKEND_DIR="/var/www/souqmatbakh/backend"
FRONTEND_DIR="/var/www/souqmatbakh/frontend"
SERVICE_NAME="souqmatbakh-backend"
NGINX_SITE="/etc/nginx/sites-available/souqmatbakh.com"
NGINX_ENABLED="/etc/nginx/sites-enabled/souqmatbakh.com"
ENV_FILE="/var/www/souqmatbakh/backend/.env"
LOG_DIR="/var/log/souqmatbakh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Track errors
SETUP_ERRORS=0

# ============================================
# HELPER FUNCTIONS
# ============================================

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_step() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    ((SETUP_ERRORS++))
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# ============================================
# MAIN SETUP STEPS
# ============================================

setup_start() {
    print_header "KitchenTech Server Setup - $DOMAIN"
    print_step "Starting automated server setup..."
    
    print_step "Configuration:"
    echo "  - Domain: $DOMAIN"
    echo "  - Repository: $REPO_URL"
    echo "  - Backend: $BACKEND_DIR"
    echo "  - Frontend: $FRONTEND_DIR"
    echo ""
}

install_packages() {
    print_header "Step 1: Installing Required Packages"
    
    print_step "Updating package lists..."
    apt-get update -qq
    
    # Required packages (NOT postgres/certbot - assumed already installed)
    local packages=(
        "nginx"
        "git"
        "python3"
        "python3-pip"
        "python3-venv"
        "curl"
    )
    
    for pkg in "${packages[@]}"; do
        if dpkg -l | grep -q "^ii  $pkg "; then
            print_success "$pkg already installed"
        else
            print_step "Installing $pkg..."
            apt-get install -y -qq "$pkg"
            print_success "$pkg installed"
        fi
    done
    
    # Verify PostgreSQL is installed (but don't install it)
    if ! command -v psql &> /dev/null; then
        print_warning "PostgreSQL client not found - you may need to install postgresql-client"
    else
        print_success "PostgreSQL client available"
    fi
}

create_directories() {
    print_header "Step 2: Creating Directory Structure"
    
    # Create main directories
    for dir in "$APP_DIR" "$BACKEND_DIR" "$FRONTEND_DIR" "$LOG_DIR"; do
        if [[ ! -d "$dir" ]]; then
            print_step "Creating $dir..."
            mkdir -p "$dir"
            print_success "Created $dir"
        else
            print_success "$dir already exists"
        fi
    done
    
    # Set ownership to www-data
    print_step "Setting ownership to www-data..."
    chown -R www-data:www-data "$APP_DIR"
    chown -R www-data:www-data "$LOG_DIR"
    print_success "Ownership configured"
}

clone_or_update_repo() {
    print_header "Step 3: Cloning/Updating Repository"
    
    if [[ ! -d "$BACKEND_DIR/.git" ]]; then
        print_step "Repository not found. Cloning from $REPO_URL..."
        
        # Remove directory if it exists but has no .git
        if [[ -d "$BACKEND_DIR" ]]; then
            rm -rf "$BACKEND_DIR"
        fi
        
        # Clone as www-data
        sudo -u www-data git clone "$REPO_URL" "$BACKEND_DIR"
        print_success "Repository cloned successfully"
    else
        print_step "Repository exists. Pulling latest changes..."
        cd "$BACKEND_DIR"
        sudo -u www-data git pull origin main || sudo -u www-data git pull origin master
        print_success "Repository updated"
    fi
    
    # Verify deploy directory exists
    if [[ ! -d "$BACKEND_DIR/deploy" ]]; then
        print_error "deploy/ directory not found in repository!"
        exit 1
    fi
}

setup_environment_file() {
    print_header "Step 4: Configuring Environment Variables"
    
    if [[ -f "$ENV_FILE" ]]; then
        print_warning ".env file already exists - keeping existing configuration"
        print_step "If you need to regenerate, delete $ENV_FILE and re-run this script"
    else
        print_step "Creating .env file from template..."
        
        # Copy template
        if [[ -f "$BACKEND_DIR/deploy/backend.env.prod.example" ]]; then
            cp "$BACKEND_DIR/deploy/backend.env.prod.example" "$ENV_FILE"
        else
            print_error "Template file not found: $BACKEND_DIR/deploy/backend.env.prod.example"
            exit 1
        fi
        
        # Generate secure secret key
        print_step "Generating secure KT_SECRET_KEY..."
        local secret_key
        secret_key=$(python3 -c "import secrets; print(secrets.token_urlsafe(64))")
        
        # Replace placeholder with generated key
        sed -i "s|__REPLACE_WITH_SECURE_RANDOM_KEY_MIN_32_CHARS__|$secret_key|g" "$ENV_FILE"
        
        # Set proper permissions
        chown www-data:www-data "$ENV_FILE"
        chmod 640 "$ENV_FILE"
        
        print_success ".env file created with auto-generated secret key"
        print_warning "IMPORTANT: Edit $ENV_FILE and update:"
        echo "  - KT_DATABASE_URL (PostgreSQL password)"
        echo "  - Review KT_ALLOWED_ORIGINS"
        echo ""
        echo "Press Enter when ready to continue, or Ctrl+C to exit and configure..."
        read -r
    fi
}

setup_python_environment() {
    print_header "Step 5: Setting Up Python Environment"
    
    local venv_dir="$BACKEND_DIR/.venv"
    
    # Create venv if doesn't exist
    if [[ ! -d "$venv_dir" ]]; then
        print_step "Creating Python virtual environment..."
        sudo -u www-data python3 -m venv "$venv_dir"
        print_success "Virtual environment created"
    else
        print_success "Virtual environment already exists"
    fi
    
    # Upgrade pip
    print_step "Upgrading pip..."
    sudo -u www-data "$venv_dir/bin/pip" install --quiet --upgrade pip
    
    # Install dependencies
    print_step "Installing Python dependencies (this may take a moment)..."
    sudo -u www-data "$venv_dir/bin/pip" install --quiet -r "$BACKEND_DIR/requirements.txt"
    
    # Install gunicorn
    print_step "Installing gunicorn..."
    sudo -u www-data "$venv_dir/bin/pip" install --quiet gunicorn
    
    print_success "Python environment configured"
}

run_database_migrations() {
    print_header "Step 6: Running Database Migrations"
    
    print_step "Checking database connection..."
    
    # Try to run migrations
    cd "$BACKEND_DIR"
    if sudo -u www-data "$BACKEND_DIR/.venv/bin/alembic" upgrade head; then
        print_success "Database migrations completed"
    else
        print_error "Database migrations failed!"
        print_warning "Check your KT_DATABASE_URL in $ENV_FILE"
        print_warning "Ensure PostgreSQL is running and database exists"
        exit 1
    fi
    
    # Initialize default data if needed
    if [[ -f "$BACKEND_DIR/init_default_data.py" ]]; then
        print_step "Checking for default data initialization..."
        sudo -u www-data "$BACKEND_DIR/.venv/bin/python" "$BACKEND_DIR/init_default_data.py" || true
        print_success "Default data check completed"
    fi
}

setup_systemd_service() {
    print_header "Step 7: Configuring Systemd Service"
    
    local service_file="$BACKEND_DIR/deploy/systemd/$SERVICE_NAME.service"
    local target="/etc/systemd/system/$SERVICE_NAME.service"
    
    if [[ ! -f "$service_file" ]]; then
        print_error "Service file not found: $service_file"
        exit 1
    fi
    
    # Copy service file
    print_step "Installing systemd service..."
    cp "$service_file" "$target"
    print_success "Service file installed"
    
    # Reload systemd
    print_step "Reloading systemd daemon..."
    systemctl daemon-reload
    
    # Enable service
    print_step "Enabling service to start on boot..."
    systemctl enable "$SERVICE_NAME"
    
    # Start service (don't fail if already running)
    print_step "Starting service..."
    systemctl restart "$SERVICE_NAME" || true
    
    print_success "Systemd service configured"
}

setup_nginx() {
    print_header "Step 8: Configuring Nginx"
    
    local nginx_conf="$BACKEND_DIR/deploy/nginx/souqmatbakh.com.conf"
    
    if [[ ! -f "$nginx_conf" ]]; then
        print_error "Nginx config not found: $nginx_conf"
        exit 1
    fi
    
    # Copy nginx config
    print_step "Installing nginx configuration..."
    cp "$nginx_conf" "$NGINX_SITE"
    print_success "Nginx config installed"
    
    # Create symlink if doesn't exist
    if [[ ! -L "$NGINX_ENABLED" ]]; then
        print_step "Enabling site..."
        ln -sf "$NGINX_SITE" "$NGINX_ENABLED"
        print_success "Site enabled"
    else
        print_success "Site already enabled"
    fi
    
    # Remove default site if exists
    if [[ -L "/etc/nginx/sites-enabled/default" ]]; then
        print_step "Removing default nginx site..."
        rm -f "/etc/nginx/sites-enabled/default"
        print_success "Default site removed"
    fi
    
    # Test nginx config
    print_step "Testing nginx configuration..."
    if nginx -t; then
        print_success "Nginx configuration valid"
    else
        print_error "Nginx configuration test failed!"
        exit 1
    fi
    
    # Reload nginx
    print_step "Reloading nginx..."
    systemctl reload nginx
    print_success "Nginx reloaded"
}

restart_and_verify_service() {
    print_header "Step 9: Restarting Backend Service"
    
    print_step "Restarting $SERVICE_NAME..."
    systemctl restart "$SERVICE_NAME"
    
    # Wait for service to start
    sleep 3
    
    # Check if service is running
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        print_success "Service is running"
    else
        print_error "Service failed to start!"
        print_step "Service status:"
        systemctl status "$SERVICE_NAME" --no-pager || true
        print_step "Recent logs:"
        journalctl -u "$SERVICE_NAME" -n 50 --no-pager || true
        exit 1
    fi
}

run_health_checks() {
    print_header "Step 10: Running Health Checks"
    
    # Wait a bit for services to fully start
    print_step "Waiting for services to stabilize..."
    sleep 2
    
    # Check 1: Backend responds locally
    print_step "Testing backend (http://127.0.0.1:8000)..."
    if curl -sSf http://127.0.0.1:8000/api/ > /dev/null 2>&1; then
        print_success "Backend responding on localhost"
    elif curl -sSf http://127.0.0.1:8000/api/docs > /dev/null 2>&1; then
        print_success "Backend responding on localhost (docs endpoint)"
    else
        print_warning "Backend may not be responding yet (give it a moment)"
    fi
    
    # Check 2: HTTPS site
    print_step "Testing HTTPS site (https://$DOMAIN)..."
    if curl -sSfI "https://$DOMAIN" > /dev/null 2>&1; then
        print_success "HTTPS site accessible"
    else
        print_warning "HTTPS not accessible yet - may need SSL certificate setup"
        print_step "Run: certbot --nginx -d $DOMAIN -d www.$DOMAIN"
    fi
    
    # Check 3: API through nginx
    print_step "Testing API endpoint (https://$DOMAIN/api/)..."
    if curl -sSf "https://$DOMAIN/api/" > /dev/null 2>&1; then
        print_success "API endpoint accessible"
    elif curl -sSf "https://$DOMAIN/api/docs" > /dev/null 2>&1; then
        print_success "API docs accessible"
    else
        print_warning "API may not be accessible through nginx yet"
    fi
    
    # Check 4: Service status
    print_step "Checking service status..."
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        print_success "Backend service is active"
    else
        print_error "Backend service is not active!"
    fi
    
    # Check 5: Nginx status
    print_step "Checking nginx status..."
    if systemctl is-active --quiet nginx; then
        print_success "Nginx is active"
    else
        print_error "Nginx is not active!"
    fi
}

show_diagnostics() {
    print_header "Diagnostics and Logs"
    
    echo -e "${YELLOW}Service Status:${NC}"
    systemctl status "$SERVICE_NAME" --no-pager --lines=10 || true
    echo ""
    
    echo -e "${YELLOW}Recent Service Logs (last 120 lines):${NC}"
    journalctl -u "$SERVICE_NAME" -n 120 --no-pager || true
    echo ""
    
    if [[ -f /var/log/nginx/souqmatbakh-error.log ]]; then
        echo -e "${YELLOW}Nginx Error Log (last 80 lines):${NC}"
        tail -n 80 /var/log/nginx/souqmatbakh-error.log || true
    elif [[ -f /var/log/nginx/error.log ]]; then
        echo -e "${YELLOW}Nginx Error Log (last 80 lines):${NC}"
        tail -n 80 /var/log/nginx/error.log || true
    fi
}

setup_complete() {
    print_header "Setup Complete!"
    
    if [[ $SETUP_ERRORS -eq 0 ]]; then
        echo -e "${GREEN}✅ Server setup completed successfully!${NC}"
        echo ""
        echo "Next steps:"
        echo "1. Verify .env configuration: $ENV_FILE"
        echo "2. Change default admin password: admin@kitchentech.sa / admin123456"
        echo "3. Upload frontend files to: $FRONTEND_DIR"
        echo "4. Setup SSL if not done: certbot --nginx -d $DOMAIN -d www.$DOMAIN"
        echo ""
        echo "Useful commands:"
        echo "  - View logs: journalctl -u $SERVICE_NAME -f"
        echo "  - Restart backend: systemctl restart $SERVICE_NAME"
        echo "  - Reload nginx: systemctl reload nginx"
        echo "  - Deploy updates: cd $BACKEND_DIR && sudo -u www-data ./deploy/scripts/deploy_backend.sh"
        echo ""
        echo "Access your application:"
        echo "  - Website: https://$DOMAIN"
        echo "  - API Docs: https://$DOMAIN/api/docs"
        echo ""
    else
        echo -e "${RED}⚠️  Setup completed with $SETUP_ERRORS error(s)${NC}"
        echo ""
        echo "Review the errors above and:"
        echo "1. Fix any configuration issues"
        echo "2. Re-run this script: sudo bash $0"
        echo ""
        show_diagnostics
    fi
}

# ============================================
# MAIN EXECUTION
# ============================================

main() {
    check_root
    setup_start
    
    # Run all setup steps
    install_packages
    create_directories
    clone_or_update_repo
    setup_environment_file
    setup_python_environment
    run_database_migrations
    setup_systemd_service
    setup_nginx
    restart_and_verify_service
    run_health_checks
    
    # Final summary
    setup_complete
}

# Run main function
main "$@"
