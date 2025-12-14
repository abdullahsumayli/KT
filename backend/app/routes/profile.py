from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from pydantic import BaseModel, EmailStr
from datetime import datetime

from app.database import get_db
from app.models import User, UserRole, Listing
from app.routes.auth import get_current_user


router = APIRouter(prefix="/api/profile", tags=["profile"])


# ============================================================================
# Pydantic Schemas
# ============================================================================

class ProfileResponse(BaseModel):
    id: int
    email: str
    username: str
    full_name: str | None
    phone: str | None
    role: UserRole
    company_name: str | None
    company_address: str | None
    company_description: str | None
    city: str | None
    avatar_url: str | None
    is_verified: bool
    join_date: datetime
    
    class Config:
        from_attributes = True


class ProfileUpdate(BaseModel):
    full_name: str | None = None
    phone: str | None = None
    company_name: str | None = None
    company_address: str | None = None
    company_description: str | None = None
    city: str | None = None


class MyListingResponse(BaseModel):
    id: int
    title: str
    price: float
    city: str
    status: str
    is_featured: bool
    created_at: datetime
    images_count: int = 0
    
    class Config:
        from_attributes = True


# ============================================================================
# Profile Routes
# ============================================================================

@router.get("/me", response_model=ProfileResponse)
async def get_my_profile(
    current_user: User = Depends(get_current_user)
):
    """Get current user's profile."""
    return current_user


@router.put("/me", response_model=ProfileResponse)
async def update_my_profile(
    profile_update: ProfileUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update current user's profile."""
    
    # Update fields
    update_data = profile_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(current_user, field, value)
    
    current_user.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(current_user)
    
    return current_user


@router.get("/my-listings", response_model=List[MyListingResponse])
async def get_my_listings(
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get all listings created by the current user."""
    
    listings = db.query(Listing).filter(
        Listing.owner_id == current_user.id
    ).order_by(Listing.created_at.desc()).offset(skip).limit(limit).all()
    
    result = []
    for listing in listings:
        listing_data = MyListingResponse.from_orm(listing)
        listing_data.images_count = len(listing.images) if listing.images else 0
        result.append(listing_data)
    
    return result


@router.delete("/me")
async def delete_my_account(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete current user's account."""
    
    # In production, you might want to soft delete or archive the account
    db.delete(current_user)
    db.commit()
    
    return {"message": "Account deleted successfully"}
