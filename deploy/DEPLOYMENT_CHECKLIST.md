# 📋 Deployment Checklist - souqmatbakh.com

Use this checklist to verify your Hetzner production deployment.

---

## Pre-Deployment (Local)

- [ ] All code changes committed to git
- [ ] Tests pass locally
- [ ] Database migrations tested locally
- [ ] Environment variables documented
- [ ] No secrets in code repository
- [ ] `.gitignore` includes `.env`

---

## Server Prerequisites

- [ ] Ubuntu 22.04+ installed
- [ ] Nginx installed and running
- [ ] PostgreSQL installed and running
- [ ] SSL certificate installed (Let's Encrypt)
- [ ] DNS records pointing to server (91.99.106.230)
- [ ] Firewall configured (ports 22, 80, 443)
- [ ] Python 3.10+ installed
- [ ] Git installed

---

## First-Time Setup

Use [first_time_server_setup.md](scripts/first_time_server_setup.md) and check off:

### 1. Server Directories

- [ ] Created `/var/www/souqmatbakh/backend`
- [ ] Created `/var/www/souqmatbakh/frontend`
- [ ] Created `/var/log/souqmatbakh`
- [ ] Set ownership to `www-data:www-data`

### 2. Database Setup

- [ ] Created PostgreSQL database: `kitchentech_prod`
- [ ] Created PostgreSQL user: `kt_user`
- [ ] Granted all privileges
- [ ] Tested connection

### 3. Backend Configuration

- [ ] Cloned repository to `/var/www/souqmatbakh/backend`
- [ ] Copied `.env` from `deploy/backend.env.prod.example`
- [ ] Generated secure `KT_SECRET_KEY` (64+ chars)
- [ ] Updated database credentials in `.env`
- [ ] Set `APP_ENV=prod` and `KT_DEBUG=False`
- [ ] Verified CORS origins

### 4. Python Environment

- [ ] Created virtual environment at `.venv`
- [ ] Installed requirements.txt
- [ ] Installed gunicorn
- [ ] Verified all packages installed

### 5. Database Migrations

- [ ] Ran `alembic upgrade head` successfully
- [ ] Verified all 8 tables created
- [ ] Ran `python init_default_data.py`
- [ ] Verified default plans and admin user created

### 6. Systemd Service

- [ ] Copied service file to `/etc/systemd/system/`
- [ ] Ran `daemon-reload`
- [ ] Enabled service
- [ ] Started service
- [ ] Verified service running: `systemctl status souqmatbakh-backend`

### 7. Nginx Configuration

- [ ] Copied nginx config to `/etc/nginx/sites-available/`
- [ ] Created symlink in `/etc/nginx/sites-enabled/`
- [ ] Removed default site
- [ ] Tested config: `nginx -t`
- [ ] Reloaded nginx

### 8. Verification

- [ ] HTTP redirects to HTTPS: `curl -I http://souqmatbakh.com`
- [ ] HTTPS returns 200: `curl -I https://souqmatbakh.com`
- [ ] API responds: `curl https://souqmatbakh.com/api/`
- [ ] API docs accessible: https://souqmatbakh.com/api/docs
- [ ] Can login with admin account
- [ ] Changed default admin password

---

## Security Hardening

- [ ] `.env` file permissions: `chmod 640 .env`
- [ ] `.env` owned by `www-data:www-data`
- [ ] SSH key-based authentication enabled
- [ ] Root login disabled
- [ ] UFW firewall enabled
- [ ] Fail2ban installed (optional but recommended)
- [ ] Automatic security updates enabled
- [ ] SSL certificate auto-renewal configured
- [ ] Database backups scheduled

---

## Regular Deployment (Updates)

Use [deploy_backend.sh](scripts/deploy_backend.sh) and verify:

- [ ] SSH into server: `ssh root@91.99.106.230`
- [ ] Navigate: `cd /var/www/souqmatbakh/backend`
- [ ] Run script: `sudo -u www-data ./deploy/scripts/deploy_backend.sh`
- [ ] Script completes without errors
- [ ] Service restarts successfully
- [ ] API responding: `curl https://souqmatbakh.com/api/`
- [ ] Check logs: `sudo journalctl -u souqmatbakh-backend -n 50`

---

## Post-Deployment Verification

### Health Checks

- [ ] Backend service running: `systemctl status souqmatbakh-backend`
- [ ] Nginx running: `systemctl status nginx`
- [ ] PostgreSQL running: `systemctl status postgresql`
- [ ] API health: `curl https://souqmatbakh.com/api/`
- [ ] Frontend loads: `curl -I https://souqmatbakh.com`

### Functional Tests

- [ ] User registration works
- [ ] User login works
- [ ] Create listing works
- [ ] Upload images works
- [ ] Admin dashboard accessible
- [ ] Plans page loads
- [ ] Contact form works

### Performance

- [ ] Response time < 500ms
- [ ] No 500 errors in logs
- [ ] Database queries performant
- [ ] Media files loading

### Monitoring

- [ ] Review access logs: `tail -f /var/log/nginx/souqmatbakh-access.log`
- [ ] Review error logs: `tail -f /var/log/nginx/souqmatbakh-error.log`
- [ ] Review backend logs: `journalctl -u souqmatbakh-backend -f`
- [ ] Check disk space: `df -h`
- [ ] Check memory usage: `free -h`

---

## Rollback (If Issues)

If deployment causes problems:

- [ ] Identify issue from logs
- [ ] Roll back code: `git reset --hard <previous-commit>`
- [ ] Roll back migrations: `alembic downgrade -1`
- [ ] Restart service: `systemctl restart souqmatbakh-backend`
- [ ] Or restore from backup

---

## Maintenance Tasks

### Daily

- [ ] Monitor error logs
- [ ] Check disk space
- [ ] Verify service uptime

### Weekly

- [ ] Review access logs for anomalies
- [ ] Check SSL certificate expiry
- [ ] Review database performance

### Monthly

- [ ] System updates: `apt update && apt upgrade`
- [ ] Database backup verification
- [ ] Security audit
- [ ] Clean old logs: `journalctl --vacuum-time=30d`

---

## Emergency Contacts

- **Server**: 91.99.106.230
- **Domain**: souqmatbakh.com
- **Hosting**: Hetzner
- **SSL Provider**: Let's Encrypt

---

## Useful Commands

```bash
# Service management
sudo systemctl status souqmatbakh-backend
sudo systemctl restart souqmatbakh-backend
sudo systemctl reload nginx

# Logs
sudo journalctl -u souqmatbakh-backend -f
sudo tail -f /var/log/nginx/souqmatbakh-error.log

# Database
sudo -u postgres psql kitchentech_prod

# Backup
sudo -u postgres pg_dump kitchentech_prod > backup.sql

# Disk space
df -h
du -sh /var/www/souqmatbakh/*

# Process monitoring
htop
ps aux | grep gunicorn
```

---

**Deployment Date**: ******\_******  
**Deployed By**: ******\_******  
**Git Commit**: ******\_******

**Status**: ✅ Deployed Successfully | ⚠️ Issues | ❌ Failed
