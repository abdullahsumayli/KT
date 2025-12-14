# Flutter API Integration - Quote Requests

تم تكامل مكون `QuoteRequestForm` بنجاح مع API الإنتاج على `https://souqmatbakh.com`.

## ✅ ما تم إنجازه

### 1. API Service Layer

- ✅ إنشاء `lib/services/quote_api_service.dart`
- ✅ دعم كامل لـ HTTP requests عبر `http` package
- ✅ معالجة شاملة للأخطاء (Timeout, Rate Limiting, Validation)
- ✅ رسائل خطأ واضحة باللغة العربية
- ✅ Timeout تلقائي بعد 10 ثواني

### 2. Widget Integration

- ✅ تحديث `QuoteRequestForm` لاستخدام API الحقيقي
- ✅ إزالة Mock API
- ✅ معالجة استجابة السيرفر (عرض رقم الطلب)
- ✅ تحسين رسائل النجاح والخطأ

### 3. Testing

- ✅ Integration tests في `test/integration/quote_api_integration_test.dart`
- ✅ اختبارات validation للهاتف
- ✅ اختبارات معالجة الأخطاء

## 🎯 الملفات المعدلة

```
lib/
  ├── services/
  │   └── quote_api_service.dart         (جديد)
  └── widgets/
      ├── quote_request_form.dart        (محدث)
      └── QUOTE_REQUEST_FORM_DOCS.md     (محدث)

test/
  └── integration/
      └── quote_api_integration_test.dart (جديد)
```

## 🚀 كيفية الاستخدام

### في أي صفحة Flutter:

```dart
import 'package:flutter/material.dart';
import 'package:kitchentech_app/widgets/quote_request_form.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('طلب عرض سعر')),
      body: QuoteRequestForm(), // ✅ متصل تلقائياً بـ API
    );
  }
}
```

## 📡 API Endpoint

```
POST https://souqmatbakh.com/api/v1/quotes/
Content-Type: application/json

{
  "style": "modern",
  "city": "riyadh",
  "phone": "0512345678"
}

Response (201 Created):
{
  "id": 1,
  "style": "modern",
  "city": "riyadh",
  "phone": "0512345678",
  "status": "new",
  "created_at": "2025-12-14T13:06:07.981900"
}
```

## 🔒 Security & Rate Limiting

- **Rate Limit**: 10 requests per minute per IP (من backend)
- **Nginx Rate Limit**: 20 requests per second للـ API بشكل عام
- **Validation**: رقم الجوال يجب أن يكون بصيغة `05xxxxxxxx`
- **HTTPS Only**: جميع الطلبات عبر SSL/TLS

## 🧪 تشغيل الاختبارات

```bash
# Unit tests
flutter test test/integration/quote_api_integration_test.dart

# Integration test (يتطلب اتصال بالإنترنت)
flutter test --concurrency=1 test/integration/
```

## 🐛 معالجة الأخطاء

| Error Code       | Status | رسالة للمستخدم                                   |
| ---------------- | ------ | ------------------------------------------------ |
| TIMEOUT          | N/A    | انتهى الوقت المحدد للطلب. تحقق من اتصال الإنترنت |
| RATE_LIMIT       | 429    | تم إرسال طلبات كثيرة. الرجاء الانتظار دقيقة      |
| VALIDATION_ERROR | 400    | البيانات المدخلة غير صحيحة                       |
| SERVER_ERROR     | 500+   | خطأ في السيرفر. الرجاء المحاولة لاحقاً           |
| NETWORK_ERROR    | N/A    | فشل الاتصال. تحقق من اتصال الإنترنت              |

## 📊 Production Status

| Component       | Status        | URL                             |
| --------------- | ------------- | ------------------------------- |
| Backend API     | ✅ Running    | https://souqmatbakh.com/api/v1/ |
| Database        | ✅ PostgreSQL | kitchentech_db                  |
| SSL Certificate | ✅ Active     | Cloudflare                      |
| Rate Limiting   | ✅ Active     | Nginx + slowapi                 |

## 🔄 تحديث API URL (Development)

للتطوير المحلي، عدّل `quote_api_service.dart`:

```dart
// في lib/services/quote_api_service.dart
static const String baseUrl = 'http://localhost:8000/api/v1';
// أو
static const String baseUrl = 'https://souqmatbakh.com/api/v1'; // Production
```

## 📝 Notes

1. **Dependencies**: تأكد من أن `http: ^1.1.0` موجود في `pubspec.yaml`
2. **Permissions**: للأندرويد، تأكد من إضافة `INTERNET` permission في `AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   ```
3. **iOS**: تأكد من إضافة `NSAppTransportSecurity` في `Info.plist` إذا كنت تستخدم HTTP (غير مطلوب لـ HTTPS)

## 🎉 نتائج الاختبار

```bash
# اختبار حي من الإنترنت:
$ curl -X POST https://souqmatbakh.com/api/v1/quotes/ \
  -H "Content-Type: application/json" \
  -d '{"style":"modern","city":"riyadh","phone":"0512345679"}'

Response:
{
  "id": 2,
  "style": "modern",
  "city": "riyadh",
  "phone": "0512345679",
  "status": "new",
  "created_at": "2025-12-14T13:06:07.981900"
}
```

## 🔗 روابط ذات صلة

- [Backend API Documentation](../../backend/QUOTE_REQUESTS_API.md)
- [Widget Documentation](../lib/widgets/QUOTE_REQUEST_FORM_DOCS.md)
- [Security Audit Report](../../SECURITY_AUDIT_REPORT.md)
- [Deployment Guide](../../deploy/README.md)

---

**Last Updated**: December 14, 2025  
**Status**: ✅ Production Ready  
**API Version**: v1
