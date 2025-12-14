from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, Enum as SQLEnum, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime, timedelta
from app.database import Base
import enum


class SubscriptionStatus(str, enum.Enum):
    """Subscription status enumeration."""
    ACTIVE = "active"
    EXPIRED = "expired"
    CANCELLED = "cancelled"
    PENDING = "pending"


class PaymentStatus(str, enum.Enum):
    """Payment status enumeration."""
    PAID = "paid"
    PENDING = "pending"
    FAILED = "failed"
    REFUNDED = "refunded"


class Subscription(Base):
    """User subscription model."""
    
    __tablename__ = "subscriptions"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    plan_id = Column(Integer, ForeignKey("plans.id", ondelete="SET NULL"), nullable=True)
    
    # Subscription details
    status = Column(SQLEnum(SubscriptionStatus), default=SubscriptionStatus.PENDING, nullable=False)
    payment_status = Column(SQLEnum(PaymentStatus), default=PaymentStatus.PENDING, nullable=False)
    
    # Dates
    start_date = Column(DateTime, nullable=True)
    end_date = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Payment info
    amount = Column(Float, nullable=False)
    payment_method = Column(String, nullable=True)  # credit_card, bank_transfer, etc.
    transaction_id = Column(String, nullable=True)
    
    # Relationships
    user = relationship("User", back_populates="subscriptions")
    plan = relationship("Plan", back_populates="subscriptions")
    
    def __repr__(self):
        return f"<Subscription(id={self.id}, user_id={self.user_id}, status={self.status})>"
    
    def is_active(self) -> bool:
        """Check if subscription is currently active."""
        if self.status != SubscriptionStatus.ACTIVE:
            return False
        if self.end_date and self.end_date < datetime.utcnow():
            return False
        return True
