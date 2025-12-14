#!/usr/bin/env python3
"""Check actual admin credentials in production database."""

from app.database import SessionLocal
from app.models.user import User, UserRole

db = SessionLocal()

try:
    # Find all admin users
    admins = db.query(User).filter(User.role == UserRole.ADMIN).all()
    
    print("=== Admin Users in Database ===")
    print(f"Total admin users found: {len(admins)}\n")
    
    for admin in admins:
        print(f"ID: {admin.id}")
        print(f"Email: {admin.email}")
        print(f"Username: {admin.username}")
        print(f"Role: {admin.role}")
        print(f"Active: {admin.is_active}")
        print(f"Verified: {admin.is_verified}")
        print("-" * 40)
        
finally:
    db.close()
