# 🎛️ Admin Dashboard - سوق مطبخ

لوحة تحكم شاملة لإدارة طلبات عروض الأسعار من العملاء مع إحصائيات مفصلة.

## 📋 المحتويات

- [المميزات](#-المميزات)
- [البنية التقنية](#-البنية-التقنية)
- [التشغيل](#-التشغيل)
- [الصفحات](#-الصفحات)
- [الأمان](#-الأمان)
- [API Integration](#-api-integration)

## ✨ المميزات

### 1. **نظام المصادقة (Authentication)**
- ✅ تسجيل دخول آمن بـ JWT Token
- ✅ تخزين Token بشكل آمن مع `flutter_secure_storage`
- ✅ Auto-logout عند انتهاء الجلسة
- ✅ حماية جميع صفحات الإدارة

### 2. **إدارة الطلبات (Quote Management)**
- ✅ عرض جميع طلبات العملاء
- ✅ تصفية حسب الحالة (Status):
  - 🆕 جديد (New)
  - 📞 تم التواصل (Contacted)
  - 💰 تم إرسال السعر (Quoted)
  - ✅ تم التحويل (Converted)
  - ❌ مفقود (Lost)
- ✅ تحديث حالة الطلب
- ✅ إضافة ملاحظات داخلية
- ✅ حذف الطلبات
- ✅ نسخ رقم الجوال بضغطة واحدة

### 3. **الإحصائيات والتحليلات (Analytics)**
- 📊 إجمالي الطلبات
- 📈 التوزيع حسب نوع المطبخ (مودرن، كلاسيك، خشب، ألمنيوم)
- 📍 التوزيع حسب المدينة
- 🎯 معدل التحويل (Conversion Rate)
- 📉 التوزيع حسب الحالة مع نسب مئوية

### 4. **واجهة المستخدم (UI/UX)**
- ✅ دعم كامل للغة العربية RTL
- ✅ Material Design 3
- ✅ Pull-to-refresh على جميع الصفحات
- ✅ Loading states وتنبيهات واضحة
- ✅ ألوان مميزة لكل حالة
- ✅ مؤشرات تقدم مرئية

## 🏗️ البنية التقنية

### الملفات الرئيسية:

```
lib/
├── services/
│   └── admin_service.dart          # Service layer للـ API
├── admin/
│   ├── admin_login_page.dart       # صفحة تسجيل الدخول
│   ├── admin_dashboard_page.dart   # الصفحة الرئيسية
│   ├── quote_details_page.dart     # صفحة تفاصيل الطلب
│   └── analytics_page.dart         # صفحة الإحصائيات
└── main_admin_demo.dart            # تطبيق Demo

backend/
├── app/routes/quotes.py            # API endpoints محمية
└── check_admin.py                  # إنشاء/تحديث admin user
```

### التبعيات (Dependencies):

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0                      # API requests
  flutter_secure_storage: ^9.0.0   # Secure token storage
```

## 🚀 التشغيل

### 1. إضافة التبعيات:

```bash
flutter pub add flutter_secure_storage
```

### 2. تشغيل الـ Demo:

```bash
flutter run -d chrome -t lib/main_admin_demo.dart
```

### 3. بيانات الدخول:

```
Email: admin@kitchentech.sa
Password: Admin@2025
```

## 📱 الصفحات

### 1. صفحة تسجيل الدخول (AdminLoginPage)

**الموقع:** `lib/admin/admin_login_page.dart`

**المميزات:**
- نموذج تسجيل دخول مع validation
- Toggle لإظهار/إخفاء كلمة المرور
- رسائل خطأ واضحة بالعربية
- Loading indicator أثناء الطلب
- تصميم Material Card مع gradient

**الاستخدام:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const AdminLoginPage()),
);
```

### 2. لوحة التحكم الرئيسية (AdminDashboardPage)

**الموقع:** `lib/admin/admin_dashboard_page.dart`

**المميزات:**
- عرض قائمة الطلبات في Cards
- فلاتر سريعة (FilterChips) لتصفية الطلبات
- Pull-to-refresh
- Status badges ملونة
- زر الانتقال للإحصائيات
- قائمة logout

**Code Example:**
```dart
// Navigate to Dashboard
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => const AdminDashboardPage(),
  ),
);
```

**Filter Options:**
```dart
final filters = ['all', 'new', 'contacted', 'quoted', 'converted', 'lost'];
```

### 3. صفحة تفاصيل الطلب (QuoteDetailsPage)

**الموقع:** `lib/admin/quote_details_page.dart`

**المميزات:**
- عرض معلومات العميل كاملة
- تحديث الحالة مع ChoiceChips
- إضافة/تعديل ملاحظات داخلية
- نسخ رقم الجوال
- حذف الطلب مع تأكيد
- حفظ التغييرات

**الاستخدام:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => QuoteDetailsPage(quoteId: 1),
  ),
);
```

**Status Colors:**
```dart
Color getStatusColor(String status) {
  switch (status) {
    case 'new': return Colors.blue;
    case 'contacted': return Colors.orange;
    case 'quoted': return Colors.purple;
    case 'converted': return Colors.green;
    case 'lost': return Colors.red;
  }
}
```

### 4. صفحة الإحصائيات (AnalyticsPage)

**الموقع:** `lib/admin/analytics_page.dart`

**المميزات:**
- بطاقة إجمالي الطلبات
- توزيع حسب نوع المطبخ مع نسب مئوية
- توزيع حسب المدينة مع رسوم بيانية
- توزيع حسب الحالة
- معدل التحويل (Conversion Rate)

**الاستخدام:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const AnalyticsPage(),
  ),
);
```

## 🔐 الأمان

### 1. JWT Authentication

```dart
// تخزين Token
await _storage.write(key: _tokenKey, value: token);

// استرجاع Token
final token = await _storage.read(key: _tokenKey);

// إضافة Token للـ headers
final headers = {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
};
```

### 2. Auto-Logout on 401

```dart
if (response.statusCode == 401) {
  await AdminService.logout();
  throw AdminAuthException('انتهت صلاحية الجلسة');
}
```

### 3. Protected Endpoints

جميع Admin endpoints محمية في Backend:

```python
@router.get("/", response_model=List[QuoteRequestResponse])
async def get_quote_requests(
    admin: User = Depends(verify_admin)  # Required
):
    # ...
```

## 🔌 API Integration

### AdminService Methods:

#### 1. تسجيل الدخول:
```dart
final response = await AdminService.login(
  email: 'admin@kitchentech.sa',
  password: 'Admin@2025',
);
// Returns: {access_token: "...", token_type: "bearer"}
```

#### 2. جلب الطلبات:
```dart
final quotes = await AdminService.fetchAllQuotes(
  status: 'new',        // Optional filter
  style: 'modern',      // Optional filter
  city: 'riyadh',       // Optional filter
  skip: 0,
  limit: 100,
);
```

#### 3. جلب طلب واحد:
```dart
final quote = await AdminService.fetchQuoteById(1);
```

#### 4. تحديث الحالة:
```dart
final updated = await AdminService.updateQuoteStatus(
  id: 1,
  status: 'contacted',
  adminNotes: 'تم التواصل مع العميل',
);
```

#### 5. حذف طلب:
```dart
await AdminService.deleteQuote(1);
```

#### 6. جلب الإحصائيات:
```dart
final stats = await AdminService.fetchStats();
// Returns:
// {
//   total: 3,
//   by_style: {...},
//   by_city: {...},
//   by_status: {...}
// }
```

### API Endpoints:

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/v1/auth/login` | ❌ | تسجيل الدخول |
| GET | `/api/v1/quotes/` | ✅ | قائمة الطلبات |
| GET | `/api/v1/quotes/stats` | ✅ | الإحصائيات |
| GET | `/api/v1/quotes/{id}` | ✅ | تفاصيل طلب |
| PATCH | `/api/v1/quotes/{id}/status` | ✅ | تحديث الحالة |
| DELETE | `/api/v1/quotes/{id}` | ✅ | حذف طلب |

## 🎨 التخصيص (Customization)

### تغيير الألوان:

```dart
// في AdminDashboardPage
Card(
  color: Colors.teal.shade50,  // غير اللون هنا
  // ...
)
```

### تغيير الترجمات:

```dart
String _getStatusLabel(String status) {
  switch (status) {
    case 'new': return 'جديد';  // غير الترجمة هنا
    // ...
  }
}
```

### إضافة فلتر جديد:

```dart
// في AdminDashboardPage
final _filterOptions = [
  'all',
  'new',
  'your_new_filter',  // أضف فلتر جديد
];
```

## 🐛 معالجة الأخطاء (Error Handling)

### AdminAuthException:
```dart
try {
  await AdminService.login(email: email, password: password);
} catch (e) {
  if (e is AdminAuthException) {
    // خطأ مصادقة
    print(e.message);  // "البريد الإلكتروني أو كلمة المرور غير صحيحة"
  }
}
```

### AdminApiException:
```dart
try {
  await AdminService.fetchAllQuotes();
} catch (e) {
  if (e is AdminApiException) {
    // خطأ API
    print(e.message);  // "خطأ في الاتصال بالسيرفر"
  }
}
```

## 📊 الإحصائيات (Analytics Data Structure)

```json
{
  "total": 3,
  "by_style": {
    "KitchenStyle.MODERN": 2,
    "KitchenStyle.CLASSIC": 1
  },
  "by_city": {
    "riyadh": 2,
    "jeddah": 1
  },
  "by_status": {
    "QuoteRequestStatus.NEW": 3
  }
}
```

**المعالجة في Flutter:**
```dart
// تنظيف Enum values
final cleanStatus = status.replaceAll('QuoteRequestStatus.', '').toLowerCase();
final cleanStyle = style.replaceAll('KitchenStyle.', '').toLowerCase();
```

## 🧪 الاختبار (Testing)

### 1. اختبار تسجيل الدخول:
```bash
# في PowerShell
Invoke-RestMethod -Uri "https://souqmatbakh.com/api/v1/auth/login" `
  -Method Post `
  -ContentType "application/x-www-form-urlencoded" `
  -Body "username=admin@kitchentech.sa&password=Admin@2025"
```

### 2. اختبار الوصول للطلبات:
```bash
$token = "YOUR_TOKEN_HERE"
$headers = @{Authorization="Bearer $token"}
Invoke-RestMethod -Uri "https://souqmatbakh.com/api/v1/quotes/" -Headers $headers
```

## 📝 Notes & Tips

### Performance:
- استخدم `const` constructors حيث أمكن
- استخدم `ListView.builder` للقوائم الطويلة
- قم بـ caching للـ stats data

### Security:
- لا تشارك Token في logs
- استخدم HTTPS فقط
- قم بتحديث كلمة المرور بانتظام

### UX:
- أضف loading indicators واضحة
- استخدم Snackbars للتنبيهات
- أضف empty states للقوائم الفارغة

## 🔄 التحديثات المستقبلية

- [ ] SMS Notifications
- [ ] Email Notifications
- [ ] Export to CSV/Excel
- [ ] Advanced search
- [ ] Multi-language support
- [ ] Dark mode
- [ ] Charts and graphs
- [ ] Offline support

## 📚 المراجع

- [Flutter Documentation](https://flutter.dev/docs)
- [Material Design 3](https://m3.material.io/)
- [JWT.io](https://jwt.io/)
- [FastAPI Docs](https://fastapi.tiangolo.com/)

---

**تم التطوير بواسطة:** GitHub Copilot  
**التاريخ:** ديسمبر 2025  
**الإصدار:** 1.0.0
