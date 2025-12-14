#!/usr/bin/env python3
"""Check if admin user exists and create one if not."""

from app.database import SessionLocal
from app.models.user import User, UserRole
from app.core.security import get_password_hash

db = SessionLocal()

try:
    # Check if admin exists
    admin = db.query(User).filter(User.email == 'admin@souqmatbakh.com').first()
    
    if not admin:
        admin = db.query(User).filter(User.username == 'admin').first()
    
    if admin:
        print("✅ Admin user exists")
        print(f"   Email: {admin.email}")
        print(f"   Username: {admin.username}")
        print(f"   Role: {admin.role}")
        
        # Update password to known value
        print("\nUpdating password to: Admin@2025")
        admin.hashed_password = get_password_hash('Admin@2025')
        admin.role = UserRole.ADMIN
        admin.is_active = True
        admin.is_verified = True
        db.commit()
        print("✅ Password updated successfully!")
    else:
        print("❌ No admin user found")
        print("Creating admin user...")
        
        # Create admin user
        admin_user = User(
            email='admin@souqmatbakh.com',
            username='admin',
            hashed_password=get_password_hash('Admin@2025'),
            full_name='Admin User',
            role=UserRole.ADMIN,
            is_active=True,
            is_verified=True
        )
        
        db.add(admin_user)
        db.commit()
        db.refresh(admin_user)
        
        print("✅ Admin user created successfully!")
        print(f"   Email: admin@souqmatbakh.com")
        print(f"   Password: Admin@2025")
        print(f"   Username: admin")
        
finally:
    db.close()
