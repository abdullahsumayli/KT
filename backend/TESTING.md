# Backend API Testing Guide

## ✅ تم تشغيل الـ Backend بنجاح!

### 📍 الروابط الهامة

- **API Server**: http://localhost:8000
- **API Documentation (Swagger)**: http://localhost:8000/docs
- **API Documentation (ReDoc)**: http://localhost:8000/redoc

---

## 🔐 بيانات الدخول الافتراضية

### حساب المدير

- **Email**: `admin@kitchentech.sa`
- **Password**: `admin123456`
- **Role**: ADMIN
- ⚠️ **هام**: غيّر كلمة المرور فوراً!

---

## 📋 اختبار API Endpoints

### 1️⃣ Authentication (المصادقة)

#### تسجيل عميل جديد

```bash
POST http://localhost:8000/api/auth/register
Content-Type: application/json

{
  "email": "client@test.com",
  "username": "client1",
  "password": "password123",
  "full_name": "عميل تجريبي",
  "phone": "+966501111111",
  "role": "CLIENT"
}
```

#### تسجيل معلن جديد

```bash
POST http://localhost:8000/api/auth/register
Content-Type: application/json

{
  "email": "advertiser@test.com",
  "username": "advertiser1",
  "password": "password123",
  "full_name": "معلن تجريبي",
  "phone": "+966502222222",
  "role": "ADVERTISER",
  "company_name": "شركة المطابخ الحديثة",
  "company_address": "الرياض - حي النخيل",
  "city": "الرياض"
}
```

#### تسجيل الدخول

```bash
POST http://localhost:8000/api/auth/login
Content-Type: application/x-www-form-urlencoded

username=admin@kitchentech.sa&password=admin123456
```

**Response**: سيعطيك `access_token` استخدمه في باقي الطلبات:

```json
{
  "access_token": "eyJ...",
  "token_type": "bearer"
}
```

---

### 2️⃣ Plans (الباقات)

#### عرض جميع الباقات (لا يحتاج تسجيل دخول)

```bash
GET http://localhost:8000/api/plans
```

**Expected Response**:

```json
[
  {
    "id": 1,
    "name": "الباقة البرونزية",
    "type": "BRONZE",
    "price": 199.0,
    "max_ads": 10,
    "featured_ads": 0
  },
  {
    "id": 2,
    "name": "الباقة الفضية",
    "type": "SILVER",
    "price": 499.0,
    "max_ads": 30,
    "featured_ads": 2
  },
  {
    "id": 3,
    "name": "الباقة الذهبية",
    "type": "GOLD",
    "price": 999.0,
    "max_ads": null,
    "featured_ads": 5
  }
]
```

---

### 3️⃣ Listings (الإعلانات)

#### إنشاء إعلان جديد (يحتاج تسجيل دخول كمعلن)

```bash
POST http://localhost:8000/api/listings
Authorization: Bearer {your_token}
Content-Type: application/json

{
  "title": "مطبخ حديث للبيع",
  "description": "مطبخ جديد بحالة ممتازة مع جميع الأجهزة الكهربائية",
  "price": 15000,
  "city": "الرياض",
  "type": "modern",
  "material": "wood",
  "length_m": 4.5,
  "width_m": 2.5,
  "height_m": 2.8
}
```

#### عرض جميع الإعلانات المعتمدة

```bash
GET http://localhost:8000/api/listings?status=APPROVED&skip=0&limit=10
```

---

### 4️⃣ Admin Panel (لوحة التحكم)

#### إحصائيات لوحة التحكم

```bash
GET http://localhost:8000/api/admin/dashboard/stats
Authorization: Bearer {admin_token}
```

**Expected Response**:

```json
{
  "total_users": 1,
  "total_listings": 0,
  "pending_listings": 0,
  "approved_listings": 0,
  "total_subscriptions": 0,
  "active_subscriptions": 0,
  "total_revenue": 0.0,
  "monthly_revenue": 0.0
}
```

#### مراجعة إعلان (موافقة)

```bash
POST http://localhost:8000/api/admin/listings/{listing_id}/review
Authorization: Bearer {admin_token}
Content-Type: application/json

{
  "action": "approve"
}
```

#### مراجعة إعلان (رفض)

```bash
POST http://localhost:8000/api/admin/listings/{listing_id}/review
Authorization: Bearer {admin_token}
Content-Type: application/json

{
  "action": "reject",
  "reason": "الإعلان لا يتوافق مع معايير المنصة"
}
```

---

### 5️⃣ Profile (الملف الشخصي)

#### عرض ملفي الشخصي

```bash
GET http://localhost:8000/api/profile/me
Authorization: Bearer {your_token}
```

#### تحديث الملف الشخصي

```bash
PUT http://localhost:8000/api/profile/me
Authorization: Bearer {your_token}
Content-Type: application/json

{
  "full_name": "اسم جديد",
  "phone": "+966503333333",
  "city": "جدة"
}
```

---

### 6️⃣ Favorites (المفضلة)

#### إضافة إعلان للمفضلة

```bash
POST http://localhost:8000/api/favorites/{listing_id}
Authorization: Bearer {your_token}
```

#### عرض المفضلة

```bash
GET http://localhost:8000/api/favorites
Authorization: Bearer {your_token}
```

#### إزالة من المفضلة

```bash
DELETE http://localhost:8000/api/favorites/{listing_id}
Authorization: Bearer {your_token}
```

---

### 7️⃣ Contact (التواصل)

#### إرسال رسالة تواصل (لا يحتاج تسجيل دخول)

```bash
POST http://localhost:8000/api/contact
Content-Type: application/json

{
  "name": "أحمد محمد",
  "email": "ahmad@example.com",
  "message_type": "SUGGESTION",
  "message": "أقترح إضافة ميزة البحث المتقدم"
}
```

#### عرض جميع الرسائل (للمدير فقط)

```bash
GET http://localhost:8000/api/contact
Authorization: Bearer {admin_token}
```

---

### 8️⃣ Settings (الإعدادات)

#### عرض الإعدادات العامة (لا يحتاج تسجيل دخول)

```bash
GET http://localhost:8000/api/settings/public
```

**Expected Response**:

```json
{
  "site_name": "كيتشن تك",
  "primary_color": "#2196F3",
  "secondary_color": "#FF9800",
  "support_email": "support@kitchentech.sa",
  "support_phone": "+966501234567",
  "whatsapp_number": "+966501234567",
  "facebook_url": "https://facebook.com/kitchentech.sa",
  "twitter_url": "https://twitter.com/kitchentech_sa",
  "instagram_url": "https://instagram.com/kitchentech.sa"
}
```

---

## 🧪 سيناريو اختبار كامل

### الخطوة 1: تسجيل معلن جديد

1. استخدم endpoint `/api/auth/register` لتسجيل معلن
2. احفظ الـ `access_token` من الرد

### الخطوة 2: إنشاء إعلان

1. استخدم التوكن لإنشاء إعلان عبر `/api/listings`
2. الإعلان سيكون بحالة `PENDING`

### الخطوة 3: تسجيل دخول المدير

1. سجل دخول كمدير باستخدام `/api/auth/login`
2. احفظ التوكن الجديد

### الخطوة 4: مراجعة الإعلان

1. استخدم توكن المدير للموافقة على الإعلان
2. الإعلان سيصبح `APPROVED` ومرئي للجميع

### الخطوة 5: تسجيل عميل

1. سجل عميل جديد عبر `/api/auth/register`
2. احفظ توكن العميل

### الخطوة 6: إضافة للمفضلة

1. استخدم توكن العميل لإضافة الإعلان للمفضلة
2. تحقق من قائمة المفضلة

### الخطوة 7: الاشتراك في باقة

1. استخدم توكن المعلن لعرض الباقات
2. أنشئ اشتراك جديد
3. قم بتأكيد الدفع

---

## 🔍 فحص قاعدة البيانات

يمكنك فتح قاعدة البيانات SQLite باستخدام:

```bash
sqlite3 d:/KT/backend/kitchentech.db
```

أوامر مفيدة:

```sql
-- عرض جميع الجداول
.tables

-- عرض المستخدمين
SELECT id, email, username, role, status FROM users;

-- عرض الباقات
SELECT id, name, type, price, max_ads FROM plans;

-- عرض الإعلانات
SELECT id, title, status, city, price FROM listings;

-- عرض الاشتراكات
SELECT id, user_id, plan_id, status, payment_status FROM subscriptions;
```

---

## 📊 هيكل قاعدة البيانات

### الجداول المتوفرة:

1. **users** - المستخدمين (عملاء، معلنين، مدراء)
2. **listings** - الإعلانات
3. **listing_images** - صور الإعلانات
4. **favorites** - المفضلة
5. **plans** - الباقات
6. **subscriptions** - الاشتراكات
7. **contact_messages** - رسائل التواصل
8. **site_settings** - إعدادات الموقع

---

## 🐛 استكشاف الأخطاء

### مشكلة: خطأ في المصادقة

**الحل**: تأكد من إضافة `Authorization: Bearer {token}` في رأس الطلب

### مشكلة: 403 Forbidden

**الحل**: تحقق من أن دور المستخدم يسمح بالوصول لهذا الـ endpoint

### مشكلة: 422 Validation Error

**الحل**: تحقق من صحة البيانات المرسلة حسب المطلوب في API docs

---

## 📱 التكامل مع Frontend Flutter

### تغيير الـ baseUrl في Flutter:

في ملف `lib/core/services/api_service.dart`:

```dart
static const String baseUrl = 'http://localhost:8000';
```

أو للاختبار على جهاز حقيقي:

```dart
static const String baseUrl = 'http://YOUR_IP:8000';
```

---

## ✅ قائمة التحقق

- [x] قاعدة البيانات تم إنشاؤها بنجاح
- [x] البيانات الافتراضية تم إضافتها (3 باقات، 13 إعداد، حساب مدير)
- [x] الخادم يعمل على http://localhost:8000
- [x] API Documentation متاح على /docs
- [x] جميع الـ Routes مسجلة (10 route modules)
- [ ] اختبار تسجيل الدخول
- [ ] اختبار إنشاء إعلان
- [ ] اختبار الموافقة على إعلان
- [ ] اختبار الاشتراك في باقة
- [ ] اختبار المفضلة
- [ ] التكامل مع Frontend

---

**🎉 Backend جاهز للاستخدام!**  
**📚 راجع التوثيق التفاعلي على**: http://localhost:8000/docs
