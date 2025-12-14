from sqlalchemy import Column, Integer, String, DateTime, Enum as SQLEnum
from datetime import datetime
from app.database import Base
import enum


class KitchenStyle(str, enum.Enum):
    """Kitchen style enumeration."""
    MODERN = "modern"
    CLASSIC = "classic"
    WOOD = "wood"
    ALUMINUM = "aluminum"


class QuoteRequestStatus(str, enum.Enum):
    """Quote request status enumeration."""
    NEW = "new"
    CONTACTED = "contacted"
    QUOTED = "quoted"
    CONVERTED = "converted"
    LOST = "lost"


class QuoteRequest(Base):
    """Quote request model for lead generation."""
    
    __tablename__ = "quote_requests"
    
    id = Column(Integer, primary_key=True, index=True)
    style = Column(
        SQLEnum(KitchenStyle, values_callable=lambda x: [e.value for e in x]),
        nullable=False,
        index=True
    )
    city = Column(String(100), nullable=False, index=True)
    phone = Column(String(20), nullable=False, index=True)
    status = Column(
        SQLEnum(QuoteRequestStatus, values_callable=lambda x: [e.value for e in x]),
        default=QuoteRequestStatus.NEW,
        nullable=False
    )
    admin_notes = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, index=True)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def __repr__(self):
        return f"<QuoteRequest(id={self.id}, style={self.style}, city={self.city}, phone={self.phone})>"
