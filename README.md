# KitchenTech

Platform for renting commercial kitchens.

## Project Structure

```
KT/
├── backend/          # FastAPI backend
├── frontend/         # Flutter mobile app
├── deploy/          # Production deployment assets (Hetzner)
└── docs/            # Documentation and wireframes
```

## 🚀 Production Deployment

**Production Site**: https://souqmatbakh.com  
**Server**: Hetzner Ubuntu (91.99.106.230)  
**Stack**: Nginx + Gunicorn + Uvicorn + PostgreSQL + SSL

### Quick Links

- **[Deployment Guide](deploy/README.md)** - Complete deployment documentation
- **[First-Time Setup](deploy/scripts/first_time_server_setup.md)** - Initial server configuration
- **[Deploy Script](deploy/scripts/deploy_backend.sh)** - Automated deployment

### Deployment Assets

```
deploy/
├── README.md                          # Deployment overview
├── backend.env.prod.example           # Production environment template
├── systemd/
│   └── souqmatbakh-backend.service   # Systemd service
├── nginx/
│   └── souqmatbakh.com.conf          # Nginx configuration
└── scripts/
    ├── deploy_backend.sh             # Deployment automation
    └── first_time_server_setup.md    # Setup guide
```

### Quick Deploy

```bash
# SSH into server
ssh root@91.99.106.230

# Deploy updates
cd /var/www/souqmatbakh/backend
sudo -u www-data ./deploy/scripts/deploy_backend.sh
```

---

## Backend (FastAPI)

### Prerequisites

- Python 3.10+
- PostgreSQL 13+

### Setup

1. Create virtual environment:

```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:

```bash
pip install -r requirements.txt
```

3. Configure environment:

```bash
cp .env.example .env
# Edit .env with your database credentials and API keys
```

4. Run database migrations (ensure PostgreSQL is running):

```bash
# The app will auto-create tables on first run
```

5. Start the server:

```bash
cd app
python main.py
# Or use uvicorn directly:
uvicorn main:app --reload
```

API Documentation: http://localhost:8000/docs

### API Endpoints

**Authentication:**

- POST `/api/auth/register` - Register new user
- POST `/api/auth/login` - Login (returns JWT token)
- GET `/api/auth/me` - Get current user info

**Listings:**

- GET `/api/listings` - Get all listings (with filters)
- POST `/api/listings` - Create listing (auth required)
- GET `/api/listings/{id}` - Get listing by ID
- PUT `/api/listings/{id}` - Update listing (owner only)
- DELETE `/api/listings/{id}` - Delete listing (owner only)
- GET `/api/listings/my-listings` - Get user's listings

**AI:**

- POST `/api/ai/generate-description` - Generate listing description
- POST `/api/ai/suggest-price` - Get price suggestions
- POST `/api/ai/enhance-listing/{id}` - Enhance existing listing

## Frontend (Flutter)

### Prerequisites

- Flutter SDK 3.0+
- Dart SDK 3.0+

### Setup

1. Navigate to the Flutter app:

```bash
cd frontend/kitchentech_app
```

2. Get dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

### Features

- User authentication (register/login)
- Browse available kitchens
- Create and manage listings
- AI-powered description generation
- AI-powered price suggestions

## Development Notes

### Database Schema

**Users Table:**

- id, email, username, hashed_password
- full_name, phone, is_active, is_verified
- created_at, updated_at

**Listings Table:**

- id, title, description, address, city, state, zip_code
- price_per_hour, price_per_day
- kitchen_type, square_footage, equipment
- is_available, available_from, available_to
- owner_id (FK to users), created_at, updated_at
- ai_generated_description, ai_suggested_price

### Security

- JWT-based authentication
- Passwords hashed with bcrypt
- Token stored securely in Flutter secure storage

### AI Integration

Currently using template-based generation. To enable full AI features:

1. Add OpenAI API key to `.env`
2. Update AI functions in `backend/app/routes/ai.py`

## License

Proprietary
