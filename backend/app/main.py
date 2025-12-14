from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import JSONResponse
from pathlib import Path
import logging
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from app.core.config import settings
from app.database import init_db
from app.routes import auth, listings, ai, images, admin, contact, plans, profile, favorites, settings as settings_routes, quotes

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger("kitchentech")

# Validate settings at startup
settings.validate_settings()

# Create media directory if it doesn't exist
MEDIA_DIR = Path("media")
MEDIA_DIR.mkdir(parents=True, exist_ok=True)

# Initialize rate limiter (slowapi)
limiter = Limiter(key_func=get_remote_address)

# Initialize FastAPI app
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="KitchenTech API - Platform for kitchen listings with AI features",
    docs_url="/docs" if settings.is_debug_mode() else None,  # Disable docs in production
    redoc_url="/redoc" if settings.is_debug_mode() else None
)

# Add rate limiter to app state
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# CORS middleware - now using environment-configured origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global exception handler for production (hide internal errors)
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """Handle uncaught exceptions - hide details in production."""
    if settings.is_debug_mode():
        # In dev, show full error
        raise exc
    else:
        # In production, log error but return generic message
        logger.error(f"Unhandled exception: {exc}", exc_info=True)
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={"detail": "An internal error occurred. Please contact support if the problem persists."}
        )

# Mount static files for serving uploaded images
app.mount("/media", StaticFiles(directory="media"), name="media")

# Include routers
app.include_router(auth.router)
app.include_router(listings.router)
app.include_router(ai.router)
app.include_router(images.router)
app.include_router(admin.router)
app.include_router(contact.router)
app.include_router(quotes.router)
app.include_router(plans.router)
app.include_router(profile.router)
app.include_router(favorites.router)
app.include_router(settings_routes.router)


@app.on_event("startup")
async def startup_event():
    """Initialize database on startup."""
    try:
        init_db()
        logger.info(f"✅ Database initialized successfully")
    except Exception as e:
        logger.error(f"⚠️  Database initialization failed: {e}")
        logger.warning(f"⚠️  API will run but database operations will fail")
    
    logger.info(f"🚀 {settings.APP_NAME} v{settings.APP_VERSION} started!")
    logger.info(f"🌍 Environment: {settings.APP_ENV}")
    logger.info(f"🔒 Debug mode: {settings.is_debug_mode()}")
    logger.info(f"🌐 Allowed origins: {settings.allowed_origins_list}")
    if settings.is_debug_mode():
        logger.info(f"📚 API Documentation: http://localhost:8000/docs")


@app.get("/")
async def root():
    """Root endpoint - API health check."""
    return {
        "message": "Welcome to KitchenTech API",
        "version": settings.APP_VERSION,
        "status": "operational",
        "docs": "/docs"
    }


@app.get("/health")
async def health_check():
    """Detailed health check endpoint."""
    return {
        "status": "healthy",
        "app_name": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "debug_mode": settings.is_debug_mode()
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.is_debug_mode()
    )
