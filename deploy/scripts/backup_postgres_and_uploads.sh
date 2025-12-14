#!/bin/bash
set -euo pipefail

# Backup script for KitchenTech PostgreSQL database and uploads
# Usage: Run daily via systemd timer
# Output: Compressed backups in /var/backups/souqmatbakh/{db,uploads}
# Rotation: Keeps last 7 days

# Configuration
BACKUP_BASE_DIR="/var/backups/souqmatbakh"
DB_BACKUP_DIR="${BACKUP_BASE_DIR}/db"
UPLOADS_BACKUP_DIR="${BACKUP_BASE_DIR}/uploads"
LOG_FILE="/var/log/souqmatbakh/backup.log"
ENV_FILE="/var/www/souqmatbakh/backend/.env"
UPLOADS_DIR="/var/www/souqmatbakh/backend/uploads"
RETENTION_DAYS=7

# Create directories
mkdir -p "${DB_BACKUP_DIR}" "${UPLOADS_BACKUP_DIR}"
mkdir -p "$(dirname "${LOG_FILE}")"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "${LOG_FILE}"
}

log "=== Backup started ==="

# Parse DATABASE_URL from .env
if [[ ! -f "${ENV_FILE}" ]]; then
    log "ERROR: Environment file not found: ${ENV_FILE}"
    exit 1
fi

# Extract KT_DATABASE_URL (format: postgresql://user:password@host:port/dbname or postgresql://user:password@host/dbname)
DB_URL=$(grep '^KT_DATABASE_URL=' "${ENV_FILE}" | cut -d= -f2- | tr -d '"' | tr -d "'")

if [[ -z "${DB_URL}" ]]; then
    log "ERROR: KT_DATABASE_URL not found in ${ENV_FILE}"
    exit 1
fi

# Parse connection details (support postgresql:// or postgres://)
DB_URL="${DB_URL#postgresql://}"
DB_URL="${DB_URL#postgres://}"

# Extract user:password@host:port/dbname
if [[ "${DB_URL}" =~ ^([^:]+):([^@]+)@([^:/]+)(:([0-9]+))?/(.+)$ ]]; then
    DB_USER="${BASH_REMATCH[1]}"
    DB_PASS="${BASH_REMATCH[2]}"
    DB_HOST="${BASH_REMATCH[3]}"
    DB_PORT="${BASH_REMATCH[5]:-5432}"
    DB_NAME="${BASH_REMATCH[6]}"
else
    log "ERROR: Failed to parse KT_DATABASE_URL format"
    exit 1
fi

# Normalize localhost
if [[ "${DB_HOST}" == "localhost" ]]; then
    DB_HOST="127.0.0.1"
fi

log "Database: ${DB_NAME} on ${DB_HOST}:${DB_PORT} as ${DB_USER}"

# Create backup filename with timestamp
TIMESTAMP=$(date '+%Y%m%d_%H%M')
DB_BACKUP_FILE="${DB_BACKUP_DIR}/kitchentech_db_${TIMESTAMP}.sql.gz"

# Perform PostgreSQL backup (NEVER echo password)
log "Backing up PostgreSQL database to ${DB_BACKUP_FILE}"
export PGPASSWORD="${DB_PASS}"

if pg_dump -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" | gzip > "${DB_BACKUP_FILE}"; then
    log "SUCCESS: Database backup completed ($(du -h "${DB_BACKUP_FILE}" | cut -f1))"
else
    log "ERROR: Database backup failed"
    unset PGPASSWORD
    exit 1
fi

unset PGPASSWORD

# Backup uploads directory if it exists
if [[ -d "${UPLOADS_DIR}" ]] && [[ -n "$(ls -A "${UPLOADS_DIR}" 2>/dev/null)" ]]; then
    UPLOADS_BACKUP_FILE="${UPLOADS_BACKUP_DIR}/uploads_${TIMESTAMP}.tar.gz"
    log "Backing up uploads directory to ${UPLOADS_BACKUP_FILE}"
    
    if tar -czf "${UPLOADS_BACKUP_FILE}" -C "$(dirname "${UPLOADS_DIR}")" "$(basename "${UPLOADS_DIR}")"; then
        log "SUCCESS: Uploads backup completed ($(du -h "${UPLOADS_BACKUP_FILE}" | cut -f1))"
    else
        log "WARNING: Uploads backup failed (non-critical)"
    fi
else
    log "INFO: No uploads directory to backup"
fi

# Rotation: Delete backups older than RETENTION_DAYS
log "Rotating old backups (keeping last ${RETENTION_DAYS} days)"

# Delete old database backups
find "${DB_BACKUP_DIR}" -name "kitchentech_db_*.sql.gz" -type f -mtime +${RETENTION_DAYS} -delete 2>/dev/null || true
DB_BACKUP_COUNT=$(find "${DB_BACKUP_DIR}" -name "kitchentech_db_*.sql.gz" -type f | wc -l)
log "Database backups retained: ${DB_BACKUP_COUNT}"

# Delete old uploads backups
find "${UPLOADS_BACKUP_DIR}" -name "uploads_*.tar.gz" -type f -mtime +${RETENTION_DAYS} -delete 2>/dev/null || true
UPLOADS_BACKUP_COUNT=$(find "${UPLOADS_BACKUP_DIR}" -name "uploads_*.tar.gz" -type f | wc -l)
log "Uploads backups retained: ${UPLOADS_BACKUP_COUNT}"

log "=== Backup completed successfully ==="
exit 0
