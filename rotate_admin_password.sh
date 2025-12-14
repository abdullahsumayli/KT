#!/bin/bash
set -e

ADMIN_EMAIL="admin@kitchentech.sa"
NEW_ADMIN_PASS="KTAdmin_Secure_2025_Mx7Zp4Qw9"

cd /var/www/souqmatbakh/backend
source venv/bin/activate

# Generate bcrypt hash
HASH=$(python3 - <<PYEND
from passlib.context import CryptContext
pwd = CryptContext(schemes=["bcrypt"], deprecated="auto")
print(pwd.hash("$NEW_ADMIN_PASS"))
PYEND
)

# Update database
sudo -u postgres psql -d kitchentech_db -c "UPDATE users SET hashed_password='$HASH' WHERE email='$ADMIN_EMAIL';"

echo "✅ Admin Password Updated Successfully"
echo "Email: $ADMIN_EMAIL"
echo "New password: $NEW_ADMIN_PASS"
