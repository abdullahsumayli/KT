from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.orm import Session
from typing import List
from pydantic import BaseModel
import os
import uuid
import logging
from pathlib import Path
from app.database import get_db
from app.models.listing import Listing
from app.models.listing_image import ListingImage
from app.models.user import User
from app.core.security import get_current_user

router = APIRouter(prefix="/api/v1", tags=["images"])
logger = logging.getLogger("kitchentech")

# File upload security settings
MAX_FILE_SIZE = 5 * 1024 * 1024  # 5 MB in bytes
ALLOWED_EXTENSIONS = {'.jpg', '.jpeg', '.png', '.webp'}
ALLOWED_CONTENT_TYPES = {'image/jpeg', 'image/png', 'image/webp'}

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
    Security: Max 5MB per file, only jpg/jpeg/png/webp allowed.
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
        logger.warning(f"❌ Unauthorized image upload attempt by user {current_user.id} for listing {listing_id}")
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have permission to upload images for this listing"
        )
    
    # Create listing-specific directory
    listing_dir = MEDIA_DIR / str(listing_id)
    listing_dir.mkdir(parents=True, exist_ok=True)
    
    uploaded_images = []
    
    for file in files:
        # Security Check 1: Validate content type
        if file.content_type not in ALLOWED_CONTENT_TYPES:
            logger.warning(f"❌ Invalid content type: {file.content_type} for file {file.filename}")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid file type: {file.content_type}. Only JPEG, PNG, and WebP images are allowed."
            )
        
        # Security Check 2: Validate file extension
        file_extension = Path(file.filename).suffix.lower()
        if file_extension not in ALLOWED_EXTENSIONS:
            logger.warning(f"❌ Invalid file extension: {file_extension} for file {file.filename}")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid file extension: {file_extension}. Only .jpg, .jpeg, .png, and .webp are allowed."
            )
        
        # Security Check 3: Read file content and validate size
        content = await file.read()
        if len(content) > MAX_FILE_SIZE:
            logger.warning(f"❌ File too large: {len(content)} bytes for file {file.filename}")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"File size exceeds maximum allowed size of 5 MB. Your file is {len(content) / (1024*1024):.2f} MB."
            )
        
        # Generate unique filename with validated extension
        unique_filename = f"{uuid.uuid4()}{file_extension}"
        file_path = listing_dir / unique_filename
        
        # Save file
        with open(file_path, "wb") as buffer:
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
        
        logger.info(f"✅ Image uploaded: {unique_filename} for listing {listing_id} by user {current_user.id}")
    
    db.commit()
    
    # Refresh all images to get their IDs
    for image in uploaded_images:
        db.refresh(image)
    
    logger.info(f"✅ Total {len(uploaded_images)} images uploaded for listing {listing_id}")
    
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
        logger.warning(f"❌ Unauthorized image deletion attempt by user {current_user.id} for listing {listing_id}")
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
        logger.info(f"🗑️ Image file deleted: {file_path}")
    
    # Delete from database
    db.delete(image)
    db.commit()
    
    logger.info(f"✅ Image deleted: {image.filename} (ID: {image_id}) from listing {listing_id} by user {current_user.id}")
    
    return None
