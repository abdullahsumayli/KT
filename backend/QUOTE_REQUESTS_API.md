# Quote Requests API - Backend Documentation

## Overview

Backend API endpoints for handling kitchen quote requests from the Flutter QuoteRequestForm widget.

**Base URL**: `https://souqmatbakh.com/api/v1/quotes`

---

## Database Model

### Table: `quote_requests`

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| `id` | Integer | Primary key | Auto-increment |
| `style` | Enum | Kitchen style | modern, classic, wood, aluminum |
| `city` | String(100) | City name | Required, indexed |
| `phone` | String(20) | Phone number | Required, indexed, 10 digits |
| `status` | Enum | Request status | new, contacted, quoted, converted, lost |
| `admin_notes` | Text | Admin notes | Optional |
| `created_at` | DateTime | Creation timestamp | Auto-generated |
| `updated_at` | DateTime | Last update | Auto-updated |

---

## API Endpoints

### 1. Create Quote Request

**Endpoint**: `POST /api/v1/quotes/`

**Rate Limit**: 10 requests per minute per IP

**Request Body**:
```json
{
  "style": "modern",
  "city": "riyadh",
  "phone": "0512345678"
}
```

**Validation Rules**:
- `style`: Must be one of: `modern`, `classic`, `wood`, `aluminum`
- `city`: Normalized to lowercase, accepts: `riyadh`, `jeddah`, `dammam`, `khobar`, `other`
- `phone`: Must be exactly 10 digits starting with `05` (Saudi format)

**Response** (201 Created):
```json
{
  "id": 1,
  "style": "modern",
  "city": "riyadh",
  "phone": "0512345678",
  "status": "new",
  "created_at": "2025-12-14T10:30:00"
}
```

**Error Responses**:

- **400 Bad Request** - Invalid data format
```json
{
  "detail": [
    {
      "loc": ["body", "phone"],
      "msg": "Phone number must be 10 digits starting with 05",
      "type": "value_error"
    }
  ]
}
```

- **409 Conflict** - Duplicate request (same phone within 24 hours)
```json
{
  "detail": "A quote request with this phone number already exists within the last 24 hours. Please try again later or contact us directly."
}
```

- **429 Too Many Requests** - Rate limit exceeded
```json
{
  "error": "Rate limit exceeded: 10 per 1 minute"
}
```

---

### 2. Get All Quote Requests

**Endpoint**: `GET /api/v1/quotes/`

**Query Parameters**:
- `skip` (int, default: 0) - Number of records to skip
- `limit` (int, default: 100) - Maximum records to return
- `status_filter` (enum, optional) - Filter by status
- `city_filter` (string, optional) - Filter by city

**Example**:
```
GET /api/v1/quotes/?status_filter=new&city_filter=riyadh&limit=50
```

**Response** (200 OK):
```json
[
  {
    "id": 1,
    "style": "modern",
    "city": "riyadh",
    "phone": "0512345678",
    "status": "new",
    "created_at": "2025-12-14T10:30:00"
  },
  {
    "id": 2,
    "style": "classic",
    "city": "jeddah",
    "phone": "0598765432",
    "status": "contacted",
    "created_at": "2025-12-14T09:15:00"
  }
]
```

**Note**: This endpoint should be protected with admin authentication in production.

---

### 3. Get Quote Statistics

**Endpoint**: `GET /api/v1/quotes/stats`

**Response** (200 OK):
```json
{
  "total": 150,
  "by_style": {
    "modern": 65,
    "classic": 40,
    "wood": 30,
    "aluminum": 15
  },
  "by_city": {
    "riyadh": 70,
    "jeddah": 45,
    "dammam": 20,
    "other": 15
  },
  "by_status": {
    "new": 50,
    "contacted": 40,
    "quoted": 30,
    "converted": 20,
    "lost": 10
  }
}
```

**Note**: This endpoint should be protected with admin authentication in production.

---

### 4. Get Single Quote Request

**Endpoint**: `GET /api/v1/quotes/{quote_id}`

**Path Parameters**:
- `quote_id` (int) - The ID of the quote request

**Response** (200 OK):
```json
{
  "id": 1,
  "style": "modern",
  "city": "riyadh",
  "phone": "0512345678",
  "status": "new",
  "created_at": "2025-12-14T10:30:00"
}
```

**Error Response** (404 Not Found):
```json
{
  "detail": "Quote request with id 999 not found"
}
```

---

### 5. Update Quote Status

**Endpoint**: `PATCH /api/v1/quotes/{quote_id}/status`

**Path Parameters**:
- `quote_id` (int) - The ID of the quote request

**Request Body**:
```json
{
  "new_status": "contacted",
  "admin_notes": "Called customer, scheduled visit for tomorrow"
}
```

**Response** (200 OK):
```json
{
  "message": "Quote request status updated successfully",
  "quote": {
    "id": 1,
    "style": "modern",
    "city": "riyadh",
    "phone": "0512345678",
    "status": "contacted",
    "created_at": "2025-12-14T10:30:00"
  }
}
```

**Note**: This endpoint should be protected with admin authentication in production.

---

### 6. Delete Quote Request

**Endpoint**: `DELETE /api/v1/quotes/{quote_id}`

**Path Parameters**:
- `quote_id` (int) - The ID of the quote request to delete

**Response** (200 OK):
```json
{
  "message": "Quote request deleted successfully",
  "quote_id": 1
}
```

**Error Response** (404 Not Found):
```json
{
  "detail": "Quote request with id 999 not found"
}
```

**Note**: This endpoint should be protected with admin authentication in production.

---

## Status Workflow

```
new → contacted → quoted → converted
                    ↓
                  lost
```

**Status Descriptions**:
- `new`: Quote request just received, not yet contacted
- `contacted`: Customer has been contacted by phone/email
- `quoted`: Price quote has been provided to customer
- `converted`: Customer accepted quote and became a client
- `lost`: Customer declined quote or did not respond

---

## Rate Limiting

### Nginx Layer (Server-level)
- Global API: 20 requests/second
- Auth endpoints: 5 requests/minute

### Application Layer (FastAPI)
- Quote creation: **10 requests/minute per IP**
- Auth endpoints: 3-5 requests/minute

### Cloudflare Edge (if enabled)
- General traffic: 300 requests/minute per IP
- Auth endpoints: 10 requests/minute per IP

---

## Database Migration

Run the migration to create the `quote_requests` table:

```bash
# On production server
cd /var/www/souqmatbakh/backend
source .venv/bin/activate
alembic upgrade head
```

**Migration File**: `backend/alembic/versions/add_quote_requests.py`

---

## Flutter Integration

Update the `_submitForm()` function in `lib/widgets/quote_request_form.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> _submitForm() async {
  if (!_formKey.currentState!.validate() || _selectedStyle == null) {
    return;
  }

  setState(() => _isLoading = true);

  try {
    final response = await http.post(
      Uri.parse('https://souqmatbakh.com/api/v1/quotes/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'style': _selectedStyle,
        'city': _selectedCity,
        'phone': _phoneController.text.trim(),
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      _showSnackBar(
        '✅ تم إرسال طلبك بنجاح! رقم الطلب: ${data['id']}',
        isError: false,
      );
      _resetForm();
    } else if (response.statusCode == 409) {
      _showSnackBar(
        '⚠️ لديك طلب سابق خلال آخر 24 ساعة. سنتواصل معك قريباً',
        isError: true,
      );
    } else if (response.statusCode == 429) {
      _showSnackBar(
        '⚠️ عدد كبير من المحاولات. الرجاء الانتظار قليلاً',
        isError: true,
      );
    } else {
      throw Exception('فشل الإرسال');
    }
  } catch (e) {
    _showSnackBar(
      '❌ حدث خطأ. الرجاء المحاولة مرة أخرى',
      isError: true,
    );
  } finally {
    setState(() => _isLoading = false);
  }
}
```

**Required Dependency** (`pubspec.yaml`):
```yaml
dependencies:
  http: ^1.1.0
```

---

## Testing

### Test with cURL

**Create Quote Request**:
```bash
curl -X POST https://souqmatbakh.com/api/v1/quotes/ \
  -H "Content-Type: application/json" \
  -d '{
    "style": "modern",
    "city": "riyadh",
    "phone": "0512345678"
  }'
```

**Get Statistics**:
```bash
curl https://souqmatbakh.com/api/v1/quotes/stats
```

**Test Rate Limiting** (should fail after 10 requests):
```bash
for i in {1..15}; do
  curl -X POST https://souqmatbakh.com/api/v1/quotes/ \
    -H "Content-Type: application/json" \
    -d "{\"style\":\"modern\",\"city\":\"riyadh\",\"phone\":\"05123456$i\"}"
  echo ""
done
```

---

## Security Considerations

### ✅ Implemented
- Phone number validation (10 digits, starts with 05)
- Rate limiting (10 requests/minute)
- Duplicate detection (24-hour window)
- SQL injection protection (SQLAlchemy ORM)
- CORS restrictions (production domains only)

### ⚠️ Recommended for Production
1. **Admin Authentication**: Protect GET/PATCH/DELETE endpoints
2. **SMS Verification**: Verify phone number ownership
3. **CAPTCHA**: Add reCAPTCHA to prevent bot submissions
4. **IP Whitelisting**: Whitelist trusted IPs for admin endpoints
5. **Audit Logging**: Log all status changes and admin actions

---

## Admin Dashboard Integration

Recommended features for admin panel:

1. **List View**: Display all quote requests with filters
2. **Status Update**: Quick actions to change status
3. **Notes**: Add internal notes for each request
4. **Export**: Export data to CSV/Excel
5. **Analytics**: Visual charts for statistics
6. **Notifications**: Real-time alerts for new requests

---

## Monitoring & Alerts

### Log Files
```bash
# Application logs
sudo journalctl -u souqmatbakh-backend -f | grep "quote"

# Nginx access logs
sudo tail -f /var/log/nginx/souqmatbakh-access.log | grep "quotes"
```

### Database Queries
```sql
-- Count new requests today
SELECT COUNT(*) FROM quote_requests 
WHERE status = 'new' 
AND DATE(created_at) = CURRENT_DATE;

-- Most popular kitchen style
SELECT style, COUNT(*) as count 
FROM quote_requests 
GROUP BY style 
ORDER BY count DESC;

-- Conversion rate
SELECT 
  COUNT(CASE WHEN status = 'converted' THEN 1 END) * 100.0 / COUNT(*) as conversion_rate
FROM quote_requests;
```

---

## Troubleshooting

### Issue: Migration fails

**Solution**:
```bash
# Check current migration status
alembic current

# If stuck, reset to head
alembic stamp head

# Try upgrade again
alembic upgrade head
```

### Issue: Enum creation errors

**Solution**: PostgreSQL enums are persistent. If migration fails, manually drop:
```sql
DROP TYPE IF EXISTS kitchenstyle CASCADE;
DROP TYPE IF EXISTS quoterequeststatus CASCADE;
```

Then re-run migration.

### Issue: Rate limit too strict

**Solution**: Edit `backend/app/routes/quotes.py`:
```python
@limiter.limit("20/minute")  # Increase from 10 to 20
```

---

## Files Modified/Created

| File | Type | Description |
|------|------|-------------|
| `backend/app/models/quote_request.py` | NEW | Database model |
| `backend/app/models/__init__.py` | MODIFIED | Added imports |
| `backend/app/routes/quotes.py` | NEW | API endpoints |
| `backend/app/main.py` | MODIFIED | Added router |
| `backend/alembic/versions/add_quote_requests.py` | NEW | Migration script |
| `lib/widgets/quote_request_form.dart` | MODIFIED | Added API comment |

---

**Documentation Version**: 1.0.0  
**Last Updated**: 2025-12-14  
**Author**: GitHub Copilot
