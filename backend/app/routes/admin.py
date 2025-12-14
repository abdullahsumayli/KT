from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel, EmailStr
from datetime import datetime
import logging

from app.database import get_db
from app.models import User, UserRole, UserStatus, Listing, ListingStatus, Subscription, Plan
from app.routes.auth import get_current_user


router = APIRouter(prefix="/api/admin", tags=["admin"])
logger = logging.getLogger("kitchentech")


# ============================================================================
# Pydantic Schemas
# ============================================================================

class UserResponse(BaseModel):
    id: int
    email: str
    username: str
    full_name: Optional[str]
    phone: Optional[str]
    role: UserRole
    status: UserStatus
    company_name: Optional[str]
    city: Optional[str]
    is_verified: bool
    join_date: datetime
    ads_count: int = 0
    
    class Config:
        from_attributes = True


class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    status: Optional[UserStatus] = None
    company_name: Optional[str] = None
    company_address: Optional[str] = None


class ListingResponse(BaseModel):
    id: int
    title: str
    description: Optional[str]
    price: float
    city: str
    status: ListingStatus
    is_featured: bool
    owner_id: int
    owner_name: Optional[str]
    created_at: datetime
    rejection_reason: Optional[str]
    
    class Config:
        from_attributes = True


class ListingReview(BaseModel):
    status: ListingStatus
    rejection_reason: Optional[str] = None


class DashboardStats(BaseModel):
    total_users: int
    total_clients: int
    total_advertisers: int
    total_listings: int
    active_listings: int
    pending_listings: int
    approved_listings: int
    rejected_listings: int
    total_subscriptions: int
    active_subscriptions: int
    monthly_revenue: float


# ============================================================================
# Dependency: Verify Admin
# ============================================================================

async def verify_admin(current_user: User = Depends(get_current_user)):
    """Verify that the current user is an admin."""
    if current_user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied. Admin privileges required."
        )
    return current_user


# ============================================================================
# Dashboard Statistics
# ============================================================================

@router.get("/dashboard/stats", response_model=DashboardStats)
async def get_dashboard_stats(
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """Get dashboard statistics for admin."""
    
    # User stats
    total_users = db.query(User).count()
    total_clients = db.query(User).filter(User.role == UserRole.CLIENT).count()
    total_advertisers = db.query(User).filter(User.role == UserRole.ADVERTISER).count()
    
    # Listing stats
    total_listings = db.query(Listing).count()
    active_listings = db.query(Listing).filter(Listing.status == ListingStatus.APPROVED).count()
    pending_listings = db.query(Listing).filter(Listing.status == ListingStatus.PENDING).count()
    approved_listings = active_listings
    rejected_listings = db.query(Listing).filter(Listing.status == ListingStatus.REJECTED).count()
    
    # Subscription stats
    total_subscriptions = db.query(Subscription).count()
    active_subscriptions = db.query(Subscription).filter(
        Subscription.status == "active"
    ).count()
    
    # Revenue (mock for now - calculate from subscriptions)
    from sqlalchemy import func
    monthly_revenue = db.query(func.sum(Subscription.amount)).filter(
        Subscription.payment_status == "paid",
        Subscription.created_at >= datetime.utcnow().replace(day=1)
    ).scalar() or 0.0
    
    return DashboardStats(
        total_users=total_users,
        total_clients=total_clients,
        total_advertisers=total_advertisers,
        total_listings=total_listings,
        active_listings=active_listings,
        pending_listings=pending_listings,
        approved_listings=approved_listings,
        rejected_listings=rejected_listings,
        total_subscriptions=total_subscriptions,
        active_subscriptions=active_subscriptions,
        monthly_revenue=monthly_revenue
    )


# ============================================================================
# User Management
# ============================================================================

@router.get("/users", response_model=List[UserResponse])
async def get_all_users(
    role: Optional[UserRole] = None,
    status: Optional[UserStatus] = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """Get all users with optional filters."""
    query = db.query(User)
    
    if role:
        query = query.filter(User.role == role)
    if status:
        query = query.filter(User.status == status)
    
    users = query.offset(skip).limit(limit).all()
    
    # Add ads count for each user
    result = []
    for user in users:
        user_data = UserResponse.from_orm(user)
        user_data.ads_count = db.query(Listing).filter(Listing.owner_id == user.id).count()
        result.append(user_data)
    
    return result


@router.get("/users/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """Get user by ID."""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    user_data = UserResponse.from_orm(user)
    user_data.ads_count = db.query(Listing).filter(Listing.owner_id == user.id).count()
    return user_data


@router.put("/users/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: int,
    user_update: UserUpdate,
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """Update user information."""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Update fields
    update_data = user_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(user, field, value)
    
    user.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(user)
    
    user_data = UserResponse.from_orm(user)
    user_data.ads_count = db.query(Listing).filter(Listing.owner_id == user.id).count()
    return user_data


@router.post("/users/{user_id}/ban")
async def ban_user(
    user_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """Ban a user."""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    user.status = UserStatus.BANNED
    user.is_active = False
    user.updated_at = datetime.utcnow()
    db.commit()
    
    return {"message": "User banned successfully"}


@router.post("/users/{user_id}/unban")
async def unban_user(
    user_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """Unban a user."""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    user.status = UserStatus.ACTIVE
    user.is_active = True
    user.updated_at = datetime.utcnow()
    db.commit()
    
    return {"message": "User unbanned successfully"}


@router.post("/users/{user_id}/suspend")
async def suspend_user(
    user_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """Suspend a user."""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    user.status = UserStatus.SUSPENDED
    user.updated_at = datetime.utcnow()
    db.commit()
    
    return {"message": "User suspended successfully"}


# ============================================================================
# Listing Management
# ============================================================================

@router.get("/listings", response_model=List[ListingResponse])
async def get_all_listings(
    status: Optional[ListingStatus] = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """Get all listings with optional status filter."""
    query = db.query(Listing)
    
    if status:
        query = query.filter(Listing.status == status)
    
    listings = query.offset(skip).limit(limit).all()
    
    # Add owner name
    result = []
    for listing in listings:
        listing_data = ListingResponse.from_orm(listing)
        listing_data.owner_name = listing.owner.full_name if listing.owner else None
        result.append(listing_data)
    
    return result


@router.get("/listings/{listing_id}", response_model=ListingResponse)
async def get_listing(
    listing_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """Get listing by ID."""
    listing = db.query(Listing).filter(Listing.id == listing_id).first()
    if not listing:
        raise HTTPException(status_code=404, detail="Listing not found")
    
    listing_data = ListingResponse.from_orm(listing)
    listing_data.owner_name = listing.owner.full_name if listing.owner else None
    return listing_data


@router.post("/listings/{listing_id}/review")
async def review_listing(
    listing_id: int,
    review: ListingReview,
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """Review a listing (approve or reject)."""
    listing = db.query(Listing).filter(Listing.id == listing_id).first()
    if not listing:
        raise HTTPException(status_code=404, detail="Listing not found")
    
    old_status = listing.status
    listing.status = review.status
    listing.rejection_reason = review.rejection_reason
    listing.reviewed_at = datetime.utcnow()
    listing.updated_at = datetime.utcnow()
    
    db.commit()
    db.refresh(listing)
    
    logger.info(f"🔍 Listing {listing_id} status changed from {old_status} to {review.status.value} by admin {admin.id}")
    if review.rejection_reason:
        logger.info(f"🔍 Rejection reason: {review.rejection_reason}")
    
    return {"message": f"Listing {review.status.value} successfully"}


@router.post("/listings/{listing_id}/feature")
async def toggle_featured(
    listing_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """Toggle featured status of a listing."""
    listing = db.query(Listing).filter(Listing.id == listing_id).first()
    if not listing:
        raise HTTPException(status_code=404, detail="Listing not found")
    
    listing.is_featured = not listing.is_featured
    if listing.is_featured:
        # Set featured until 30 days from now
        from datetime import timedelta
        listing.featured_until = datetime.utcnow() + timedelta(days=30)
    else:
        listing.featured_until = None
    
    listing.updated_at = datetime.utcnow()
    db.commit()
    
    return {
        "message": f"Listing {'featured' if listing.is_featured else 'unfeatured'} successfully",
        "is_featured": listing.is_featured
    }


# ============================================================================
# Plan Management
# ============================================================================

@router.get("/plans", response_model=List[dict])
async def get_all_plans(
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """Get all subscription plans."""
    plans = db.query(Plan).all()
    return [
        {
            "id": plan.id,
            "name": plan.name,
            "name_en": plan.name_en,
            "type": plan.type,
            "price": plan.price,
            "duration_days": plan.duration_days,
            "max_ads": plan.max_ads,
            "featured_ads": plan.featured_ads,
            "priority_support": plan.priority_support,
            "is_active": plan.is_active
        }
        for plan in plans
    ]


@router.put("/plans/{plan_id}")
async def update_plan_price(
    plan_id: int,
    price: float,
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """Update plan price."""
    plan = db.query(Plan).filter(Plan.id == plan_id).first()
    if not plan:
        raise HTTPException(status_code=404, detail="Plan not found")
    
    plan.price = price
    plan.updated_at = datetime.utcnow()
    db.commit()
    
    return {"message": "Plan price updated successfully", "new_price": price}


# ============================================================================
# Subscription Management
# ============================================================================

@router.get("/subscriptions", response_model=List[dict])
async def get_all_subscriptions(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """Get all subscriptions."""
    subscriptions = db.query(Subscription).offset(skip).limit(limit).all()
    
    return [
        {
            "id": sub.id,
            "user_id": sub.user_id,
            "user_name": sub.user.full_name if sub.user else None,
            "user_email": sub.user.email if sub.user else None,
            "plan_name": sub.plan.name if sub.plan else None,
            "amount": sub.amount,
            "status": sub.status,
            "payment_status": sub.payment_status,
            "start_date": sub.start_date,
            "end_date": sub.end_date,
            "created_at": sub.created_at
        }
        for sub in subscriptions
    ]
