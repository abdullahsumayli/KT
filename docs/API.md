# API Documentation

## Authentication Flow

### Register

```http
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "username": "johndoe",
  "password": "securepassword",
  "full_name": "John Doe",
  "phone": "+1234567890"
}
```

### Login

```http
POST /api/auth/login
Content-Type: application/x-www-form-urlencoded

username=user@example.com
password=securepassword

Response:
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "bearer"
}
```

### Authenticated Requests

Include JWT token in Authorization header:

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

## Listing Management

### Create Listing

```http
POST /api/listings
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Commercial Kitchen Downtown",
  "description": "Fully equipped commercial kitchen",
  "address": "123 Main St",
  "city": "New York",
  "state": "NY",
  "zip_code": "10001",
  "price_per_hour": 50.00,
  "price_per_day": 350.00,
  "kitchen_type": "commercial",
  "square_footage": 1200,
  "equipment": "ovens, stoves, refrigerators, prep tables"
}
```

### Get Listings with Filters

```http
GET /api/listings?city=New York&min_price=20&max_price=100&is_available=true
```

### Update Listing

```http
PUT /api/listings/1
Authorization: Bearer <token>
Content-Type: application/json

{
  "price_per_hour": 55.00,
  "is_available": false
}
```

## AI Features

### Generate Description

```http
POST /api/ai/generate-description
Authorization: Bearer <token>
Content-Type: application/json

{
  "kitchen_type": "commercial",
  "square_footage": 1200,
  "equipment": "ovens, stoves, refrigerators",
  "city": "New York",
  "additional_info": "Recently renovated"
}

Response:
{
  "generated_description": "Beautiful commercial kitchen located in New York..."
}
```

### Suggest Price

```http
POST /api/ai/suggest-price
Authorization: Bearer <token>
Content-Type: application/json

{
  "kitchen_type": "commercial",
  "city": "New York",
  "state": "NY",
  "square_footage": 1200,
  "equipment": "fully equipped"
}

Response:
{
  "suggested_price_per_hour": 62.50,
  "suggested_price_per_day": 425.00,
  "reasoning": "Based on commercial kitchen type in New York with 1200 sq ft..."
}
```

### Enhance Listing

```http
POST /api/ai/enhance-listing/1
Authorization: Bearer <token>

Response:
{
  "listing_id": 1,
  "enhanced_description": "...",
  "suggested_price": 62.50,
  "original_price": 50.00
}
```

## Error Responses

```json
{
  "detail": "Error message here"
}
```

Common status codes:

- 200 OK
- 201 Created
- 204 No Content
- 400 Bad Request
- 401 Unauthorized
- 403 Forbidden
- 404 Not Found
- 500 Internal Server Error
