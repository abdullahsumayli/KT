from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pathlib import Path
from app.core.config import settings
from app.database import init_db
from app.routes import auth, listings, ai, images

# Create media directory if it doesn't exist
MEDIA_DIR = Path("media")
MEDIA_DIR.mkdir(parents=True, exist_ok=True)

# Initialize FastAPI app
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="KitchenTech API - Platform for kitchen listings with AI features",
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount static files for serving uploaded images
app.mount("/media", StaticFiles(directory="media"), name="media")

# Include routers
app.include_router(auth.router)
app.include_router(listings.router)
app.include_router(ai.router)
app.include_router(images.router)


@app.on_event("startup")
async def startup_event():
    """Initialize database on startup."""
    try:
        init_db()
        print(f"✅ Database initialized successfully")
    except Exception as e:
        print(f"⚠️  Database initialization failed: {e}")
        print(f"⚠️  API will run but database operations will fail")
    
    print(f"🚀 {settings.APP_NAME} v{settings.APP_VERSION} started!")
    print(f"📚 API Documentation: http://localhost:8000/docs")


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
        "debug_mode": settings.DEBUG
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.DEBUG
    )
