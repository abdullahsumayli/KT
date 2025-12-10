# KitchenTech - منصة المطابخ الذكية

## ✅ تم ربط Flutter بالـ Backend بنجاح!

### الملفات التي تم إنشاؤها/تحديثها:

1. **Data Model**

   - `lib/features/listings/models/kitchen_listing.dart`
   - نموذج بيانات KitchenListing مع fromJson و toJson و copyWith

2. **API Service**

   - `lib/features/listings/data/listings_api.dart`
   - خدمة ListingsApi للاتصال بالـ Backend
   - GET /api/v1/listings (مع فلاتر)
   - POST /api/v1/listings (إضافة مطبخ جديد)

3. **Listings Page**

   - `lib/pages/listings_placeholder_page.dart`
   - عرض المطابخ في Grid
   - فلاتر حسب المدينة والنوع
   - حالات: loading, error, empty, success

4. **Add Listing Page**
   - `lib/pages/add_listing_placeholder_page.dart`
   - نموذج إضافة مطبخ جديد
   - حقول: العنوان، السعر، المدينة، النوع، المادة، الأبعاد، الوصف

### كيفية التشغيل:

1. **Backend (FastAPI)**

   ```bash
   cd D:\KT\backend
   .venv\Scripts\activate
   uvicorn app.main:app --host 127.0.0.1 --port 8000
   ```

2. **Frontend (Flutter)**
   ```bash
   cd D:\KT\frontend\kitchentech_app
   flutter run -d chrome
   ```

### التدفق:

1. افتح التطبيق في المتصفح
2. من الصفحة الرئيسية، اضغط على "تصفّح المطابخ" لعرض قائمة المطابخ
3. استخدم الفلاتر للبحث حسب المدينة والنوع
4. اضغط على "إضافة مطبخ" لإضافة مطبخ جديد
5. املأ النموذج واضغط "حفظ الإعلان"

### API Endpoints:

- **GET** `http://localhost:8000/api/v1/listings`
  - Query params: `city`, `type`, `min_price`, `max_price`, `is_featured`
- **POST** `http://localhost:8000/api/v1/listings`
  - Body: `{ title, description, price, city, type, material, length_m, width_m, height_m }`

### تعيين القيم (Arabic → English):

**النوع (Type):**

- جديد → new
- مستعمل → used
- جاهز → ready
- تفصيل → custom

**المادة (Material):**

- خشب → wood
- ألمنيوم → aluminum
- مختلط → mixed
- غير محدد → unknown

### ✅ الميزات المطبقة:

- ✅ عرض قائمة المطابخ من الـ Backend
- ✅ فلترة حسب المدينة والنوع
- ✅ إضافة مطبخ جديد
- ✅ واجهة عربية كاملة
- ✅ تصميم responsive (واسع/ضيق)
- ✅ معالجة الأخطاء
- ✅ حالات التحميل
- ✅ رسائل النجاح/الفشل

### الحساب الموجود:

- **البريد الإلكتروني:** sumayliabdullah@gmail.com
- **كلمة المرور:** abd12345

---

**ملاحظة:** تأكد من تشغيل الـ Backend قبل فتح التطبيق!
