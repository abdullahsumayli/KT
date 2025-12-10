from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, Text, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base


class Listing(Base):
    """Kitchen listing model for rental properties."""
    
    __tablename__ = "listings"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False, index=True)
    description = Column(Text)
    
    # Pricing
    price = Column(Float, nullable=False)
    
    # Location
    city = Column(String, nullable=False, index=True)
    
    # Status and Type
    status = Column(String, default="active", index=True)  # active, inactive, pending
    type = Column(String, index=True)  # Commercial, Home, Shared, Industrial, etc.
    material = Column(String)  # Stainless steel, Wood, Composite, etc.
    
    # Dimensions
    length_m = Column(Float)
    width_m = Column(Float)
    height_m = Column(Float)
    
    # Featured
    is_featured = Column(Boolean, default=False, index=True)
    featured_until = Column(DateTime)
    
    # Metadata
    owner_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    owner = relationship("User", back_populates="listings")
    images = relationship("ListingImage", back_populates="listing", cascade="all, delete-orphan")
    
    def __repr__(self):
        return f"<Listing(id={self.id}, title={self.title}, price=${self.price})>"
