from sqlalchemy import Column, Integer, String, Text, DateTime, Enum as SQLEnum
from datetime import datetime
from app.database import Base
import enum


class ContactMessageType(str, enum.Enum):
    """Contact message type enumeration."""
    SUGGESTION = "suggestion"
    PROBLEM = "problem"
    PARTNERSHIP = "partnership"
    ADVERTISEMENT = "advertisement"


class ContactMessageStatus(str, enum.Enum):
    """Contact message status enumeration."""
    NEW = "new"
    READ = "read"
    REPLIED = "replied"
    CLOSED = "closed"


class ContactMessage(Base):
    """Contact message model."""
    
    __tablename__ = "contact_messages"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, nullable=False)
    message_type = Column(SQLEnum(ContactMessageType), nullable=False)
    message = Column(Text, nullable=False)
    status = Column(SQLEnum(ContactMessageStatus), default=ContactMessageStatus.NEW, nullable=False)
    admin_notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def __repr__(self):
        return f"<ContactMessage(id={self.id}, name={self.name}, type={self.message_type})>"
