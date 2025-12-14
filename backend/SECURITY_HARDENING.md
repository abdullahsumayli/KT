# KitchenTech Backend Security Hardening

## Overview

This document describes the security hardening measures implemented in the KitchenTech backend API.

---

## 1. Secret Management ✅

### Changes:

- **Removed hardcoded SECRET_KEY** from `config.py`
- **Environment variable requirement**: `KT_SECRET_KEY` must be set in `.env`
- **Startup validation**: Application checks for secure key at startup and exits if invalid in production

### Files Modified:

- `app/core/config.py` - Added environment variable validation
- `.env.example` - Updated with proper documentation
- `.env` - Created with development defaults

### How to Generate Secure Key:

```bash
openssl rand -hex 32
```

### Production Setup:

```bash
# In .env file
KT_SECRET_KEY=your-64-character-hex-string-here
APP_ENV=prod
```

---

## 2. Environment-Based Configuration ✅

### Changes:

- **New APP_ENV variable**: Controls debug mode and error verbosity
  - `dev`: Debug enabled, detailed errors, API docs visible
  - `prod`: Debug disabled, generic errors, API docs hidden
- **DEBUG mode**: Now computed property based on APP_ENV
- **Global exception handler**: Hides internal errors in production

### Files Modified:

- `app/core/config.py` - Added APP_ENV and DEBUG property
- `app/main.py` - Added global exception handler
- `.env` - Set APP_ENV=dev

### Production Mode Features:

- API documentation disabled at `/docs` and `/redoc`
- Stack traces hidden from client responses
- All errors logged server-side
- Generic error messages returned to users

---

## 3. CORS Configuration ✅

### Changes:

- **Replaced `allow_origins=["*"]`** with environment-configured list
- **New variable**: `ALLOWED_ORIGINS` (comma-separated domains)
- **Production validation**: Rejects wildcard `*` in production mode

### Files Modified:

- `app/core/config.py` - Added `allowed_origins_list` property
- `app/main.py` - Updated CORS middleware
- `.env` - Set allowed origins for development

### Production Setup:

```bash
# In .env file
ALLOWED_ORIGINS=https://kitchentech.sa,https://www.kitchentech.sa
```

---

## 4. Rate Limiting (Login Endpoints) ✅

### Changes:

- **Implemented SimpleRateLimiter**: In-memory rate limiting for login attempts
- **Limit**: 5 attempts per minute per IP address
- **Applied to**:
  - `/api/v1/auth/login` (email login)
  - `/api/v1/auth/login/phone` (phone login)
- **Response**: HTTP 429 (Too Many Requests) when limit exceeded

### Files Modified:

- `app/routes/auth.py` - Added rate limiter class and enforcement

### Improvements Needed (Future):

- Use Redis-based rate limiting for multi-instance deployments
- Add configurable limits per environment
- Consider using `slowapi` or `fastapi-limiter` package

---

## 5. Password Policy ✅

### Changes:

- **Minimum 8 characters**
- **At least one uppercase letter**
- **At least one digit**
- **Validation on registration**: Returns clear 422 error with specific requirements

### Files Modified:

- `app/routes/auth.py` - Added `@validator` to `UserRegister` schema

### Example Error:

```json
{
  "detail": [
    {
      "loc": ["body", "password"],
      "msg": "Password must contain at least one uppercase letter",
      "type": "value_error"
    }
  ]
}
```

---

## 6. File Upload Security ✅

### Changes:

- **Maximum file size**: 5 MB per file
- **Allowed extensions**: `.jpg`, `.jpeg`, `.png`, `.webp` only
- **Content-type validation**: Must match `image/jpeg`, `image/png`, or `image/webp`
- **Triple validation**:
  1. Content-Type header check
  2. File extension check
  3. File size check (after reading content)

### Files Modified:

- `app/routes/images.py` - Added comprehensive file validation

### Security Benefits:

- Prevents shell script uploads (`.sh`, `.php`, etc.)
- Prevents path traversal attacks
- Prevents DoS via large file uploads
- Reduces storage abuse

### Error Messages:

- Clear user-facing messages for each violation
- File size shown in MB for clarity

---

## 7. Audit Logging ✅

### Changes:

- **Configured Python logging module** with consistent logger name: `"kitchentech"`
- **Log format**: Timestamp, logger name, level, message
- **Logged operations**:
  - ✅ User registration (success)
  - ✅ Login attempts (success/failure) with IP address
  - ❌ Failed authentication attempts
  - 🔍 Admin listing reviews (approve/reject with reason)
  - ✅ Listing creation
  - ✅ Listing updates
  - 🗑️ Listing deletion
  - ✅ Image uploads
  - 🗑️ Image deletion
  - ❌ Unauthorized access attempts

### Files Modified:

- `app/main.py` - Configured logging
- `app/routes/auth.py` - Login/registration logging
- `app/routes/listings.py` - CRUD operation logging
- `app/routes/images.py` - Upload/delete logging
- `app/routes/admin.py` - Admin action logging

### Log Examples:

```
2025-12-12 10:30:45 - kitchentech - INFO - ✅ New user registered: user@example.com (ID: 123)
2025-12-12 10:31:00 - kitchentech - INFO - ✅ Successful login: user@example.com (ID: 123) from IP: 192.168.1.100
2025-12-12 10:32:15 - kitchentech - WARNING - ❌ Failed login attempt for: user@example.com from IP: 192.168.1.101
2025-12-12 10:35:00 - kitchentech - INFO - ✅ New listing created: ID 45 - 'Commercial Kitchen Downtown' by user 123
2025-12-12 10:40:00 - kitchentech - INFO - 🔍 Listing 45 status changed from pending to approved by admin 1
```

### Future Improvements:

- Send logs to centralized logging service (Sentry, CloudWatch, etc.)
- Add structured logging (JSON format)
- Log retention policies
- Security event alerting

---

## 8. Database Configuration

### Changes:

- **DATABASE_URL now required** via environment variable
- **Production warning**: Warns if using SQLite in production

### Production Recommendation:

```bash
# Use PostgreSQL in production
DATABASE_URL=postgresql://user:password@localhost:5432/kitchentech
```

---

## Summary of Files Changed

| File                     | Changes                                                 |
| ------------------------ | ------------------------------------------------------- |
| `app/core/config.py`     | Environment-based config, validation, CORS list parsing |
| `app/main.py`            | CORS from env, global exception handler, logging setup  |
| `app/routes/auth.py`     | Rate limiting, password validation, audit logging       |
| `app/routes/listings.py` | Audit logging for CRUD operations                       |
| `app/routes/images.py`   | File size/type validation, audit logging                |
| `app/routes/admin.py`    | Audit logging for admin actions                         |
| `.env.example`           | Updated documentation                                   |
| `.env`                   | Created with development defaults                       |

---

## Testing the Changes

### 1. Test Startup Validation

```bash
# Should fail if KT_SECRET_KEY is not set or too short
unset KT_SECRET_KEY
python -m uvicorn app.main:app

# Should pass with proper key
export KT_SECRET_KEY=$(openssl rand -hex 32)
python -m uvicorn app.main:app
```

### 2. Test Rate Limiting

```bash
# Make 6 login attempts rapidly - 6th should fail with 429
for i in {1..6}; do
  curl -X POST http://localhost:8000/api/v1/auth/login \
    -d "username=test@test.com&password=wrong"
done
```

### 3. Test Password Policy

```bash
# Should fail: too short
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","username":"test","password":"Short1"}'

# Should fail: no uppercase
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","username":"test","password":"short123"}'

# Should succeed
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","username":"test","password":"Strong123"}'
```

### 4. Test File Upload Limits

```bash
# Should fail: file too large (create 6MB file)
dd if=/dev/zero of=large.jpg bs=1M count=6
curl -X POST http://localhost:8000/api/v1/listings/1/images \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "files=@large.jpg"

# Should fail: wrong extension
curl -X POST http://localhost:8000/api/v1/listings/1/images \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "files=@script.php"
```

### 5. Test CORS

```bash
# Should fail in production if origin not in ALLOWED_ORIGINS
curl -H "Origin: https://evil.com" \
  http://localhost:8000/api/v1/listings
```

---

## Production Deployment Checklist

- [ ] Generate secure `KT_SECRET_KEY` with `openssl rand -hex 32`
- [ ] Set `APP_ENV=prod` in `.env`
- [ ] Set `DATABASE_URL` to PostgreSQL connection string
- [ ] Configure `ALLOWED_ORIGINS` with actual frontend domain(s)
- [ ] Review and configure `OPENAI_API_KEY` if using AI features
- [ ] Set up log forwarding to centralized service
- [ ] Configure backup strategy for database
- [ ] Set up monitoring and alerting
- [ ] Review firewall rules and network security
- [ ] Enable HTTPS with valid SSL certificate
- [ ] Test all security measures in staging environment

---

## Known Limitations

1. **Rate limiting is in-memory**: Will not work correctly with multiple instances. Use Redis in production.
2. **File scanning**: No malware scanning implemented. Consider adding ClamAV or VirusTotal integration.
3. **No token revocation**: JWT tokens cannot be revoked before expiry. Implement token blacklist with Redis.
4. **No email verification**: Users are not required to verify email addresses.
5. **No account lockout**: Repeated failed logins do not permanently lock accounts.
6. **No 2FA**: Two-factor authentication is not implemented.

---

## Next Steps (Not Implemented)

These are P1/P2 priorities that should be addressed before large-scale production launch:

1. **Token Refresh Mechanism**: Implement refresh tokens with `/api/v1/auth/refresh` endpoint
2. **Email Verification**: Send verification emails on registration
3. **Account Lockout**: Lock accounts after repeated failed login attempts
4. **Redis-Based Rate Limiting**: Replace in-memory limiter with Redis
5. **Token Blacklist**: Allow logout to invalidate tokens immediately
6. **Malware Scanning**: Scan uploaded files for malicious content
7. **Input Sanitization**: Add comprehensive input validation across all endpoints
8. **SQL Injection Protection**: Review all raw SQL queries (already using ORM)
9. **Structured Logging**: Move to JSON log format for better parsing
10. **Monitoring Integration**: Add Sentry, Prometheus, or CloudWatch
