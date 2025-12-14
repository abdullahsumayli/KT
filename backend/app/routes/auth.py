from fastapi import APIRouter, Depends, HTTPException, status, Request
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from pydantic import BaseModel, EmailStr, validator
from datetime import timedelta
import logging
import re
from slowapi import Limiter
from slowapi.util import get_remote_address
from app.database import get_db
from app.models.user import User
from app.core.security import (
    verify_password,
    get_password_hash,
    create_access_token,
    get_current_user
)
from app.core.config import settings

router = APIRouter(prefix="/api/v1/auth", tags=["authentication"])
logger = logging.getLogger("kitchentech")

# Initialize slowapi limiter for secondary rate limiting
limiter = Limiter(key_func=get_remote_address)

# Simple in-memory rate limiter for login attempts
from collections import defaultdict
from datetime import datetime as dt
from threading import Lock

class SimpleRateLimiter:
    """Simple in-memory rate limiter for login attempts."""
    def __init__(self, max_attempts: int = 5, window_seconds: int = 60):
        self.max_attempts = max_attempts
        self.window_seconds = window_seconds
        self.attempts = defaultdict(list)
        self.lock = Lock()
    
    def is_allowed(self, key: str) -> bool:
        """Check if request is allowed based on rate limit."""
        with self.lock:
            now = dt.now()
            # Clean old attempts
            self.attempts[key] = [
                timestamp for timestamp in self.attempts[key]
                if (now - timestamp).total_seconds() < self.window_seconds
            ]
            
            if len(self.attempts[key]) >= self.max_attempts:
                return False
            
            self.attempts[key].append(now)
            return True

# Global rate limiter instance
login_limiter = SimpleRateLimiter(max_attempts=5, window_seconds=60)


# Pydantic schemas
class UserRegister(BaseModel):
    email: EmailStr
    username: str
    password: str
    full_name: str = None
    phone: str = None
    
    @validator('password')
    def validate_password(cls, v):
        """
        Enforce password policy:
        - Minimum 8 characters
        - At least one uppercase letter
        - At least one digit
        """
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters long')
        
        if not re.search(r'[A-Z]', v):
            raise ValueError('Password must contain at least one uppercase letter')
        
        if not re.search(r'\d', v):
            raise ValueError('Password must contain at least one digit')
        
        return v


class UserResponse(BaseModel):
    id: int
    email: str
    username: str
    full_name: str = None
    phone: str = None
    is_active: bool
    is_verified: bool
    
    class Config:
        from_attributes = True


class Token(BaseModel):
    access_token: str
    token_type: str


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
@limiter.limit("3/minute")  # Secondary rate limit: 3 registrations per minute per IP
async def register(request: Request, user_data: UserRegister, db: Session = Depends(get_db)):
    """Register a new user account."""
    
    # Check if user already exists
    existing_user = db.query(User).filter(
        (User.email == user_data.email) | (User.username == user_data.username)
    ).first()
    
    if existing_user:
        logger.warning(f"Registration failed: Email or username already exists - {user_data.email}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email or username already registered"
        )
    
    # Create new user
    new_user = User(
        email=user_data.email,
        username=user_data.username,
        hashed_password=get_password_hash(user_data.password),
        full_name=user_data.full_name,
        phone=user_data.phone
    )
    
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    logger.info(f"✅ New user registered: {new_user.email} (ID: {new_user.id})")
    
    return new_user


class PhoneLoginRequest(BaseModel):
    phone: str
    password: str


@router.post("/login", response_model=Token)
@limiter.limit("5/minute")  # Secondary rate limit: 5 login attempts per minute per IP
async def login(
    request: Request,
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db)
):
    """Login and receive JWT access token."""
    
    # Rate limiting: Check if too many attempts from this IP
    client_ip = request.client.host
    if not login_limiter.is_allowed(client_ip):
        logger.warning(f"🚫 Rate limit exceeded for IP: {client_ip}")
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Too many login attempts. Please try again in 1 minute.",
        )
    
    # Find user by username (OAuth2 uses 'username' field)
    user = db.query(User).filter(User.email == form_data.username).first()
    
    if not user or not verify_password(form_data.password, user.hashed_password):
        logger.warning(f"❌ Failed login attempt for: {form_data.username} from IP: {client_ip}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    if not user.is_active:
        logger.warning(f"❌ Login attempt for inactive account: {user.email}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive user account"
        )
    
    # Create access token
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.email},
        expires_delta=access_token_expires
    )
    
    logger.info(f"✅ Successful login: {user.email} (ID: {user.id}) from IP: {client_ip}")
    
    return {"access_token": access_token, "token_type": "bearer"}


@router.post("/login/phone", response_model=Token)
@limiter.limit("5/minute")  # Secondary rate limit: 5 phone login attempts per minute per IP
async def login_with_phone(
    request: Request,
    credentials: PhoneLoginRequest,
    db: Session = Depends(get_db)
):
    """Login using phone number and receive JWT access token."""
    
    # Rate limiting: Check if too many attempts from this IP
    client_ip = request.client.host
    if not login_limiter.is_allowed(f"{client_ip}_phone"):
        logger.warning(f"🚫 Rate limit exceeded for phone login from IP: {client_ip}")
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Too many login attempts. Please try again in 1 minute.",
        )
    
    # Find user by phone
    user = db.query(User).filter(User.phone == credentials.phone).first()
    
    if not user or not verify_password(credentials.password, user.hashed_password):
        logger.warning(f"❌ Failed phone login attempt for: {credentials.phone} from IP: {client_ip}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect phone or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    if not user.is_active:
        logger.warning(f"❌ Phone login attempt for inactive account: {user.email}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive user account"
        )
    
    # Create access token
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.email},
        expires_delta=access_token_expires
    )
    
    logger.info(f"✅ Successful phone login: {user.email} (ID: {user.id}) from IP: {client_ip}")
    
    return {"access_token": access_token, "token_type": "bearer"}


@router.get("/me", response_model=UserResponse)
async def get_current_user_info(current_user: User = Depends(get_current_user)):
    """Get current authenticated user information."""
    return current_user


@router.put("/me", response_model=UserResponse)
async def update_user_profile(
    full_name: str = None,
    phone: str = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update current user's profile information."""
    
    if full_name is not None:
        current_user.full_name = full_name
    if phone is not None:
        current_user.phone = phone
    
    db.commit()
    db.refresh(current_user)
    
    return current_user
