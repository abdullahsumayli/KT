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
    # Create everything using raw SQL to avoid SQLAlchemy's automatic ENUM creation
    op.execute("""
        -- Create kitchen_style enum if not exists
        DO $$ BEGIN
            CREATE TYPE kitchenstyle AS ENUM ('modern', 'classic', 'wood', 'aluminum');
        EXCEPTION
            WHEN duplicate_object THEN null;
        END $$;
        
        -- Create quote_request_status enum if not exists
        DO $$ BEGIN
            CREATE TYPE quoterequeststatus AS ENUM ('new', 'contacted', 'quoted', 'converted', 'lost');
        EXCEPTION
            WHEN duplicate_object THEN null;
        END $$;
        
        -- Create quote_requests table
        CREATE TABLE IF NOT EXISTS quote_requests (
            id SERIAL PRIMARY KEY,
            style kitchenstyle NOT NULL,
            city VARCHAR(100) NOT NULL,
            phone VARCHAR(20) NOT NULL,
            status quoterequeststatus NOT NULL DEFAULT 'new',
            admin_notes TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        -- Create indexes
        CREATE INDEX IF NOT EXISTS ix_quote_requests_id ON quote_requests(id);
        CREATE INDEX IF NOT EXISTS ix_quote_requests_style ON quote_requests(style);
        CREATE INDEX IF NOT EXISTS ix_quote_requests_city ON quote_requests(city);
        CREATE INDEX IF NOT EXISTS ix_quote_requests_phone ON quote_requests(phone);
        CREATE INDEX IF NOT EXISTS ix_quote_requests_created_at ON quote_requests(created_at);
    """)


def downgrade():
    # Drop using raw SQL
    op.execute("""
        DROP INDEX IF EXISTS ix_quote_requests_created_at;
        DROP INDEX IF EXISTS ix_quote_requests_phone;
        DROP INDEX IF EXISTS ix_quote_requests_city;
        DROP INDEX IF EXISTS ix_quote_requests_style;
        DROP INDEX IF EXISTS ix_quote_requests_id;
        DROP TABLE IF EXISTS quote_requests;
        DROP TYPE IF EXISTS quoterequeststatus;
        DROP TYPE IF EXISTS kitchenstyle;
    """)
