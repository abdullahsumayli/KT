from sqlalchemy import Column, Integer, String, Text, Boolean
from app.database import Base


class SiteSetting(Base):
    """Site settings model for admin configuration."""
    
    __tablename__ = "site_settings"
    
    id = Column(Integer, primary_key=True, index=True)
    key = Column(String, unique=True, nullable=False, index=True)
    value = Column(Text, nullable=True)
    description = Column(String, nullable=True)
    is_public = Column(Boolean, default=False)  # Whether setting is accessible via public API
    
    def __repr__(self):
        return f"<SiteSetting(key={self.key})>"


# Default settings keys:
# - site_name: اسم الموقع
# - site_logo_url: رابط شعار الموقع
# - primary_color: اللون الأساسي
# - secondary_color: اللون الثانوي
# - support_email: بريد الدعم
# - support_phone: رقم الدعم
# - whatsapp_number: رقم واتساب
# - terms_of_service: نص الشروط والأحكام
# - privacy_policy: نص سياسة الخصوصية
# - about_us: نبذة عنا
# - facebook_url: رابط فيسبوك
# - twitter_url: رابط تويتر
# - instagram_url: رابط إنستغرام
# - tiktok_url: رابط تيك توك
