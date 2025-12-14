from pydantic_settings import BaseSettings
from pydantic import Field
from typing import Optional, List
import os
import sys


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""
    
    # Application
    APP_NAME: str = "KitchenTech API"
    APP_VERSION: str = "1.0.0"
    APP_ENV: str = "dev"  # dev or prod
    
    # Database - MUST be set via environment variable KT_DATABASE_URL
    DATABASE_URL: str = Field(validation_alias="KT_DATABASE_URL")
    
    # Security - MUST be set via environment variable KT_SECRET_KEY
    SECRET_KEY: str = Field(validation_alias="KT_SECRET_KEY")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # CORS - comma-separated list of allowed origins
    ALLOWED_ORIGINS: str = "http://localhost:3000,http://localhost:8080"
    
    # AI
    OPENAI_API_KEY: Optional[str] = None
    
    class Config:
        env_file = ".env"
        case_sensitive = True
    
    @property
    def DEBUG(self) -> bool:
        """Debug mode is only enabled in dev environment."""
        return self.APP_ENV.lower() == "dev"
    
    @property
    def allowed_origins_list(self) -> List[str]:
        """Parse ALLOWED_ORIGINS into a list."""
        return [origin.strip() for origin in self.ALLOWED_ORIGINS.split(",")]
    
    def validate_settings(self):
        """Validate critical settings at startup."""
        errors = []
        
        if not self.SECRET_KEY or self.SECRET_KEY == "your-secret-key-change-in-production":
            errors.append("❌ KT_SECRET_KEY is not set or using default value. Generate a secure key with: openssl rand -hex 32")
        
        if len(self.SECRET_KEY) < 32:
            errors.append("❌ KT_SECRET_KEY must be at least 32 characters long")
        
        if not self.DATABASE_URL:
            errors.append("❌ KT_DATABASE_URL is not set")
        
        if self.APP_ENV.lower() == "prod":
            if "sqlite" in self.DATABASE_URL.lower():
                errors.append("❌ SQLite is not allowed in production. Use PostgreSQL.")
                # This is now a hard error, not just a warning
            
            if "*" in self.ALLOWED_ORIGINS:
                errors.append("❌ ALLOWED_ORIGINS cannot contain '*' in production")
        
        if errors:
            print("\n" + "="*60)
            print("🔒 SECURITY CONFIGURATION ERRORS")
            print("="*60)
            for error in errors:
                print(error)
            print("="*60 + "\n")
            
            # Exit if critical errors in production
            if self.APP_ENV.lower() == "prod":
                sys.exit(1)


settings = Settings()
