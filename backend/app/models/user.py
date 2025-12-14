from sqlalchemy import Column, Integer, String, Boolean, DateTime, Enum as SQLEnum
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base
import enum


class UserRole(str, enum.Enum):
    """User role enumeration."""
    CLIENT = "client"
    ADVERTISER = "advertiser"
    ADMIN = "admin"


class UserStatus(str, enum.Enum):
    """User status enumeration."""
    ACTIVE = "active"
    SUSPENDED = "suspended"
    BANNED = "banned"


class User(Base):
    """User model for authentication and profile management."""
    
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    username = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    full_name = Column(String)
    phone = Column(String)
    
    # User type and status
    role = Column(SQLEnum(UserRole), default=UserRole.CLIENT, nullable=False)
    status = Column(SQLEnum(UserStatus), default=UserStatus.ACTIVE, nullable=False)
    
    # Company info (for advertisers)
    company_name = Column(String, nullable=True)
    company_address = Column(String, nullable=True)
    company_description = Column(String, nullable=True)
    
    # Profile info
    city = Column(String, nullable=True)
    avatar_url = Column(String, nullable=True)
    
    # Verification
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    join_date = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    listings = relationship("Listing", back_populates="owner", cascade="all, delete-orphan")
    favorites = relationship("Favorite", back_populates="user", cascade="all, delete-orphan")
    subscriptions = relationship("Subscription", back_populates="user", cascade="all, delete-orphan")
    
    def __repr__(self):
        return f"<User(id={self.id}, email={self.email}, role={self.role})>"
