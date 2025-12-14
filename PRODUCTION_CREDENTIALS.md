# 🔐 بيانات الوصول المحدّثة - KitchenTech Production

**Date**: December 14, 2025  
**Server**: 91.99.106.230 (souqmatbakh.com)  
**Commit**: 99d1f58

---

## ✅ التحديثات المنفذة (Completed Tasks)

### 1️⃣ تدوير كلمة مرور PostgreSQL ✅

- **Database**: kitchentech_db
- **User**: ktuser
- **كلمة المرور الجديدة**: `KT_Secure_DB_v2_2025_Qx9pLm8Rw3`
- **Connection String**:
  ```
  postgresql+psycopg2://ktuser:KT_Secure_DB_v2_2025_Qx9pLm8Rw3@127.0.0.1:5432/kitchentech_db
  ```

### 2️⃣ تدوير كلمة مرور الأدمن ✅

- **Email**: admin@kitchentech.sa
- **كلمة المرور الجديدة**: `KTAdmin@2025#Secure`
- **⚠️ ملاحظة**: غيّر كلمة المرور من لوحة التحكم فوراً!

### 3️⃣ نقل .env خارج الريبو ✅

- **الموقع القديم**: `/var/www/souqmatbakh/backend/.env` (محفوظ كنسخة احتياطية)
- **الموقع الجديد**: `/etc/souqmatbakh/backend.env` ✅
- **الصلاحيات**: `600` (root:root)
- **Systemd**: محدّث للإشارة إلى الموقع الجديد ✅

### 4️⃣ إصلاح النسخ الاحتياطي ✅

- **مسار النسخ الاحتياطي**: `/var/backups/souqmatbakh/`
  - Database backups: `/var/backups/souqmatbakh/db/`
  - Uploads backups: `/var/backups/souqmatbakh/uploads/`
- **التكرار**: يومياً الساعة 03:15 UTC
- **الاحتفاظ**: آخر 7 أيام
- **الحالة**: ✅ تم اختباره بنجاح
- **آخر نسخة احتياطية**: `kitchentech_db_20251214_0853.sql.gz (4.0K)`

### 5️⃣ التحقق السريع من الخدمات ✅

```bash
ssh root@91.99.106.230 "bash -lc 'systemctl is-active souqmatbakh-backend && \
  systemctl is-active souqmatbakh-backup.timer && \
  systemctl is-active souqmatbakh-healthcheck.timer && \
  curl -fsS https://souqmatbakh.com/ >/dev/null && \
  curl -fsS https://souqmatbakh.com/api/ >/dev/null && \
  echo OPS_OK'"
```

**النتيجة**: `OPS_OK` ✅

---

## 📋 جميع بيانات الوصول (All Credentials)

### 🗄️ قاعدة البيانات (Database)

```
Host: 127.0.0.1
Port: 5432
Database: kitchentech_db
User: ktuser
Password: KT_Secure_DB_v2_2025_Qx9pLm8Rw3
```

### 👤 حساب الأدمن (Admin Account)

```
Email: admin@kitchentech.sa
Password: KTAdmin@2025#Secure
URL: https://souqmatbakh.com/admin (أو /docs للـ API)
```

### 🔑 متغيرات البيئة (Environment Variables)

**الملف**: `/etc/souqmatbakh/backend.env`

```bash
APP_NAME=KitchenTech API
APP_VERSION=2.0.0
APP_ENV=prod
KT_DATABASE_URL=postgresql+psycopg2://ktuser:KT_Secure_DB_v2_2025_Qx9pLm8Rw3@127.0.0.1:5432/kitchentech_db
KT_SECRET_KEY=[generated 32-byte hex key]
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
ALLOWED_ORIGINS=https://souqmatbakh.com,https://www.souqmatbakh.com
OPENAI_API_KEY=
```

---

## 🛠️ الخدمات النشطة (Active Services)

### Backend API

- **Service**: `souqmatbakh-backend.service`
- **Status**: ✅ Active (running)
- **Port**: 8000 (localhost)
- **Workers**: 2 Gunicorn + Uvicorn
- **Logs**: `/var/log/souqmatbakh/backend-*.log`

### Backup Timer

- **Service**: `souqmatbakh-backup.timer`
- **Status**: ✅ Active
- **Schedule**: Daily at 03:15 UTC
- **Script**: `/var/www/souqmatbakh/backend/deploy/scripts/backup_postgres_and_uploads.sh`
- **Output**: `/var/backups/souqmatbakh/`
- **Log**: `/var/log/souqmatbakh/backup.log`

### Healthcheck Timer

- **Service**: `souqmatbakh-healthcheck.timer`
- **Status**: ✅ Active
- **Schedule**: Every 5 minutes
- **Script**: `/var/www/souqmatbakh/backend/deploy/scripts/healthcheck_and_restart.sh`
- **Log**: `/var/log/souqmatbakh/healthcheck.log`

### Nginx

- **Config**: `/etc/nginx/sites-available/souqmatbakh.com.conf`
- **Features**:
  - Gzip compression ✅
  - Cache headers (1-year for assets, no-cache for HTML) ✅
  - SSL/TLS ✅
  - Rate limiting ✅

---

## 📂 مسارات الملفات المهمة (Important Paths)

```
Application Root:     /var/www/souqmatbakh/backend/
Environment Config:   /etc/souqmatbakh/backend.env
Python venv:          /var/www/souqmatbakh/backend/venv/
Media uploads:        /var/www/souqmatbakh/backend/media/
Backups:              /var/backups/souqmatbakh/
Logs:                 /var/log/souqmatbakh/
Systemd units:        /etc/systemd/system/souqmatbakh-*
```

---

## 🔒 ملاحظات الأمان (Security Notes)

1. ✅ **كلمات المرور**: تم تدويرها بنجاح (DB + Admin)
2. ✅ **ملف .env**: منقول خارج الريبو إلى `/etc/souqmatbakh/`
3. ✅ **الصلاحيات**: `600` على ملف .env (root:root فقط)
4. ⚠️ **مهم**: غيّر كلمة مرور الأدمن من لوحة التحكم فوراً!
5. ✅ **النسخ الاحتياطي**: يعمل يومياً ويحفظ آخر 7 أيام
6. ✅ **المراقبة**: healthcheck كل 5 دقائق مع إعادة تشغيل تلقائية

---

## 🧪 اختبار سريع (Quick Test)

```bash
# 1. Test API
curl -s https://souqmatbakh.com/api/
# Expected: {"message":"Welcome to KitchenTech API","version":"2.0.0"...}

# 2. Test Frontend
curl -I https://souqmatbakh.com/
# Expected: HTTP/2 200

# 3. Check services
ssh root@91.99.106.230 "systemctl status souqmatbakh-backend --no-pager | head -5"

# 4. Check backup
ssh root@91.99.106.230 "ls -lh /var/backups/souqmatbakh/db/ | tail -5"

# 5. Check logs
ssh root@91.99.106.230 "tail -10 /var/log/souqmatbakh/backup.log"
```

---

## 📝 سجل التغييرات (Changelog)

### December 14, 2025 - Security Hardening

- ✅ Rotated PostgreSQL password (ktuser)
- ✅ Rotated Admin password
- ✅ Moved .env to external secure location (`/etc/souqmatbakh/`)
- ✅ Fixed backup script to support `postgresql+psycopg2://` URLs
- ✅ Fixed backup script to use new .env location
- ✅ Tested all services - OPS_OK ✅

### Git Commits

- `99d1f58` - fix: update backup script for external env and psycopg2 URL format
- `3549848` - fix: correct PlanType enum handling and admin password
- `46fa769` - fix: correct plans table migration - add description column and fix enum values
- `f536236` - ops: add backups, caching, healthcheck timers

---

**🎉 جميع الأنظمة تعمل بشكل صحيح!**

**Status**: ✅ Production Ready  
**Last Verified**: 2025-12-14 08:53 UTC
