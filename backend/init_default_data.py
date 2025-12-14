"""
Initialize default data for the application.
Run this script once after database setup.
"""
from app.database import SessionLocal
from app.models import Plan, PlanType, SiteSetting, User, UserRole
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def init_plans(db):
    """Initialize default subscription plans."""
    plans_data = [
        {
            "name": "الباقة البرونزية",
            "name_en": "Bronze Plan",
            "type": PlanType.BRONZE,
            "price": 199.0,
            "duration_days": 30,
            "max_ads": 10,
            "featured_ads": 0,
            "priority_support": False,
            "description": "باقة مناسبة للبداية - 10 إعلانات شهرياً",
            "is_active": True
        },
        {
            "name": "الباقة الفضية",
            "name_en": "Silver Plan",
            "type": PlanType.SILVER,
            "price": 499.0,
            "duration_days": 30,
            "max_ads": 30,
            "featured_ads": 2,
            "priority_support": False,
            "description": "باقة متوسطة - 30 إعلان شهرياً + 2 إعلان مميز",
            "is_active": True
        },
        {
            "name": "الباقة الذهبية",
            "name_en": "Gold Plan",
            "type": PlanType.GOLD,
            "price": 999.0,
            "duration_days": 30,
            "max_ads": None,  # Unlimited
            "featured_ads": 5,
            "priority_support": True,
            "description": "باقة شاملة - إعلانات غير محدودة + 5 إعلانات مميزة + دعم فني أولوية",
            "is_active": True
        }
    ]
    
    for plan_data in plans_data:
        existing = db.query(Plan).filter(Plan.type == plan_data["type"]).first()
        if not existing:
            plan = Plan(**plan_data)
            db.add(plan)
            print(f"✓ Created plan: {plan_data['name']}")
    
    db.commit()
    print("✅ Plans initialized")


def init_settings(db):
    """Initialize default site settings."""
    default_settings = [
        {"key": "site_name", "value": "كيتشن تك", "description": "اسم الموقع", "is_public": True},
        {"key": "site_logo_url", "value": "", "description": "رابط شعار الموقع", "is_public": True},
        {"key": "primary_color", "value": "#2196F3", "description": "اللون الأساسي", "is_public": True},
        {"key": "secondary_color", "value": "#FF9800", "description": "اللون الثانوي", "is_public": True},
        {"key": "support_email", "value": "support@kitchentech.sa", "description": "بريد الدعم", "is_public": True},
        {"key": "support_phone", "value": "+966501234567", "description": "رقم الدعم", "is_public": True},
        {"key": "whatsapp_number", "value": "+966501234567", "description": "رقم واتساب", "is_public": True},
        {"key": "facebook_url", "value": "https://facebook.com/kitchentech.sa", "description": "رابط فيسبوك", "is_public": True},
        {"key": "twitter_url", "value": "https://twitter.com/kitchentech_sa", "description": "رابط تويتر", "is_public": True},
        {"key": "instagram_url", "value": "https://instagram.com/kitchentech.sa", "description": "رابط إنستغرام", "is_public": True},
        {"key": "tiktok_url", "value": "https://tiktok.com/@kitchentech.sa", "description": "رابط تيك توك", "is_public": True},
        {"key": "terms_of_service", "value": "نص الشروط والأحكام...", "description": "الشروط والأحكام", "is_public": True},
        {"key": "privacy_policy", "value": "نص سياسة الخصوصية...", "description": "سياسة الخصوصية", "is_public": True},
    ]
    
    for setting_data in default_settings:
        existing = db.query(SiteSetting).filter(SiteSetting.key == setting_data["key"]).first()
        if not existing:
            setting = SiteSetting(**setting_data)
            db.add(setting)
            print(f"✓ Created setting: {setting_data['key']}")
    
    db.commit()
    print("✅ Settings initialized")


def create_admin_user(db):
    """Create default admin user."""
    admin_email = "admin@kitchentech.sa"
    existing = db.query(User).filter(User.email == admin_email).first()
    
    if not existing:
        hashed_password = pwd_context.hash("admin123456")  # Change this in production!
        admin = User(
            email=admin_email,
            username="admin",
            hashed_password=hashed_password,
            full_name="مدير النظام",
            role=UserRole.ADMIN,
            is_active=True,
            is_verified=True
        )
        db.add(admin)
        db.commit()
        print(f"✅ Admin user created: {admin_email} / admin123456")
        print("⚠️  IMPORTANT: Change the admin password immediately!")
    else:
        print("ℹ️  Admin user already exists")


def main():
    """Main initialization function."""
    print("🚀 Starting database initialization...")
    
    db = SessionLocal()
    try:
        init_plans(db)
        init_settings(db)
        create_admin_user(db)
        print("\n✅ Database initialization completed successfully!")
    except Exception as e:
        print(f"\n❌ Error during initialization: {e}")
        db.rollback()
    finally:
        db.close()


if __name__ == "__main__":
    main()
