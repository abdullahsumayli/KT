# 🚀 Quick Start: PostgreSQL Migration

## One-Time Setup

### 1. Install PostgreSQL

```bash
# Windows: Download from https://www.postgresql.org/download/windows/
# Linux: sudo apt install postgresql postgresql-contrib
# macOS: brew install postgresql
```

### 2. Create Database

```bash
psql -U postgres
```

```sql
CREATE DATABASE kitchentech_dev;
CREATE USER kt_user WITH PASSWORD 'kt_password';
GRANT ALL PRIVILEGES ON DATABASE kitchentech_dev TO kt_user;
\c kitchentech_dev
GRANT ALL ON SCHEMA public TO kt_user;
\q
```

### 3. Update .env

```env
KT_DATABASE_URL=postgresql+psycopg2://kt_user:kt_password@localhost:5432/kitchentech_dev
```

### 4. Run Migrations

```bash
alembic upgrade head
```

### 5. Initialize Data

```bash
python init_default_data.py
```

### 6. Start Server

```bash
uvicorn app.main:app --reload
```

---

## Daily Commands

### Start Development

```bash
# Activate venv
.venv\Scripts\activate

# Start server
uvicorn app.main:app --reload
```

### Database Migrations

```bash
# Create new migration after model changes
alembic revision --autogenerate -m "Add new field"

# Apply migrations
alembic upgrade head

# Rollback one migration
alembic downgrade -1

# Check current version
alembic current
```

### PostgreSQL Quick Commands

```bash
# Connect
psql -U kt_user -d kitchentech_dev

# List tables: \dt
# Describe table: \d users
# Quit: \q
```

---

## Troubleshooting

### PostgreSQL Not Running

```bash
# Windows
Get-Service postgresql*
Start-Service postgresql-x64-XX

# Linux
sudo systemctl start postgresql
```

### Reset Database (⚠️ Deletes all data!)

```bash
alembic downgrade base
alembic upgrade head
python init_default_data.py
```

### Switch Back to SQLite (Dev Only)

```env
KT_DATABASE_URL=sqlite:///./kitchentech.db
```

---

## API Endpoints

- Docs: http://localhost:8000/docs
- API: http://localhost:8000/api/

**Default Admin**:

- Email: `admin@kitchentech.sa`
- Password: `admin123456` (⚠️ Change immediately!)

---

## Files Changed

### Configuration

- ✅ `app/core/config.py` - KT_DATABASE_URL support
- ✅ `.env` - PostgreSQL URL
- ✅ `.env.example` - Setup instructions

### Database

- ✅ `app/database.py` - Uses migrations now

### New (Alembic)

- ✅ `alembic/` - Migration system
- ✅ `alembic.ini` - Configuration
- ✅ `alembic/versions/a1b2c3d4e5f6_*.py` - Initial migration

### Documentation

- ✅ `backend/README.md` - Full guide
- ✅ `backend/MIGRATION_SUMMARY.md` - Detailed changes
- ✅ `backend/QUICK_START.md` - This file

---

## Key Notes

- ✅ PostgreSQL required for **production**
- ✅ SQLite allowed for **development** only
- ✅ All 8 tables included in migration
- ✅ No business logic changes
- ✅ No API contract changes

For full details, see: `MIGRATION_SUMMARY.md`
