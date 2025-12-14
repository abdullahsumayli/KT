#!/bin/bash
set -e

NEW_DB_PASS="KT_Secure_DB_v2_2025_Qx9pLm8Rw3"

# Update PostgreSQL password
sudo -u postgres psql -d postgres -c "ALTER USER ktuser WITH PASSWORD '$NEW_DB_PASS';"

# Update .env file
sed -i "s#^KT_DATABASE_URL=.*#KT_DATABASE_URL=postgresql+psycopg2://ktuser:$NEW_DB_PASS@127.0.0.1:5432/kitchentech_db#" /var/www/souqmatbakh/backend/.env

# Restart backend
systemctl restart souqmatbakh-backend
sleep 2

# Verify
if curl -fsS https://souqmatbakh.com/api/ >/dev/null; then
    echo "✅ DB Password Rotated Successfully"
    echo "New password: $NEW_DB_PASS"
else
    echo "❌ API Check Failed"
    exit 1
fi
