"""Initial migration - create all tables

Revision ID: a1b2c3d4e5f6
Revises: 
Create Date: 2025-12-12 06:40:04.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'a1b2c3d4e5f6'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Create users table
    op.create_table('users',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('email', sa.String(), nullable=False),
    sa.Column('username', sa.String(), nullable=False),
    sa.Column('hashed_password', sa.String(), nullable=False),
    sa.Column('full_name', sa.String(), nullable=True),
    sa.Column('phone', sa.String(), nullable=True),
    sa.Column('role', sa.Enum('CLIENT', 'ADVERTISER', 'ADMIN', name='userrole'), nullable=False),
    sa.Column('status', sa.Enum('ACTIVE', 'SUSPENDED', 'BANNED', name='userstatus'), nullable=False),
    sa.Column('company_name', sa.String(), nullable=True),
    sa.Column('company_address', sa.String(), nullable=True),
    sa.Column('company_description', sa.String(), nullable=True),
    sa.Column('city', sa.String(), nullable=True),
    sa.Column('avatar_url', sa.String(), nullable=True),
    sa.Column('is_active', sa.Boolean(), nullable=True),
    sa.Column('is_verified', sa.Boolean(), nullable=True),
    sa.Column('created_at', sa.DateTime(), nullable=True),
    sa.Column('updated_at', sa.DateTime(), nullable=True),
    sa.Column('join_date', sa.DateTime(), nullable=True),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_users_email'), 'users', ['email'], unique=True)
    op.create_index(op.f('ix_users_id'), 'users', ['id'], unique=False)
    op.create_index(op.f('ix_users_username'), 'users', ['username'], unique=True)

    # Create plans table
    op.create_table('plans',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('name', sa.String(), nullable=False),
    sa.Column('name_en', sa.String(), nullable=False),
    sa.Column('type', sa.Enum('BASIC', 'STANDARD', 'PREMIUM', name='plantype'), nullable=False),
    sa.Column('price', sa.Float(), nullable=False),
    sa.Column('duration_days', sa.Integer(), nullable=False),
    sa.Column('max_ads', sa.Integer(), nullable=False),
    sa.Column('featured_ads', sa.Integer(), nullable=False),
    sa.Column('priority_support', sa.Boolean(), nullable=True),
    sa.Column('is_active', sa.Boolean(), nullable=True),
    sa.Column('created_at', sa.DateTime(), nullable=True),
    sa.Column('updated_at', sa.DateTime(), nullable=True),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_plans_id'), 'plans', ['id'], unique=False)
    op.create_index(op.f('ix_plans_type'), 'plans', ['type'], unique=False)

    # Create site_settings table
    op.create_table('site_settings',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('key', sa.String(), nullable=False),
    sa.Column('value', sa.Text(), nullable=True),
    sa.Column('description', sa.String(), nullable=True),
    sa.Column('is_public', sa.Boolean(), nullable=True),
    sa.Column('created_at', sa.DateTime(), nullable=True),
    sa.Column('updated_at', sa.DateTime(), nullable=True),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_site_settings_id'), 'site_settings', ['id'], unique=False)
    op.create_index(op.f('ix_site_settings_key'), 'site_settings', ['key'], unique=True)

    # Create contact_messages table
    op.create_table('contact_messages',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('name', sa.String(), nullable=False),
    sa.Column('email', sa.String(), nullable=False),
    sa.Column('phone', sa.String(), nullable=True),
    sa.Column('subject', sa.String(), nullable=True),
    sa.Column('message', sa.Text(), nullable=False),
    sa.Column('type', sa.Enum('GENERAL', 'SUPPORT', 'BUSINESS', 'FEEDBACK', name='contactmessagetype'), nullable=False),
    sa.Column('status', sa.Enum('NEW', 'READ', 'REPLIED', 'CLOSED', name='contactmessagestatus'), nullable=False),
    sa.Column('admin_notes', sa.Text(), nullable=True),
    sa.Column('created_at', sa.DateTime(), nullable=True),
    sa.Column('updated_at', sa.DateTime(), nullable=True),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_contact_messages_id'), 'contact_messages', ['id'], unique=False)

    # Create listings table
    op.create_table('listings',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('title', sa.String(), nullable=False),
    sa.Column('description', sa.Text(), nullable=True),
    sa.Column('price', sa.Float(), nullable=False),
    sa.Column('city', sa.String(), nullable=False),
    sa.Column('status', sa.Enum('PENDING', 'APPROVED', 'REJECTED', 'INACTIVE', name='listingstatus'), nullable=False),
    sa.Column('type', sa.String(), nullable=True),
    sa.Column('material', sa.String(), nullable=True),
    sa.Column('rejection_reason', sa.Text(), nullable=True),
    sa.Column('reviewed_at', sa.DateTime(), nullable=True),
    sa.Column('length_m', sa.Float(), nullable=True),
    sa.Column('width_m', sa.Float(), nullable=True),
    sa.Column('height_m', sa.Float(), nullable=True),
    sa.Column('is_featured', sa.Boolean(), nullable=True),
    sa.Column('featured_until', sa.DateTime(), nullable=True),
    sa.Column('owner_id', sa.Integer(), nullable=False),
    sa.Column('created_at', sa.DateTime(), nullable=True),
    sa.Column('updated_at', sa.DateTime(), nullable=True),
    sa.ForeignKeyConstraint(['owner_id'], ['users.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_listings_city'), 'listings', ['city'], unique=False)
    op.create_index(op.f('ix_listings_id'), 'listings', ['id'], unique=False)
    op.create_index(op.f('ix_listings_is_featured'), 'listings', ['is_featured'], unique=False)
    op.create_index(op.f('ix_listings_status'), 'listings', ['status'], unique=False)
    op.create_index(op.f('ix_listings_title'), 'listings', ['title'], unique=False)
    op.create_index(op.f('ix_listings_type'), 'listings', ['type'], unique=False)

    # Create subscriptions table
    op.create_table('subscriptions',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('user_id', sa.Integer(), nullable=False),
    sa.Column('plan_id', sa.Integer(), nullable=False),
    sa.Column('amount', sa.Float(), nullable=False),
    sa.Column('status', sa.Enum('ACTIVE', 'EXPIRED', 'CANCELLED', name='subscriptionstatus'), nullable=False),
    sa.Column('payment_status', sa.Enum('PENDING', 'COMPLETED', 'FAILED', 'REFUNDED', name='paymentstatus'), nullable=False),
    sa.Column('start_date', sa.DateTime(), nullable=False),
    sa.Column('end_date', sa.DateTime(), nullable=False),
    sa.Column('created_at', sa.DateTime(), nullable=True),
    sa.Column('updated_at', sa.DateTime(), nullable=True),
    sa.ForeignKeyConstraint(['plan_id'], ['plans.id'], ),
    sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_subscriptions_id'), 'subscriptions', ['id'], unique=False)

    # Create favorites table
    op.create_table('favorites',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('user_id', sa.Integer(), nullable=False),
    sa.Column('listing_id', sa.Integer(), nullable=False),
    sa.Column('created_at', sa.DateTime(), nullable=True),
    sa.ForeignKeyConstraint(['listing_id'], ['listings.id'], ),
    sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_favorites_id'), 'favorites', ['id'], unique=False)

    # Create listing_images table
    op.create_table('listing_images',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('listing_id', sa.Integer(), nullable=False),
    sa.Column('url', sa.String(), nullable=False),
    sa.Column('filename', sa.String(), nullable=False),
    sa.Column('created_at', sa.DateTime(), nullable=True),
    sa.ForeignKeyConstraint(['listing_id'], ['listings.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_listing_images_id'), 'listing_images', ['id'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_listing_images_id'), table_name='listing_images')
    op.drop_table('listing_images')
    op.drop_index(op.f('ix_favorites_id'), table_name='favorites')
    op.drop_table('favorites')
    op.drop_index(op.f('ix_subscriptions_id'), table_name='subscriptions')
    op.drop_table('subscriptions')
    op.drop_index(op.f('ix_listings_type'), table_name='listings')
    op.drop_index(op.f('ix_listings_title'), table_name='listings')
    op.drop_index(op.f('ix_listings_status'), table_name='listings')
    op.drop_index(op.f('ix_listings_is_featured'), table_name='listings')
    op.drop_index(op.f('ix_listings_id'), table_name='listings')
    op.drop_index(op.f('ix_listings_city'), table_name='listings')
    op.drop_table('listings')
    op.drop_index(op.f('ix_contact_messages_id'), table_name='contact_messages')
    op.drop_table('contact_messages')
    op.drop_index(op.f('ix_site_settings_key'), table_name='site_settings')
    op.drop_index(op.f('ix_site_settings_id'), table_name='site_settings')
    op.drop_table('site_settings')
    op.drop_index(op.f('ix_plans_type'), table_name='plans')
    op.drop_index(op.f('ix_plans_id'), table_name='plans')
    op.drop_table('plans')
    op.drop_index(op.f('ix_users_username'), table_name='users')
    op.drop_index(op.f('ix_users_id'), table_name='users')
    op.drop_index(op.f('ix_users_email'), table_name='users')
    op.drop_table('users')
