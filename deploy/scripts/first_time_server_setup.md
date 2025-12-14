# First-Time Server Setup - KitchenTech (souqmatbakh.com)

Complete guide for deploying KitchenTech backend on Hetzner Ubuntu server.

**Server**: 91.99.106.230  
**Domain**: souqmatbakh.com  
**Prerequisites**: Ubuntu 22.04+, Nginx, PostgreSQL, SSL (Let's Encrypt) already installed

---

## 1. Prepare Server Directories

```bash
# Create project directories
sudo mkdir -p /var/www/souqmatbakh/{backend,frontend}
sudo mkdir -p /var/log/souqmatbakh

# Set ownership
sudo chown -R www-data:www-data /var/www/souqmatbakh
sudo chown -R www-data:www-data /var/log/souqmatbakh
```

---

## 2. Install System Dependencies

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Python and dependencies
sudo apt install -y python3 python3-pip python3-venv git

# Install PostgreSQL client (if not already installed)
sudo apt install -y postgresql-client libpq-dev
```

---

## 3. Setup PostgreSQL Database

```bash
# Connect to PostgreSQL
sudo -u postgres psql

# Inside PostgreSQL shell:
CREATE DATABASE kitchentech_prod;
CREATE USER kt_user WITH PASSWORD 'your_secure_password_here';
GRANT ALL PRIVILEGES ON DATABASE kitchentech_prod TO kt_user;
\c kitchentech_prod
GRANT ALL ON SCHEMA public TO kt_user;
\q
```

---

## 4. Clone and Configure Backend

```bash
# Switch to www-data user (or use sudo -u www-data)
sudo -u www-data bash

# Clone repository
cd /var/www/souqmatbakh
git clone https://github.com/YOUR_USERNAME/kitchentech.git backend
cd backend

# Copy and configure environment file
cp deploy/backend.env.prod.example .env

# Edit .env with actual values (use nano or vim)
nano .env
# - Replace KT_SECRET_KEY with: python3 -c "import secrets; print(secrets.token_urlsafe(64))"
# - Update KT_DATABASE_URL with actual PostgreSQL password
# - Verify KT_ALLOWED_ORIGINS matches your domain
# - Ensure APP_ENV=prod and KT_DEBUG=False

# Exit www-data shell
exit
```

---

## 5. Setup Python Virtual Environment

```bash
# Create virtual environment
sudo -u www-data python3 -m venv /var/www/souqmatbakh/backend/.venv

# Install dependencies
sudo -u www-data /var/www/souqmatbakh/backend/.venv/bin/pip install --upgrade pip
sudo -u www-data /var/www/souqmatbakh/backend/.venv/bin/pip install -r /var/www/souqmatbakh/backend/requirements.txt
sudo -u www-data /var/www/souqmatbakh/backend/.venv/bin/pip install gunicorn
```

---

## 6. Run Database Migrations

```bash
# Apply migrations to create tables
cd /var/www/souqmatbakh/backend
sudo -u www-data /var/www/souqmatbakh/backend/.venv/bin/alembic upgrade head

# Initialize default data (plans, site settings, admin user)
sudo -u www-data /var/www/souqmatbakh/backend/.venv/bin/python init_default_data.py
```

---

## 7. Install Systemd Service

```bash
# Copy service file
sudo cp /var/www/souqmatbakh/backend/deploy/systemd/souqmatbakh-backend.service \
    /etc/systemd/system/

# Reload systemd
sudo systemctl daemon-reload

# Enable and start service
sudo systemctl enable souqmatbakh-backend
sudo systemctl start souqmatbakh-backend

# Check status
sudo systemctl status souqmatbakh-backend

# View logs
sudo journalctl -u souqmatbakh-backend -f
```

---

## 8. Install Nginx Configuration

```bash
# Copy nginx config
sudo cp /var/www/souqmatbakh/backend/deploy/nginx/souqmatbakh.com.conf \
    /etc/nginx/sites-available/

# Enable site (create symlink)
sudo ln -sf /etc/nginx/sites-available/souqmatbakh.com.conf \
    /etc/nginx/sites-enabled/

# Remove default site (if exists)
sudo rm -f /etc/nginx/sites-enabled/default

# Test nginx configuration
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

---

## 9. Verify Deployment

```bash
# Test HTTPS redirect
curl -I http://souqmatbakh.com
# Should return: 301 Moved Permanently

# Test HTTPS main site
curl -I https://souqmatbakh.com
# Should return: 200 OK

# Test API endpoint
curl -i https://souqmatbakh.com/api/
# Should return: {"message": "Welcome to KitchenTech API"} or similar

# Test API docs (in browser)
# Visit: https://souqmatbakh.com/api/docs

# Check backend logs
sudo journalctl -u souqmatbakh-backend -n 50
```

---

## 10. Security Checklist

```bash
# Verify file permissions
ls -la /var/www/souqmatbakh/backend/.env
# Should be: -rw-r----- or -rw------- owned by www-data

# Ensure .env is not in git
cd /var/www/souqmatbakh/backend
cat .gitignore | grep ".env"
# Should include: .env

# Verify service is running as www-data
ps aux | grep gunicorn | grep www-data

# Check firewall (if UFW enabled)
sudo ufw status
# Should allow: 80/tcp, 443/tcp, 22/tcp (SSH)
```

---

## 11. Deploy Frontend (Flutter Web)

```bash
# Upload built Flutter web files to:
# /var/www/souqmatbakh/frontend/

# Ensure index.html exists
ls -la /var/www/souqmatbakh/frontend/index.html

# Set correct permissions
sudo chown -R www-data:www-data /var/www/souqmatbakh/frontend
```

---

## Troubleshooting

### Service won't start

```bash
# Check detailed logs
sudo journalctl -u souqmatbakh-backend -n 100 --no-pager

# Check if port 8000 is in use
sudo netstat -tulpn | grep 8000

# Verify .env file exists and is readable
sudo -u www-data cat /var/www/souqmatbakh/backend/.env
```

### Database connection errors

```bash
# Test PostgreSQL connection
sudo -u www-data psql -h 127.0.0.1 -U kt_user -d kitchentech_prod -c "SELECT 1;"

# Check PostgreSQL is running
sudo systemctl status postgresql
```

### Nginx errors

```bash
# Check nginx error logs
sudo tail -f /var/log/nginx/souqmatbakh-error.log

# Verify nginx config syntax
sudo nginx -t

# Check if backend is responding
curl http://127.0.0.1:8000/api/
```

---

## Daily Operations

### Deploy new changes

```bash
cd /var/www/souqmatbakh/backend
sudo -u www-data ./deploy/scripts/deploy_backend.sh
```

### View logs

```bash
# Backend service logs
sudo journalctl -u souqmatbakh-backend -f

# Nginx logs
sudo tail -f /var/log/nginx/souqmatbakh-access.log
sudo tail -f /var/log/nginx/souqmatbakh-error.log

# Backend application logs
sudo tail -f /var/log/souqmatbakh/backend-error.log
```

### Restart services

```bash
# Restart backend
sudo systemctl restart souqmatbakh-backend

# Reload nginx
sudo systemctl reload nginx

# Restart PostgreSQL (if needed)
sudo systemctl restart postgresql
```

---

## Default Admin Credentials

**Email**: admin@kitchentech.sa  
**Password**: admin123456

⚠️ **CRITICAL**: Change this password immediately after first login!

---

## Useful Commands

```bash
# Service status
sudo systemctl status souqmatbakh-backend

# Enable service on boot
sudo systemctl enable souqmatbakh-backend

# Disable service
sudo systemctl disable souqmatbakh-backend

# View service configuration
sudo systemctl cat souqmatbakh-backend

# Database backup
sudo -u postgres pg_dump kitchentech_prod > backup_$(date +%Y%m%d).sql

# Database restore
sudo -u postgres psql kitchentech_prod < backup_20251214.sql
```

---

**Setup Complete!** 🚀

Visit: https://souqmatbakh.com/api/docs
