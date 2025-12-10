from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base


class ListingImage(Base):
    """Image model for kitchen listing photos."""
    
    __tablename__ = "listing_images"
    
    id = Column(Integer, primary_key=True, index=True)
    listing_id = Column(Integer, ForeignKey("listings.id", ondelete="CASCADE"), nullable=False)
    url = Column(String, nullable=False)
    filename = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    listing = relationship("Listing", back_populates="images")
    
    def __repr__(self):
        return f"<ListingImage(id={self.id}, listing_id={self.listing_id}, filename={self.filename})>"
