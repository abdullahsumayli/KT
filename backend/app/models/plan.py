from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, Enum as SQLEnum, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base
import enum


class PlanType(str, enum.Enum):
    """Plan type enumeration."""
    BRONZE = "bronze"
    SILVER = "silver"
    GOLD = "gold"


class Plan(Base):
    """Subscription plan model."""
    
    __tablename__ = "plans"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)  # البرونزية، الفضية، الذهبية
    name_en = Column(String, nullable=False)  # Bronze, Silver, Gold
    type = Column(SQLEnum(PlanType, values_callable=lambda x: [e.value for e in x]), nullable=False)
    price = Column(Float, nullable=False)  # Price in SAR
    duration_days = Column(Integer, default=30)  # Plan duration in days
    max_ads = Column(Integer, nullable=True)  # Null = unlimited
    featured_ads = Column(Integer, default=0)  # Number of featured ads allowed
    priority_support = Column(Boolean, default=False)
    description = Column(String, nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    subscriptions = relationship("Subscription", back_populates="plan")
    
    def __repr__(self):
        return f"<Plan(id={self.id}, name={self.name}, price={self.price})>"
