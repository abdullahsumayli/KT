"""create quote_requests table

Revision ID: add_quote_requests
Revises: 
Create Date: 2025-12-14

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'add_quote_requests'
down_revision = None  # Update this to your latest migration
branch_labels = None
depends_on = None


def upgrade():
    # Create kitchen_style enum
    kitchen_style_enum = sa.Enum('modern', 'classic', 'wood', 'aluminum', name='kitchenstyle')
    kitchen_style_enum.create(op.get_bind(), checkfirst=True)
    
    # Create quote_request_status enum
    quote_status_enum = sa.Enum('new', 'contacted', 'quoted', 'converted', 'lost', name='quoterequeststatus')
    quote_status_enum.create(op.get_bind(), checkfirst=True)
    
    # Create quote_requests table
    op.create_table(
        'quote_requests',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('style', kitchen_style_enum, nullable=False),
        sa.Column('city', sa.String(length=100), nullable=False),
        sa.Column('phone', sa.String(length=20), nullable=False),
        sa.Column('status', quote_status_enum, nullable=False, server_default='new'),
        sa.Column('admin_notes', sa.String(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    
    # Create indexes
    op.create_index(op.f('ix_quote_requests_id'), 'quote_requests', ['id'], unique=False)
    op.create_index(op.f('ix_quote_requests_style'), 'quote_requests', ['style'], unique=False)
    op.create_index(op.f('ix_quote_requests_city'), 'quote_requests', ['city'], unique=False)
    op.create_index(op.f('ix_quote_requests_phone'), 'quote_requests', ['phone'], unique=False)
    op.create_index(op.f('ix_quote_requests_created_at'), 'quote_requests', ['created_at'], unique=False)


def downgrade():
    # Drop indexes
    op.drop_index(op.f('ix_quote_requests_created_at'), table_name='quote_requests')
    op.drop_index(op.f('ix_quote_requests_phone'), table_name='quote_requests')
    op.drop_index(op.f('ix_quote_requests_city'), table_name='quote_requests')
    op.drop_index(op.f('ix_quote_requests_style'), table_name='quote_requests')
    op.drop_index(op.f('ix_quote_requests_id'), table_name='quote_requests')
    
    # Drop table
    op.drop_table('quote_requests')
    
    # Drop enums
    sa.Enum(name='quoterequeststatus').drop(op.get_bind(), checkfirst=True)
    sa.Enum(name='kitchenstyle').drop(op.get_bind(), checkfirst=True)
