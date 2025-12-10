from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.orm import Session
from typing import List
from pydantic import BaseModel
import os
import uuid
from pathlib import Path
from app.database import get_db
from app.models.listing import Listing
from app.models.listing_image import ListingImage
from app.models.user import User
from app.core.security import get_current_user

router = APIRouter(prefix="/api/v1", tags=["images"])

# Create media directory if it doesn't exist
MEDIA_DIR = Path("media/listings")
MEDIA_DIR.mkdir(parents=True, exist_ok=True)


# Pydantic schemas
class ImageResponse(BaseModel):
    id: int
    listing_id: int
    url: str
    filename: str
    
    class Config:
        from_attributes = True


@router.post("/listings/{listing_id}/images", response_model=List[ImageResponse])
async def upload_listing_images(
    listing_id: int,
    files: List[UploadFile] = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Upload one or more images for a listing.
    Only the listing owner can upload images.
    """
    
    # Check if listing exists
    listing = db.query(Listing).filter(Listing.id == listing_id).first()
    if not listing:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Listing not found"
        )
    
    # Check if current user owns the listing
    if listing.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have permission to upload images for this listing"
        )
    
    # Create listing-specific directory
    listing_dir = MEDIA_DIR / str(listing_id)
    listing_dir.mkdir(parents=True, exist_ok=True)
    
    uploaded_images = []
    
    for file in files:
        # Validate file type
        if not file.content_type.startswith('image/'):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"File {file.filename} is not an image"
            )
        
        # Generate unique filename
        file_extension = Path(file.filename).suffix
        unique_filename = f"{uuid.uuid4()}{file_extension}"
        file_path = listing_dir / unique_filename
        
        # Save file
        with open(file_path, "wb") as buffer:
            content = await file.read()
            buffer.write(content)
        
        # Create database record
        image_url = f"/media/listings/{listing_id}/{unique_filename}"
        listing_image = ListingImage(
            listing_id=listing_id,
            url=image_url,
            filename=unique_filename
        )
        
        db.add(listing_image)
        uploaded_images.append(listing_image)
    
    db.commit()
    
    # Refresh all images to get their IDs
    for image in uploaded_images:
        db.refresh(image)
    
    return uploaded_images


@router.get("/listings/{listing_id}/images", response_model=List[ImageResponse])
async def get_listing_images(
    listing_id: int,
    db: Session = Depends(get_db)
):
    """Get all images for a specific listing."""
    
    # Check if listing exists
    listing = db.query(Listing).filter(Listing.id == listing_id).first()
    if not listing:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Listing not found"
        )
    
    images = db.query(ListingImage).filter(ListingImage.listing_id == listing_id).all()
    return images


@router.delete("/listings/{listing_id}/images/{image_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_listing_image(
    listing_id: int,
    image_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Delete a specific image from a listing.
    Only the listing owner can delete images.
    """
    
    # Check if listing exists
    listing = db.query(Listing).filter(Listing.id == listing_id).first()
    if not listing:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Listing not found"
        )
    
    # Check if current user owns the listing
    if listing.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have permission to delete images for this listing"
        )
    
    # Get the image
    image = db.query(ListingImage).filter(
        ListingImage.id == image_id,
        ListingImage.listing_id == listing_id
    ).first()
    
    if not image:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Image not found"
        )
    
    # Delete file from disk
    file_path = Path("media") / "listings" / str(listing_id) / image.filename
    if file_path.exists():
        file_path.unlink()
    
    # Delete from database
    db.delete(image)
    db.commit()
    
    return None
