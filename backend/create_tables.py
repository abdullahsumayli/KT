"""
Create Database Tables Script

This script creates all database tables defined in the models.
Run this before running init_default_data.py
"""

import sys
from pathlib import Path

# Add backend directory to path
backend_dir = Path(__file__).parent
sys.path.insert(0, str(backend_dir))

from app.database import init_db

def main():
    print("🗃️  Creating database tables...")
    try:
        init_db()
        print("✅ Database tables created successfully!")
        print("\nNext step: Run 'python init_default_data.py' to populate default data")
    except Exception as e:
        print(f"❌ Error creating tables: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
