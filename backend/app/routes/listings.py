from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
import logging
from app.database import get_db
from app.models.user import User
from app.models.listing import Listing
from app.core.security import get_current_user, get_current_user_optional

router = APIRouter(prefix="/api/v1/listings", tags=["listings"])
logger = logging.getLogger("kitchentech")


# Pydantic schemas
class ListingCreate(BaseModel):
    title: str
    description: Optional[str] = None
    price: float
    city: str
    type: Optional[str] = None
    material: Optional[str] = None
    length_m: Optional[float] = None
    width_m: Optional[float] = None
    height_m: Optional[float] = None


class ListingUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    price: Optional[float] = None
    city: Optional[str] = None
    status: Optional[str] = None
    type: Optional[str] = None
    material: Optional[str] = None
    length_m: Optional[float] = None
    width_m: Optional[float] = None
    height_m: Optional[float] = None
    is_featured: Optional[bool] = None
    featured_until: Optional[datetime] = None


class ListingResponse(BaseModel):
    id: int
    title: str
    description: Optional[str] = None
    price: float
    city: str
    status: str
    type: Optional[str] = None
    material: Optional[str] = None
    length_m: Optional[float] = None
    width_m: Optional[float] = None
    height_m: Optional[float] = None
    is_featured: bool
    featured_until: Optional[datetime] = None
    owner_id: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


@router.get("/", response_model=List[ListingResponse])
async def get_listings(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=100),
    city: Optional[str] = None,
    type: Optional[str] = None,
    min_price: Optional[float] = None,
    max_price: Optional[float] = None,
    is_featured: Optional[bool] = None,
    owner_id: Optional[str] = None,
    current_user: Optional[User] = Depends(get_current_user_optional),
    db: Session = Depends(get_db)
):
    """
    Get all kitchen listings with optional filtering.
    Use owner_id='me' to get only your own listings (requires authentication).
    """
    
    query = db.query(Listing).filter(Listing.status == "active")
    
    # Handle owner_id filter
    if owner_id:
        if owner_id == "me":
            if not current_user:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Authentication required to filter by 'me'"
                )
            query = query.filter(Listing.owner_id == current_user.id)
        elif owner_id.isdigit():
            query = query.filter(Listing.owner_id == int(owner_id))
    
    if city:
        query = query.filter(Listing.city.ilike(f"%{city}%"))
    
    if type:
        query = query.filter(Listing.type.ilike(f"%{type}%"))
    
    if min_price is not None:
        query = query.filter(Listing.price >= min_price)
    
    if max_price is not None:
        query = query.filter(Listing.price <= max_price)
    
    if is_featured is not None:
        query = query.filter(Listing.is_featured == is_featured)
    
    listings = query.offset(skip).limit(limit).all()
    
    return listings


@router.get("/{listing_id}", response_model=ListingResponse)
async def get_listing(listing_id: int, db: Session = Depends(get_db)):
    """Get a specific listing by ID."""
    
    listing = db.query(Listing).filter(
        Listing.id == listing_id,
        Listing.status == "active"
    ).first()
    
    if not listing:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Listing not found"
        )
    
    return listing


@router.post("/", response_model=ListingResponse, status_code=status.HTTP_201_CREATED)
async def create_listing(
    listing_data: ListingCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a new kitchen listing for the current user."""
    
    new_listing = Listing(
        **listing_data.model_dump(),
        owner_id=current_user.id,
        status="active"
    )
    
    db.add(new_listing)
    db.commit()
    db.refresh(new_listing)
    
    logger.info(f"✅ New listing created: ID {new_listing.id} - '{new_listing.title}' by user {current_user.id}")
    
    return new_listing


@router.put("/{listing_id}", response_model=ListingResponse)
async def update_listing(
    listing_id: int,
    listing_data: ListingUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update a kitchen listing (owner only)."""
    
    listing = db.query(Listing).filter(Listing.id == listing_id).first()
    
    if not listing:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Listing not found"
        )
    
    if listing.owner_id != current_user.id:
        logger.warning(f"❌ Unauthorized listing update attempt by user {current_user.id} for listing {listing_id}")
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to update this listing"
        )
    
    # Update fields
    update_data = listing_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(listing, field, value)
    
    listing.updated_at = datetime.utcnow()
    
    db.commit()
    db.refresh(listing)
    
    logger.info(f"✅ Listing updated: ID {listing_id} by user {current_user.id}")
    
    return listing


@router.delete("/{listing_id}", status_code=status.HTTP_200_OK)
async def delete_listing(
    listing_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Soft delete a listing by marking it as inactive (owner only)."""
    
    listing = db.query(Listing).filter(Listing.id == listing_id).first()
    
    if not listing:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Listing not found"
        )
    
    if listing.owner_id != current_user.id:
        logger.warning(f"❌ Unauthorized listing deletion attempt by user {current_user.id} for listing {listing_id}")
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to delete this listing"
        )
    
    # Soft delete - mark as inactive
    listing.status = "inactive"
    listing.updated_at = datetime.utcnow()
    
    db.commit()
    
    logger.info(f"🗑️ Listing soft-deleted: ID {listing_id} by user {current_user.id}")
    
    return {"message": "Listing marked as inactive", "listing_id": listing_id}
