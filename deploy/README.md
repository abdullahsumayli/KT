# KitchenTech Deployment Assets

Production deployment configuration for KitchenTech backend on Hetzner Ubuntu server.

**Server**: 91.99.106.230  
**Domain**: souqmatbakh.com  
**Stack**: Nginx + Gunicorn + Uvicorn + PostgreSQL + Let's Encrypt SSL

---

## 📁 Directory Structure

```
deploy/
├── ONE_COMMAND_SERVER_SETUP.sh      # 🚀 Complete automated setup script
├── DEPLOYMENT_CHECKLIST.md          # Step-by-step verification checklist
├── backend.env.prod.example         # Production environment variables template
├── systemd/
│   └── souqmatbakh-backend.service  # Systemd service unit
├── nginx/
│   └── souqmatbakh.com.conf         # Nginx server configuration
├── scripts/
│   ├── deploy_backend.sh            # Automated deployment script
│   ├── first_time_server_setup.md   # Initial server setup guide
│   └── verify_deployment_assets.sh  # Asset verification script
└── README.md                         # This file
```

---

## 🚀 Quick Start

### ⚡ One-Command Deployment

The **fastest way** to deploy - choose one:

#### Option A: Remote Deployment from Windows PowerShell

Run this single command from your Windows machine (PowerShell):

```powershell
ssh root@91.99.106.230 "cd /tmp && rm -rf KT && git clone https://github.com/abdullahsumayli/KT.git && bash KT/deploy/ONE_COMMAND_SERVER_SETUP.sh"
```

This will:

1. Clone the repository on the server
2. Run the complete automated setup
3. Show you the results

#### Option B: Run Directly on Server

If you're already logged into the server:

```bash
# One-time: Clone repo if not already done
cd /var/www/souqmatbakh
git clone https://github.com/abdullahsumayli/KT.git backend

# Run setup (or re-run to update)
bash /var/www/souqmatbakh/backend/deploy/ONE_COMMAND_SERVER_SETUP.sh
```

**What the script does automatically**:

- ✅ Installs required packages (nginx, git, python3-venv)
- ✅ Creates directory structure
- ✅ Clones/updates repository to `/var/www/souqmatbakh/backend`
- ✅ Auto-generates secure secret key in `.env` (if missing)
- ✅ Sets up Python virtual environment
- ✅ Installs all dependencies + gunicorn
- ✅ Runs database migrations (`alembic upgrade head`)
- ✅ Configures systemd service
- ✅ Configures nginx reverse proxy
- ✅ Runs comprehensive health checks
- ✅ Shows diagnostics if any issues

**Prerequisites** (must be installed manually):

- ✅ PostgreSQL with database created
- ✅ SSL certificate (Let's Encrypt/certbot)
- ✅ DNS pointing to server (91.99.106.230)

**After running the script**:

1. Edit `/var/www/souqmatbakh/backend/.env` with your PostgreSQL password
2. Run `systemctl restart souqmatbakh-backend`
3. Change default admin password (admin@kitchentech.sa / admin123456)
4. Deploy frontend files to `/var/www/souqmatbakh/frontend`

The script is **idempotent** - safe to run multiple times!

---

### 📖 Alternative: Step-by-Step Manual Setup

If you prefer step-by-step manual setup, follow the complete guide:

- **[scripts/first_time_server_setup.md](scripts/first_time_server_setup.md)**

---

### 🔄 Deploying Updates (Existing Server)

For routine updates after initial setup:

```bash
# SSH into server
ssh root@91.99.106.230

# Navigate to backend directory
cd /var/www/souqmatbakh/backend

# Run automated deployment script
sudo -u www-data ./deploy/scripts/deploy_backend.sh
```

This script handles:

- Pulling latest code
- Installing dependencies
- Running migrations
- Restarting service
- Health verification

---

## 📄 Configuration Files

## 📄 Configuration Files

### 1. Environment Variables (`backend.env.prod.example`)

Template for production environment variables. Copy to `.env` on server and fill in actual values:

```bash
cp deploy/backend.env.prod.example /var/www/souqmatbakh/backend/.env
nano /var/www/souqmatbakh/backend/.env
```

**Required variables**:

- `APP_ENV` - Set to `prod`
- `KT_SECRET_KEY` - Random secure key (min 32 chars)
- `KT_DATABASE_URL` - PostgreSQL connection string
- `KT_ALLOWED_ORIGINS` - CORS allowed domains
- `KT_DEBUG` - Set to `False` in production

### 2. Systemd Service (`systemd/souqmatbakh-backend.service`)

Manages backend as a system service.

**Installation**:

```bash
sudo cp deploy/systemd/souqmatbakh-backend.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable souqmatbakh-backend
sudo systemctl start souqmatbakh-backend
```

**Management**:

```bash
sudo systemctl status souqmatbakh-backend    # Check status
sudo systemctl restart souqmatbakh-backend   # Restart service
sudo journalctl -u souqmatbakh-backend -f    # View logs
```

### 3. Nginx Configuration (`nginx/souqmatbakh.com.conf`)

Reverse proxy configuration for frontend + backend.

**Installation**:

```bash
sudo cp deploy/nginx/souqmatbakh.com.conf /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/souqmatbakh.com.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

**Features**:

- HTTP to HTTPS redirect
- SSL/TLS termination
- API proxy to backend (127.0.0.1:8000)
- Static file serving for Flutter web
- Media file caching
- Gzip compression

---

## 🛠️ Deployment Script

### `scripts/deploy_backend.sh`

Automated deployment script that:

1. Pulls latest code from git
2. Updates Python virtual environment
3. Installs dependencies (including gunicorn)
4. Runs database migrations
5. Restarts systemd service
6. Verifies deployment

**Usage**:

```bash
cd /var/www/souqmatbakh/backend
sudo -u www-data ./deploy/scripts/deploy_backend.sh
```

**Features**:

- Idempotent (safe to run multiple times)
- Error handling and rollback
- Service health verification
- Automatic log display on failure

---

## 📋 Prerequisites

Before deployment, ensure server has:

- ✅ Ubuntu 22.04+ (or compatible Linux)
- ✅ Nginx installed and configured
- ✅ PostgreSQL installed and running
- ✅ SSL certificate (Let's Encrypt) for souqmatbakh.com
- ✅ Python 3.10+ installed
- ✅ Git installed
- ✅ Domain DNS pointing to server IP (91.99.106.230)

---

## 🔐 Security Checklist

### Server Security

- [ ] UFW firewall enabled (ports 22, 80, 443)
- [ ] SSH key-based authentication
- [ ] Root login disabled
- [ ] Regular security updates (`apt update && apt upgrade`)

### Application Security

- [ ] `.env` file has restricted permissions (600 or 640)
- [ ] `KT_SECRET_KEY` is random and secure (64+ chars)
- [ ] Database password is strong and unique
- [ ] `KT_DEBUG=False` in production
- [ ] Default admin password changed after first login
- [ ] CORS origins limited to actual domains

### SSL/TLS

- [ ] SSL certificate valid and auto-renewing
- [ ] HTTPS enforced (HTTP redirects)
- [ ] TLS 1.2+ only
- [ ] HSTS header enabled

---

## 📊 Monitoring

### Service Status

```bash
# Check backend service
sudo systemctl status souqmatbakh-backend

# Check nginx
sudo systemctl status nginx

# Check PostgreSQL
sudo systemctl status postgresql
```

### Logs

```bash
# Backend application logs
sudo journalctl -u souqmatbakh-backend -f
sudo tail -f /var/log/souqmatbakh/backend-error.log

# Nginx logs
sudo tail -f /var/log/nginx/souqmatbakh-access.log
sudo tail -f /var/log/nginx/souqmatbakh-error.log

# PostgreSQL logs
sudo tail -f /var/log/postgresql/postgresql-14-main.log
```

### Health Checks

```bash
# Test backend directly
curl http://127.0.0.1:8000/api/

# Test through nginx
curl https://souqmatbakh.com/api/

# Test frontend
curl -I https://souqmatbakh.com
```

---

## 🔄 Rollback Procedure

If deployment fails or causes issues:

### 1. Rollback Code

```bash
cd /var/www/souqmatbakh/backend
sudo -u www-data git log --oneline -10  # Find last good commit
sudo -u www-data git reset --hard <commit-hash>
sudo systemctl restart souqmatbakh-backend
```

### 2. Rollback Database

```bash
cd /var/www/souqmatbakh/backend
sudo -u www-data .venv/bin/alembic downgrade -1  # Go back one migration
sudo systemctl restart souqmatbakh-backend
```

### 3. Restore from Backup

```bash
# Stop backend
sudo systemctl stop souqmatbakh-backend

# Restore database
sudo -u postgres psql kitchentech_prod < backup_YYYYMMDD.sql

# Start backend
sudo systemctl start souqmatbakh-backend
```

---

## 📞 Troubleshooting

### Backend won't start

```bash
# Check logs for errors
sudo journalctl -u souqmatbakh-backend -n 100 --no-pager

# Verify environment variables
sudo -u www-data cat /var/www/souqmatbakh/backend/.env

# Test manually
cd /var/www/souqmatbakh/backend
sudo -u www-data .venv/bin/gunicorn app.main:app --bind 127.0.0.1:8000 --workers 1 --worker-class uvicorn.workers.UvicornWorker
```

### Database connection issues

```bash
# Test PostgreSQL connection
sudo -u www-data psql -h 127.0.0.1 -U kt_user -d kitchentech_prod -c "SELECT version();"

# Check PostgreSQL status
sudo systemctl status postgresql

# Check database exists
sudo -u postgres psql -l | grep kitchentech
```

### Nginx errors

```bash
# Test configuration
sudo nginx -t

# Check error logs
sudo tail -f /var/log/nginx/souqmatbakh-error.log

# Verify backend is listening
sudo netstat -tulpn | grep 8000
```

---

## 📚 Additional Resources

- [First-Time Server Setup Guide](scripts/first_time_server_setup.md)
- [Backend README](../backend/README.md)
- [Database Migration Guide](../backend/MIGRATION_SUMMARY.md)

---

## 🤝 Support

For deployment issues or questions:

1. Check troubleshooting section above
2. Review logs: `sudo journalctl -u souqmatbakh-backend -f`
3. Verify all prerequisites are met
4. Check [first_time_server_setup.md](scripts/first_time_server_setup.md)

---

**Last Updated**: December 2025
