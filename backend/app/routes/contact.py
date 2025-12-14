from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from pydantic import BaseModel, EmailStr
from datetime import datetime

from app.database import get_db
from app.models import ContactMessage, ContactMessageType, ContactMessageStatus


router = APIRouter(prefix="/api/contact", tags=["contact"])


# ============================================================================
# Pydantic Schemas
# ============================================================================

class ContactMessageCreate(BaseModel):
    name: str
    email: EmailStr
    message_type: ContactMessageType
    message: str


class ContactMessageResponse(BaseModel):
    id: int
    name: str
    email: str
    message_type: ContactMessageType
    message: str
    status: ContactMessageStatus
    created_at: datetime
    
    class Config:
        from_attributes = True


# ============================================================================
# Contact Routes
# ============================================================================

@router.post("/", response_model=ContactMessageResponse, status_code=status.HTTP_201_CREATED)
async def create_contact_message(
    message: ContactMessageCreate,
    db: Session = Depends(get_db)
):
    """Create a new contact message."""
    
    db_message = ContactMessage(
        name=message.name,
        email=message.email,
        message_type=message.message_type,
        message=message.message,
        status=ContactMessageStatus.NEW
    )
    
    db.add(db_message)
    db.commit()
    db.refresh(db_message)
    
    return db_message


@router.get("/", response_model=List[ContactMessageResponse])
async def get_contact_messages(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """Get all contact messages (admin only - should add auth)."""
    messages = db.query(ContactMessage).order_by(
        ContactMessage.created_at.desc()
    ).offset(skip).limit(limit).all()
    
    return messages
