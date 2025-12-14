from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime, timedelta

from app.database import get_db
from app.models import Plan, PlanType, Subscription, SubscriptionStatus, PaymentStatus, User
from app.routes.auth import get_current_user


router = APIRouter(prefix="/api/plans", tags=["plans"])


# ============================================================================
# Pydantic Schemas
# ============================================================================

class PlanResponse(BaseModel):
    id: int
    name: str
    name_en: str
    type: PlanType
    price: float
    duration_days: int
    max_ads: Optional[int]
    featured_ads: int
    priority_support: bool
    description: Optional[str]
    is_active: bool
    
    class Config:
        from_attributes = True


class SubscriptionCreate(BaseModel):
    plan_id: int
    payment_method: str = "credit_card"


class SubscriptionResponse(BaseModel):
    id: int
    plan_id: int
    plan_name: str
    amount: float
    status: SubscriptionStatus
    payment_status: PaymentStatus
    start_date: Optional[datetime]
    end_date: Optional[datetime]
    created_at: datetime
    
    class Config:
        from_attributes = True


# ============================================================================
# Plan Routes
# ============================================================================

@router.get("/", response_model=List[PlanResponse])
async def get_plans(
    db: Session = Depends(get_db)
):
    """Get all active subscription plans."""
    plans = db.query(Plan).filter(Plan.is_active == True).all()
    return plans


@router.get("/{plan_id}", response_model=PlanResponse)
async def get_plan(
    plan_id: int,
    db: Session = Depends(get_db)
):
    """Get a specific plan by ID."""
    plan = db.query(Plan).filter(Plan.id == plan_id).first()
    if not plan:
        raise HTTPException(status_code=404, detail="Plan not found")
    return plan


# ============================================================================
# Subscription Routes
# ============================================================================

@router.post("/subscribe", response_model=SubscriptionResponse, status_code=status.HTTP_201_CREATED)
async def create_subscription(
    subscription: SubscriptionCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a new subscription for the current user."""
    
    # Get the plan
    plan = db.query(Plan).filter(Plan.id == subscription.plan_id).first()
    if not plan:
        raise HTTPException(status_code=404, detail="Plan not found")
    
    # Check if user already has an active subscription
    existing_sub = db.query(Subscription).filter(
        Subscription.user_id == current_user.id,
        Subscription.status == SubscriptionStatus.ACTIVE
    ).first()
    
    if existing_sub:
        raise HTTPException(
            status_code=400,
            detail="You already have an active subscription"
        )
    
    # Create subscription
    start_date = datetime.utcnow()
    end_date = start_date + timedelta(days=plan.duration_days)
    
    db_subscription = Subscription(
        user_id=current_user.id,
        plan_id=plan.id,
        amount=plan.price,
        status=SubscriptionStatus.PENDING,
        payment_status=PaymentStatus.PENDING,
        payment_method=subscription.payment_method,
        start_date=start_date,
        end_date=end_date
    )
    
    db.add(db_subscription)
    db.commit()
    db.refresh(db_subscription)
    
    # Return response with plan name
    response = SubscriptionResponse.from_orm(db_subscription)
    response.plan_name = plan.name
    return response


@router.get("/subscriptions/my", response_model=List[SubscriptionResponse])
async def get_my_subscriptions(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get all subscriptions for the current user."""
    subscriptions = db.query(Subscription).filter(
        Subscription.user_id == current_user.id
    ).order_by(Subscription.created_at.desc()).all()
    
    result = []
    for sub in subscriptions:
        response = SubscriptionResponse.from_orm(sub)
        response.plan_name = sub.plan.name if sub.plan else "Unknown"
        result.append(response)
    
    return result


@router.get("/subscriptions/active", response_model=Optional[SubscriptionResponse])
async def get_active_subscription(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get the active subscription for the current user."""
    subscription = db.query(Subscription).filter(
        Subscription.user_id == current_user.id,
        Subscription.status == SubscriptionStatus.ACTIVE
    ).first()
    
    if not subscription:
        return None
    
    response = SubscriptionResponse.from_orm(subscription)
    response.plan_name = subscription.plan.name if subscription.plan else "Unknown"
    return response


@router.post("/subscriptions/{subscription_id}/confirm-payment")
async def confirm_payment(
    subscription_id: int,
    transaction_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Confirm payment for a subscription (mock - in production, verify with payment gateway)."""
    
    subscription = db.query(Subscription).filter(
        Subscription.id == subscription_id,
        Subscription.user_id == current_user.id
    ).first()
    
    if not subscription:
        raise HTTPException(status_code=404, detail="Subscription not found")
    
    # Update subscription status
    subscription.payment_status = PaymentStatus.PAID
    subscription.status = SubscriptionStatus.ACTIVE
    subscription.transaction_id = transaction_id
    subscription.updated_at = datetime.utcnow()
    
    db.commit()
    
    return {"message": "Payment confirmed successfully", "subscription_id": subscription_id}
