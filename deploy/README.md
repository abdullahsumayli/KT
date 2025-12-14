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

## �️ Ops Pack - Production Operations

KitchenTech includes automated operational tools for production monitoring, backups, and self-healing.

### Components Installed

The Ops Pack includes:

1. **Daily Database & Uploads Backup** (03:15 UTC daily)

   - Automated PostgreSQL dumps with gzip compression
   - Uploads directory archival (if exists)
   - 7-day retention policy
   - Logs: `/var/log/souqmatbakh/backup.log`

2. **API Health Monitoring & Auto-Restart** (every 5 minutes)

   - Checks frontend and API endpoints
   - Auto-restarts backend service if API fails
   - Smart logging (only logs state changes)
   - Logs: `/var/log/souqmatbakh/healthcheck.log`

3. **Nginx Caching for Flutter Assets**
   - Immutable assets (JS, CSS, WASM): 1-year cache
   - Dynamic content (index.html, service worker): no cache
   - Gzip compression enabled

### Monitoring Commands

Check operational status:

```bash
# Verify all components running
sudo bash /var/www/souqmatbakh/deploy/scripts/ops_verify.sh

# Check timer status
systemctl status souqmatbakh-backup.timer
systemctl status souqmatbakh-healthcheck.timer

# List all timers
systemctl list-timers | grep souqmatbakh

# View recent backup logs
tail -f /var/log/souqmatbakh/backup.log

# View healthcheck logs
tail -f /var/log/souqmatbakh/healthcheck.log

# Check backup files
ls -lh /var/backups/souqmatbakh/db/
ls -lh /var/backups/souqmatbakh/uploads/
```

### Manual Operations

Trigger manual backup:

```bash
sudo systemctl start souqmatbakh-backup.service
```

Trigger manual healthcheck:

```bash
sudo systemctl start souqmatbakh-healthcheck.service
```

Restore from backup:

```bash
# List available backups
ls -lh /var/backups/souqmatbakh/db/

# Restore database (example)
sudo systemctl stop souqmatbakh-backend
gunzip -c /var/backups/souqmatbakh/db/kitchentech_db_20251214_0315.sql.gz | \
  sudo -u postgres psql -d kitchentech_db
sudo systemctl start souqmatbakh-backend
```

### Backup Retention

- **Database**: Last 7 days retained
- **Uploads**: Last 7 days retained
- **Location**: `/var/backups/souqmatbakh/{db,uploads}/`
- **Format**:
  - DB: `kitchentech_db_YYYYmmdd_HHMM.sql.gz`
  - Uploads: `uploads_YYYYmmdd_HHMM.tar.gz`

### Customizing Timers

Edit timer schedules:

```bash
# Backup timer (default: 03:15 UTC daily)
sudo systemctl edit souqmatbakh-backup.timer

# Healthcheck timer (default: every 5 minutes)
sudo systemctl edit souqmatbakh-healthcheck.timer

# After changes, reload
sudo systemctl daemon-reload
```

---

## 🛡️ Rate Limiting & Abuse Protection

### Overview

Production-grade rate limiting is implemented at **two layers** for defense in depth:

1. **Nginx (Primary Shield)**: Network-level rate limiting before requests reach the application
2. **FastAPI (Secondary Shield)**: Application-level rate limiting with slowapi

### Rate Limit Configuration

#### Nginx Limits (Network Layer)

- **Global API**: 20 requests/second (burst: 40)
- **Auth Endpoints**: 5 requests/minute (burst: 10)
- **Status Code**: HTTP 429 (Too Many Requests)

Configured in:

- `/etc/nginx/nginx.conf` - Rate limiting zones
- `/etc/nginx/sites-available/souqmatbakh.com.conf` - Applied limits

#### FastAPI Limits (Application Layer)

- **Login**: 5 requests/minute per IP
- **Registration**: 3 requests/minute per IP
- **Phone Login**: 5 requests/minute per IP

Implemented with `slowapi` decorators on auth endpoints.

### Testing Rate Limits

```bash
# Test auth endpoint rate limiting
for i in {1..7}; do
  curl -X POST https://souqmatbakh.com/api/v1/auth/login \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -d 'username=test@test.com&password=test'
  echo ""
  sleep 11
done

# Should see 401 (Unauthorized) for first 5 requests
# Then 429 (Rate limit exceeded) on 6th request
```

### Adjusting Limits

**To modify Nginx rate limits:**

```bash
# Edit nginx.conf
sudo nano /etc/nginx/nginx.conf

# Find these lines:
limit_req_zone $binary_remote_addr zone=global_limit:10m rate=20r/s;
limit_req_zone $binary_remote_addr zone=auth_limit:10m rate=5r/m;

# Adjust rate= values:
# - rate=20r/s means 20 requests per second
# - rate=5r/m means 5 requests per minute

# Test and reload
sudo nginx -t && sudo systemctl reload nginx
```

**To modify FastAPI rate limits:**

Edit `backend/app/routes/auth.py`:

```python
@limiter.limit("5/minute")  # Change this value
async def login(...):
    ...
```

Then restart backend:

```bash
sudo systemctl restart souqmatbakh-backend
```

### Monitoring Rate Limiting

```bash
# Check nginx rate limiting in logs
sudo tail -f /var/log/nginx/souqmatbakh-access.log | grep ' 429 '

# Check backend rate limiting logs
sudo journalctl -u souqmatbakh-backend -f | grep 'Rate limit'

# View rate limit header
curl -I https://souqmatbakh.com/api/ | grep -i 'x-rate'
# Returns: x-ratelimit-policy: global=20r/s, auth=5r/m
```

### Whitelisting IPs (if needed)

To allow specific IPs to bypass rate limits:

```bash
# Edit nginx site config
sudo nano /etc/nginx/sites-available/souqmatbakh.com.conf

# Add before limit_req directives:
geo $limit {
    default 1;
    91.99.106.230 0;  # Server IP
    1.2.3.4 0;        # Your office IP
}

map $limit $limit_key {
    0 "";
    1 $binary_remote_addr;
}

# Change limit_req_zone to use $limit_key instead of $binary_remote_addr
```

### Important Notes

- **Both layers active**: Nginx catches most abuse, FastAPI provides fine-grained control
- **No business logic changes**: Rate limiting is transparent to application code
- **Production-ready**: Tested and verified working
- **Reversible**: Can be adjusted or removed without code changes

---

## �📞 Troubleshooting

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
