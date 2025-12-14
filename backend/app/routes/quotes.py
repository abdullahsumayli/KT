from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List, Optional
from pydantic import BaseModel, Field, validator
from datetime import datetime
import re

from app.database import get_db
from app.models import QuoteRequest, KitchenStyle, QuoteRequestStatus
from app.models.user import User, UserRole
from app.core.security import get_current_user
from slowapi import Limiter
from slowapi.util import get_remote_address


router = APIRouter(prefix="/api/v1/quotes", tags=["quotes"])

# Rate limiting
limiter = Limiter(key_func=get_remote_address)


# ============================================================================
# Admin Verification
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
# Pydantic Schemas
# ============================================================================

class QuoteRequestCreate(BaseModel):
    """Schema for creating a quote request."""
    style: KitchenStyle = Field(..., description="Kitchen style (modern, classic, wood, aluminum)")
    city: str = Field(..., min_length=2, max_length=100, description="City name")
    phone: str = Field(..., min_length=10, max_length=10, description="Phone number (10 digits, starts with 05)")
    
    @validator('phone')
    def validate_phone(cls, v):
        """Validate Saudi phone number format."""
        # Remove any spaces or special characters
        clean_phone = re.sub(r'[\s\-\(\)]', '', v)
        
        # Check if it's a valid Saudi mobile number (05xxxxxxxx)
        if not re.match(r'^05\d{8}$', clean_phone):
            raise ValueError('Phone number must be 10 digits starting with 05 (e.g., 0512345678)')
        
        return clean_phone
    
    @validator('city')
    def validate_city(cls, v):
        """Validate and normalize city name."""
        # Allowed cities
        valid_cities = ['riyadh', 'jeddah', 'dammam', 'khobar', 'other']
        city_lower = v.lower().strip()
        
        if city_lower not in valid_cities:
            # If not in predefined list, accept but mark as 'other'
            return 'other'
        
        return city_lower


class QuoteRequestResponse(BaseModel):
    """Schema for quote request response."""
    id: int
    style: KitchenStyle
    city: str
    phone: str
    status: QuoteRequestStatus
    created_at: datetime
    
    class Config:
        from_attributes = True


class QuoteRequestStats(BaseModel):
    """Statistics for quote requests."""
    total: int
    by_style: dict
    by_city: dict
    by_status: dict


class QuoteStatusUpdate(BaseModel):
    """Schema for updating quote status."""
    status: QuoteRequestStatus = Field(..., description="New status")
    admin_notes: Optional[str] = Field(None, description="Admin notes")


# ============================================================================
# Quote Request Routes
# ============================================================================

@router.post("/", response_model=QuoteRequestResponse, status_code=status.HTTP_201_CREATED)
@limiter.limit("10/minute")
async def create_quote_request(
    request: Request,
    quote: QuoteRequestCreate,
    db: Session = Depends(get_db)
):
    """
    Create a new quote request for kitchen customization.
    
    **Rate Limit**: 10 requests per minute per IP
    
    **Request Body**:
    - style: Kitchen style (modern, classic, wood, aluminum)
    - city: City name (riyadh, jeddah, dammam, khobar, other)
    - phone: Saudi phone number (10 digits, starts with 05)
    
    **Returns**: Created quote request with ID and timestamp
    """
    
    # Check for duplicate requests (same phone within 24 hours)
    from datetime import timedelta
    one_day_ago = datetime.utcnow() - timedelta(days=1)
    
    existing_request = db.query(QuoteRequest).filter(
        QuoteRequest.phone == quote.phone,
        QuoteRequest.created_at >= one_day_ago
    ).first()
    
    if existing_request:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="A quote request with this phone number already exists within the last 24 hours. Please try again later or contact us directly."
        )
    
    # Create new quote request
    db_quote = QuoteRequest(
        style=quote.style,
        city=quote.city,
        phone=quote.phone,
        status=QuoteRequestStatus.NEW
    )
    
    db.add(db_quote)
    db.commit()
    db.refresh(db_quote)
    
    # TODO: Send notification to admin/factories
    # TODO: Send confirmation SMS to customer
    
    return db_quote


@router.get("/", response_model=List[QuoteRequestResponse])
async def get_quote_requests(
    skip: int = 0,
    limit: int = 100,
    status_filter: Optional[QuoteRequestStatus] = None,
    city_filter: Optional[str] = None,
    style_filter: Optional[KitchenStyle] = None,
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """
    Get all quote requests with optional filters.
    
    **Query Parameters**:
    - skip: Number of records to skip (default: 0)
    - limit: Maximum number of records to return (default: 100)
    - status_filter: Filter by status (new, contacted, quoted, converted, lost)
    - city_filter: Filter by city name
    - style_filter: Filter by kitchen style
    
    **Authentication**: Requires admin token
    """
    
    query = db.query(QuoteRequest)
    
    # Apply filters
    if status_filter:
        query = query.filter(QuoteRequest.status == status_filter)
    
    if city_filter:
        query = query.filter(QuoteRequest.city == city_filter.lower())
    
    if style_filter:
        query = query.filter(QuoteRequest.style == style_filter)
    
    # Order by most recent first
    quotes = query.order_by(
        QuoteRequest.created_at.desc()
    ).offset(skip).limit(limit).all()
    
    return quotes


@router.get("/stats", response_model=QuoteRequestStats)
async def get_quote_stats(
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """
    Get statistics about quote requests.
    
    **Returns**:
    - total: Total number of quote requests
    - by_style: Count grouped by kitchen style
    - by_city: Count grouped by city
    - by_status: Count grouped by status
    
    **Authentication**: Requires admin token
    """
    
    # Total count
    total = db.query(QuoteRequest).count()
    
    # Group by style
    style_counts = db.query(
        QuoteRequest.style,
        func.count(QuoteRequest.id).label('count')
    ).group_by(QuoteRequest.style).all()
    
    by_style = {str(style): count for style, count in style_counts}
    
    # Group by city
    city_counts = db.query(
        QuoteRequest.city,
        func.count(QuoteRequest.id).label('count')
    ).group_by(QuoteRequest.city).all()
    
    by_city = {city: count for city, count in city_counts}
    
    # Group by status
    status_counts = db.query(
        QuoteRequest.status,
        func.count(QuoteRequest.id).label('count')
    ).group_by(QuoteRequest.status).all()
    
    by_status = {str(status): count for status, count in status_counts}
    
    return QuoteRequestStats(
        total=total,
        by_style=by_style,
        by_city=by_city,
        by_status=by_status
    )


@router.get("/{quote_id}", response_model=QuoteRequestResponse)
async def get_quote_request(
    quote_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """
    Get a specific quote request by ID.
    
    **Path Parameters**:
    - quote_id: The ID of the quote request
    
    **Authentication**: Requires admin token
    """
    
    quote = db.query(QuoteRequest).filter(QuoteRequest.id == quote_id).first()
    
    if not quote:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Quote request with id {quote_id} not found"
        )
    
    return quote


@router.patch("/{quote_id}/status", response_model=QuoteRequestResponse)
async def update_quote_status(
    quote_id: int,
    update_data: QuoteStatusUpdate,
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """
    Update the status of a quote request.
    
    **Path Parameters**:
    - quote_id: The ID of the quote request
    
    **Request Body**:
    - status: New status (new, contacted, quoted, converted, lost)
    - admin_notes: Optional notes from admin
    
    **Authentication**: Requires admin token
    """
    
    quote = db.query(QuoteRequest).filter(QuoteRequest.id == quote_id).first()
    
    if not quote:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Quote request with id {quote_id} not found"
        )
    
    # Update status
    quote.status = update_data.status
    
    # Update admin notes if provided
    if update_data.admin_notes is not None:
        quote.admin_notes = update_data.admin_notes
    
    quote.updated_at = datetime.utcnow()
    
    db.commit()
    db.refresh(quote)
    
    return quote


@router.delete("/{quote_id}")
async def delete_quote_request(
    quote_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """
    Delete a quote request.
    
    **Path Parameters**:
    - quote_id: The ID of the quote request to delete
    
    **Authentication**: Requires admin token
    """
    
    quote = db.query(QuoteRequest).filter(QuoteRequest.id == quote_id).first()
    
    if not quote:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Quote request with id {quote_id} not found"
        )
    
    db.delete(quote)
    db.commit()
    
    return {"message": "Quote request deleted successfully", "quote_id": quote_id}
