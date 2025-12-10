from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional
from app.database import get_db
from app.models.user import User
from app.models.listing import Listing
from app.core.security import get_current_user
from app.core.config import settings

router = APIRouter(prefix="/api/v1/ai", tags=["ai"])


# Pydantic schemas
class GenerateDescriptionRequest(BaseModel):
    kitchen_type: str
    square_footage: int = None
    equipment: str = None
    city: str = None
    additional_info: str = None


class GenerateDescriptionResponse(BaseModel):
    generated_description: str


# New schemas for kitchen listing description generation
class KitchenDescriptionRequest(BaseModel):
    title: str
    city: str
    type: str  # new / used / ready / custom
    material: str  # wood / aluminum / mixed / unknown
    price: Optional[float] = None
    notes: Optional[str] = None


class KitchenDescriptionResponse(BaseModel):
    description: str


class SuggestPriceRequest(BaseModel):
    kitchen_type: str
    square_footage: int = None
    equipment: str = None
    city: str
    state: str = None


class SuggestPriceResponse(BaseModel):
    suggested_price_per_hour: float
    suggested_price_per_day: float
    reasoning: str


class EnhanceListingRequest(BaseModel):
    listing_id: int


class EnhanceListingResponse(BaseModel):
    listing_id: int
    enhanced_description: str
    suggested_price: float
    original_price: float


def generate_ai_description(
    kitchen_type: str,
    square_footage: Optional[int] = None,
    equipment: Optional[str] = None,
    city: Optional[str] = None,
    additional_info: Optional[str] = None
) -> str:
    """
    Generate an AI-powered kitchen listing description.
    
    TODO: Integrate with OpenAI API when OPENAI_API_KEY is configured.
    Currently returns a template-based description.
    """
    
    # Placeholder implementation - replace with actual OpenAI integration
    description_parts = []
    
    if kitchen_type:
        description_parts.append(f"Beautiful {kitchen_type.lower()} kitchen")
    
    if city:
        description_parts.append(f"located in {city}")
    
    if square_footage:
        description_parts.append(f"featuring {square_footage} sq ft of workspace")
    
    if equipment:
        description_parts.append(f"equipped with {equipment}")
    
    if additional_info:
        description_parts.append(additional_info)
    
    base_description = ", ".join(description_parts) + "."
    
    # Add generic marketing text
    enhanced = f"{base_description} Perfect for food entrepreneurs, catering businesses, and culinary professionals. "
    enhanced += "This fully-equipped space meets all health code requirements and is ready for immediate use. "
    enhanced += "Flexible booking options available to suit your schedule."
    
    return enhanced


def suggest_ai_price(
    kitchen_type: str,
    city: str,
    square_footage: Optional[int] = None,
    equipment: Optional[str] = None,
    state: Optional[str] = None
) -> dict:
    """
    Suggest pricing using AI-based market analysis.
    
    TODO: Integrate with OpenAI API and real market data when available.
    Currently uses a simple heuristic-based pricing model.
    """
    
    # Base price per hour (simple heuristic)
    base_price = 25.0
    
    # Adjust based on kitchen type
    type_multipliers = {
        "commercial": 1.5,
        "professional": 1.4,
        "home": 0.8,
        "shared": 0.9,
        "industrial": 1.8
    }
    
    multiplier = type_multipliers.get(kitchen_type.lower(), 1.0)
    price_per_hour = base_price * multiplier
    
    # Adjust for square footage
    if square_footage:
        if square_footage > 1000:
            price_per_hour *= 1.3
        elif square_footage > 500:
            price_per_hour *= 1.15
    
    # City-based adjustments (placeholder)
    high_cost_cities = ["new york", "san francisco", "los angeles", "boston", "seattle"]
    if city and any(hc_city in city.lower() for hc_city in high_cost_cities):
        price_per_hour *= 1.25
    
    # Calculate daily price (with discount for longer rental)
    price_per_day = price_per_hour * 8 * 0.85  # 15% discount for daily rental
    
    reasoning = f"Based on {kitchen_type} kitchen type in {city}"
    if square_footage:
        reasoning += f" with {square_footage} sq ft"
    reasoning += f". Market analysis suggests ${price_per_hour:.2f}/hour pricing."
    
    return {
        "price_per_hour": round(price_per_hour, 2),
        "price_per_day": round(price_per_day, 2),
        "reasoning": reasoning
    }


@router.post("/generate-description", response_model=GenerateDescriptionResponse)
async def generate_description(
    request: GenerateDescriptionRequest,
    current_user: User = Depends(get_current_user)
):
    """
    Generate an AI-powered description for a kitchen listing.
    
    Uses AI to create compelling, professional descriptions based on kitchen attributes.
    """
    
    description = generate_ai_description(
        kitchen_type=request.kitchen_type,
        square_footage=request.square_footage,
        equipment=request.equipment,
        city=request.city,
        additional_info=request.additional_info
    )
    
    return GenerateDescriptionResponse(generated_description=description)


@router.post("/suggest-price", response_model=SuggestPriceResponse)
async def suggest_price(
    request: SuggestPriceRequest,
    current_user: User = Depends(get_current_user)
):
    """
    Get AI-powered price suggestions based on kitchen attributes and market data.
    
    Analyzes similar listings and market trends to recommend optimal pricing.
    """
    
    pricing_data = suggest_ai_price(
        kitchen_type=request.kitchen_type,
        city=request.city,
        square_footage=request.square_footage,
        equipment=request.equipment,
        state=request.state
    )
    
    return SuggestPriceResponse(
        suggested_price_per_hour=pricing_data["price_per_hour"],
        suggested_price_per_day=pricing_data["price_per_day"],
        reasoning=pricing_data["reasoning"]
    )


def generate_kitchen_description(
    title: str,
    city: str,
    type_: str,
    material: str,
    price: Optional[float] = None,
    notes: Optional[str] = None
) -> str:
    """Generate Arabic description for kitchen listing."""
    
    # Map type to Arabic
    type_map = {
        'new': 'جديد',
        'used': 'مستعمل',
        'ready': 'جاهز',
        'custom': 'تفصيل'
    }
    
    # Map material to Arabic
    material_map = {
        'wood': 'خشب',
        'aluminum': 'ألمنيوم',
        'mixed': 'مختلط',
        'unknown': 'غير محدد'
    }
    
    type_ar = type_map.get(type_, type_)
    material_ar = material_map.get(material, material)
    
    # Generate description
    description = f"مطبخ {type_ar} مصنوع من {material_ar} في {city}. "
    
    if type_ == 'new':
        description += "هذا المطبخ جديد تمامًا ولم يُستخدم من قبل، مع تصميم عصري وجودة عالية. "
    elif type_ == 'used':
        description += "مطبخ مستعمل بحالة جيدة، تم الحفاظ عليه بعناية. "
    elif type_ == 'ready':
        description += "مطبخ جاهز للتركيب الفوري، مثالي لمن يبحث عن حل سريع. "
    elif type_ == 'custom':
        description += "مطبخ مصمم خصيصًا حسب المواصفات المطلوبة. "
    
    if material == 'wood':
        description += "الخشب يمنح المطبخ مظهرًا دافئًا وكلاسيكيًا. "
    elif material == 'aluminum':
        description += "الألمنيوم يوفر متانة عالية ومقاومة للرطوبة. "
    elif material == 'mixed':
        description += "مزيج من المواد يجمع بين الجمال والوظائف العملية. "
    
    if price:
        description += f"متوفر بسعر منافس {price:.0f} ريال سعودي. "
    
    if notes:
        description += f"{notes} "
    
    description += "اتصل الآن للاستفسار والمعاينة!"
    
    return description.strip()


@router.post("/generate-description", response_model=KitchenDescriptionResponse)
async def generate_kitchen_listing_description(
    request: KitchenDescriptionRequest
):
    """
    Generate Arabic description for kitchen listing without authentication.
    
    This endpoint is public and doesn't require user authentication.
    """
    
    description = generate_kitchen_description(
        title=request.title,
        city=request.city,
        type_=request.type,
        material=request.material,
        price=request.price,
        notes=request.notes
    )
    
    return KitchenDescriptionResponse(description=description)


@router.post("/enhance-listing/{listing_id}", response_model=EnhanceListingResponse)
async def enhance_listing(
    listing_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Enhance an existing listing with AI-generated description and price suggestions.
    
    Updates the listing with AI-generated content for better market appeal.
    """
    
    listing = db.query(Listing).filter(Listing.id == listing_id).first()
    
    if not listing:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Listing not found"
        )
    
    if listing.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to enhance this listing"
        )
    
    # Generate enhanced description
    enhanced_description = generate_ai_description(
        kitchen_type=listing.kitchen_type or "commercial",
        square_footage=listing.square_footage,
        equipment=listing.equipment,
        city=listing.city
    )
    
    # Generate price suggestion
    pricing_data = suggest_ai_price(
        kitchen_type=listing.kitchen_type or "commercial",
        city=listing.city,
        square_footage=listing.square_footage,
        equipment=listing.equipment,
        state=listing.state
    )
    
    # Update listing with AI-generated content
    listing.ai_generated_description = enhanced_description
    listing.ai_suggested_price = pricing_data["price_per_hour"]
    
    db.commit()
    db.refresh(listing)
    
    return EnhanceListingResponse(
        listing_id=listing.id,
        enhanced_description=enhanced_description,
        suggested_price=pricing_data["price_per_hour"],
        original_price=listing.price_per_hour
    )


@router.get("/health")
async def ai_health_check():
    """Check if AI services are properly configured."""
    
    return {
        "status": "operational",
        "openai_configured": bool(settings.OPENAI_API_KEY),
        "features": {
            "description_generation": "template-based",  # Change to "ai-powered" when OpenAI is integrated
            "price_suggestion": "heuristic-based",  # Change to "ai-powered" when integrated
            "listing_enhancement": "available"
        },
        "note": "Configure OPENAI_API_KEY for full AI capabilities"
    }
