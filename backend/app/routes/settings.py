from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel

from app.database import get_db
from app.models import SiteSetting
from app.routes.auth import get_current_user
from app.models.user import User, UserRole


router = APIRouter(prefix="/api/settings", tags=["settings"])


# ============================================================================
# Pydantic Schemas
# ============================================================================

class SettingResponse(BaseModel):
    key: str
    value: str | None
    description: str | None
    is_public: bool
    
    class Config:
        from_attributes = True


class SettingUpdate(BaseModel):
    value: str


# ============================================================================
# Settings Routes
# ============================================================================

@router.get("/public", response_model=List[SettingResponse])
async def get_public_settings(
    db: Session = Depends(get_db)
):
    """Get all public settings (accessible without authentication)."""
    settings = db.query(SiteSetting).filter(SiteSetting.is_public == True).all()
    return settings


@router.get("/", response_model=List[SettingResponse])
async def get_all_settings(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get all settings (admin only)."""
    if current_user.role != UserRole.ADMIN:
        raise HTTPException(status_code=403, detail="Admin access required")
    
    settings = db.query(SiteSetting).all()
    return settings


@router.get("/{key}", response_model=SettingResponse)
async def get_setting(
    key: str,
    db: Session = Depends(get_db)
):
    """Get a specific setting by key."""
    setting = db.query(SiteSetting).filter(SiteSetting.key == key).first()
    
    if not setting:
        raise HTTPException(status_code=404, detail="Setting not found")
    
    # Check if public or require admin
    if not setting.is_public:
        raise HTTPException(status_code=403, detail="This setting is not public")
    
    return setting


@router.put("/{key}", response_model=SettingResponse)
async def update_setting(
    key: str,
    setting_update: SettingUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update a setting (admin only)."""
    if current_user.role != UserRole.ADMIN:
        raise HTTPException(status_code=403, detail="Admin access required")
    
    setting = db.query(SiteSetting).filter(SiteSetting.key == key).first()
    
    if not setting:
        # Create new setting if it doesn't exist
        setting = SiteSetting(key=key, value=setting_update.value)
        db.add(setting)
    else:
        setting.value = setting_update.value
    
    db.commit()
    db.refresh(setting)
    
    return setting


@router.post("/init-defaults")
async def init_default_settings(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Initialize default settings (admin only, run once)."""
    if current_user.role != UserRole.ADMIN:
        raise HTTPException(status_code=403, detail="Admin access required")
    
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
    
    created_count = 0
    for setting_data in default_settings:
        existing = db.query(SiteSetting).filter(SiteSetting.key == setting_data["key"]).first()
        if not existing:
            setting = SiteSetting(**setting_data)
            db.add(setting)
            created_count += 1
    
    db.commit()
    
    return {"message": f"Initialized {created_count} default settings"}
