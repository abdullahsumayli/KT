from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from pydantic import BaseModel
from datetime import datetime

from app.database import get_db
from app.models import Favorite, Listing, User, ListingImage
from app.routes.auth import get_current_user


router = APIRouter(prefix="/api/favorites", tags=["favorites"])


# ============================================================================
# Pydantic Schemas
# ============================================================================

class FavoriteListingResponse(BaseModel):
    id: int
    title: str
    description: str | None
    price: float
    city: str
    status: str
    type: str | None
    is_featured: bool
    created_at: datetime
    owner_name: str | None
    image_url: str | None
    
    class Config:
        from_attributes = True


class FavoriteResponse(BaseModel):
    id: int
    listing_id: int
    listing: FavoriteListingResponse
    
    class Config:
        from_attributes = True


# ============================================================================
# Favorites Routes
# ============================================================================

@router.get("/", response_model=List[FavoriteResponse])
async def get_my_favorites(
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get all favorites for the current user."""
    
    favorites = db.query(Favorite).filter(
        Favorite.user_id == current_user.id
    ).offset(skip).limit(limit).all()
    
    result = []
    for fav in favorites:
        if fav.listing:
            listing_data = FavoriteListingResponse.from_orm(fav.listing)
            listing_data.owner_name = fav.listing.owner.full_name if fav.listing.owner else None
            # Get first image
            listing_data.image_url = fav.listing.images[0].image_url if fav.listing.images else None
            
            fav_response = FavoriteResponse(
                id=fav.id,
                listing_id=fav.listing_id,
                listing=listing_data
            )
            result.append(fav_response)
    
    return result


@router.post("/{listing_id}", status_code=status.HTTP_201_CREATED)
async def add_to_favorites(
    listing_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Add a listing to favorites."""
    
    # Check if listing exists
    listing = db.query(Listing).filter(Listing.id == listing_id).first()
    if not listing:
        raise HTTPException(status_code=404, detail="Listing not found")
    
    # Check if already in favorites
    existing = db.query(Favorite).filter(
        Favorite.user_id == current_user.id,
        Favorite.listing_id == listing_id
    ).first()
    
    if existing:
        raise HTTPException(status_code=400, detail="Already in favorites")
    
    # Add to favorites
    favorite = Favorite(
        user_id=current_user.id,
        listing_id=listing_id
    )
    
    db.add(favorite)
    db.commit()
    db.refresh(favorite)
    
    return {"message": "Added to favorites", "favorite_id": favorite.id}


@router.delete("/{listing_id}")
async def remove_from_favorites(
    listing_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Remove a listing from favorites."""
    
    favorite = db.query(Favorite).filter(
        Favorite.user_id == current_user.id,
        Favorite.listing_id == listing_id
    ).first()
    
    if not favorite:
        raise HTTPException(status_code=404, detail="Not in favorites")
    
    db.delete(favorite)
    db.commit()
    
    return {"message": "Removed from favorites"}


@router.get("/check/{listing_id}")
async def check_favorite(
    listing_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Check if a listing is in favorites."""
    
    favorite = db.query(Favorite).filter(
        Favorite.user_id == current_user.id,
        Favorite.listing_id == listing_id
    ).first()
    
    return {"is_favorite": favorite is not None}
