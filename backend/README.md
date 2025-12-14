# KitchenTech Backend API

Backend API للمنصة كيتشن تك - منصة لعرض وإدارة إعلانات المطابخ.

## 📋 المتطلبات

- Python 3.10+
- PostgreSQL أو SQLite
- pip (Python package manager)

## 🚀 التثبيت والإعداد

### 1. تفعيل البيئة الافتراضية

```bash
# Windows
.venv\Scripts\activate

# Linux/Mac
source .venv/bin/activate
```

### 2. تثبيت المكتبات المطلوبة

```bash
pip install -r requirements.txt
```

### 3. إعداد متغيرات البيئة

انسخ ملف `.env.example` إلى `.env` وقم بتحديث القيم:

```bash
copy .env.example .env  # Windows
# cp .env.example .env  # Linux/Mac
```

قم بتعديل المتغيرات في ملف `.env`:

```env
# Database
KT_DATABASE_URL=postgresql+psycopg2://kt_user:kt_password@localhost:5432/kitchentech_dev

# Security
KT_SECRET_KEY=your-secret-key-here-min-32-chars
KT_DEBUG=True

# CORS
KT_CORS_ALLOW_ORIGINS=http://localhost:3000,http://localhost:5173

# Rate Limiting
KT_RATE_LIMIT_ENABLED=True
KT_RATE_LIMIT_PER_MINUTE=60
```

⚠️ **مهم**:

- في بيئة التطوير، يمكنك استخدام SQLite: `KT_DATABASE_URL=sqlite:///./kitchentech.db`
- في بيئة الإنتاج، **يجب** استخدام PostgreSQL
- قم بتوليد `KT_SECRET_KEY` عشوائي وآمن (32 حرف على الأقل)

### 4. إعداد قاعدة البيانات PostgreSQL

#### تثبيت PostgreSQL (إذا لم يكن مثبتاً)

**Windows**:

```bash
# قم بتحميل PostgreSQL من الموقع الرسمي
# https://www.postgresql.org/download/windows/
```

**Linux (Ubuntu/Debian)**:

```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
```

**macOS**:

```bash
brew install postgresql
brew services start postgresql
```

#### إنشاء قاعدة البيانات والمستخدم

قم بتشغيل الأوامر التالية في PostgreSQL:

```bash
# الدخول إلى PostgreSQL shell
psql -U postgres

# داخل PostgreSQL shell:
CREATE DATABASE kitchentech_dev;
CREATE USER kt_user WITH PASSWORD 'kt_password';
GRANT ALL PRIVILEGES ON DATABASE kitchentech_dev TO kt_user;

# في PostgreSQL 15+، قد تحتاج أيضاً:
\c kitchentech_dev
GRANT ALL ON SCHEMA public TO kt_user;

# للخروج:
\q
```

#### بدائل SQLite للتطوير (اختياري)

إذا أردت استخدام SQLite للتطوير السريع:

```env
KT_DATABASE_URL=sqlite:///./kitchentech.db
```

**ملاحظة**: SQLite **غير مسموح** في بيئة الإنتاج - ستحصل على خطأ عند تشغيل التطبيق.

### 5. تشغيل migrations لإنشاء الجداول

قم بتطبيق migrations لإنشاء جميع جداول قاعدة البيانات:

```bash
# تطبيق جميع migrations
alembic upgrade head
```

هذا الأمر سينشئ الجداول التالية:

- `users` - المستخدمين
- `plans` - باقات الاشتراك
- `subscriptions` - الاشتراكات
- `listings` - إعلانات المطابخ
- `listing_images` - صور الإعلانات
- `favorites` - المفضلة
- `contact_messages` - رسائل التواصل
- `site_settings` - إعدادات الموقع

### 6. تهيئة البيانات الافتراضية

قم بتشغيل السكريبت لإضافة الباقات والإعدادات الافتراضية:

```bash
python init_default_data.py
```

هذا السكريبت سيقوم بـ:

- ✅ إنشاء 3 باقات اشتراك (برونزية، فضية، ذهبية)
- ✅ إضافة إعدادات الموقع الافتراضية
- ✅ إنشاء حساب مدير النظام
  - Email: `admin@kitchentech.sa`
  - Password: `admin123456`
  - ⚠️ **هام**: غيّر كلمة المرور فوراً بعد التشغيل!

### 7. تشغيل السيرفر

```bash
# Windows
start_server.bat

# أو يدوياً
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

السيرفر سيعمل على: `http://localhost:8000`

## 📚 التوثيق التفاعلي (API Docs)

بعد تشغيل السيرفر، يمكنك الوصول إلى:

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## 🗂️ هيكل المشروع

```
backend/
├── app/
│   ├── core/                 # إعدادات التطبيق
│   ├── models/               # نماذج قاعدة البيانات
│   │   ├── user.py          # نموذج المستخدم
│   │   ├── listing.py       # نموذج الإعلانات
│   │   ├── plan.py          # نموذج الباقات
│   │   ├── subscription.py  # نموذج الاشتراكات
│   │   ├── favorite.py      # نموذج المفضلة
│   │   ├── contact_message.py # نموذج رسائل التواصل
│   │   └── site_setting.py  # نموذج إعدادات الموقع
│   ├── routes/               # مسارات API
│   │   ├── auth.py          # تسجيل الدخول والتسجيل
│   │   ├── listings.py      # إدارة الإعلانات
│   │   ├── admin.py         # لوحة تحكم المدير
│   │   ├── contact.py       # صفحة التواصل
│   │   ├── plans.py         # الباقات والاشتراكات
│   │   ├── profile.py       # الملف الشخصي
│   │   ├── favorites.py     # المفضلة
│   │   └── settings.py      # إعدادات الموقع
│   ├── database.py          # إعداد قاعدة البيانات
│   └── main.py              # التطبيق الرئيسي
├── media/                    # ملفات الوسائط المرفوعة
├── init_default_data.py     # سكريبت تهيئة البيانات
├── requirements.txt          # المكتبات المطلوبة
└── README.md                # هذا الملف
```

## 🔐 API Endpoints

### Auth (المصادقة)

- `POST /api/auth/register` - تسجيل مستخدم جديد
- `POST /api/auth/login` - تسجيل الدخول
- `GET /api/auth/me` - معلومات المستخدم الحالي

### Listings (الإعلانات)

- `GET /api/listings` - قائمة الإعلانات
- `GET /api/listings/{id}` - تفاصيل إعلان
- `POST /api/listings` - إنشاء إعلان جديد
- `PUT /api/listings/{id}` - تحديث إعلان
- `DELETE /api/listings/{id}` - حذف إعلان

### Admin (لوحة التحكم)

- `GET /api/admin/dashboard/stats` - إحصائيات لوحة التحكم
- `GET /api/admin/users` - قائمة المستخدمين
- `PUT /api/admin/users/{id}` - تحديث مستخدم
- `POST /api/admin/users/{id}/ban` - حظر مستخدم
- `GET /api/admin/listings` - قائمة جميع الإعلانات
- `POST /api/admin/listings/{id}/review` - مراجعة إعلان (موافقة/رفض)
- `POST /api/admin/listings/{id}/feature` - تمييز إعلان
- `GET /api/admin/plans` - قائمة الباقات
- `PUT /api/admin/plans/{id}` - تحديث سعر باقة
- `GET /api/admin/subscriptions` - قائمة الاشتراكات

### Contact (التواصل)

- `POST /api/contact` - إرسال رسالة تواصل
- `GET /api/contact` - قائمة رسائل التواصل (للمدير)

### Plans (الباقات)

- `GET /api/plans` - قائمة الباقات المتاحة
- `POST /api/plans/subscribe` - إنشاء اشتراك جديد
- `GET /api/plans/subscriptions/my` - اشتراكاتي
- `GET /api/plans/subscriptions/active` - الاشتراك النشط
- `POST /api/plans/subscriptions/{id}/confirm-payment` - تأكيد الدفع

### Profile (الملف الشخصي)

- `GET /api/profile/me` - معلومات الملف الشخصي
- `PUT /api/profile/me` - تحديث الملف الشخصي
- `GET /api/profile/my-listings` - إعلاناتي
- `DELETE /api/profile/me` - حذف الحساب

### Favorites (المفضلة)

- `GET /api/favorites` - قائمة المفضلة
- `POST /api/favorites/{listing_id}` - إضافة إلى المفضلة
- `DELETE /api/favorites/{listing_id}` - إزالة من المفضلة
- `GET /api/favorites/check/{listing_id}` - فحص حالة المفضلة

### Settings (الإعدادات)

- `GET /api/settings/public` - الإعدادات العامة
- `GET /api/settings` - جميع الإعدادات (للمدير)
- `PUT /api/settings/{key}` - تحديث إعداد (للمدير)
- `POST /api/settings/init-defaults` - تهيئة الإعدادات الافتراضية

## 🗄️ Database & Migrations (قاعدة البيانات والترحيلات)

### نظرة عامة

المشروع يستخدم:

- **SQLAlchemy 2.0.25**: ORM لإدارة قاعدة البيانات
- **Alembic 1.13.1**: أداة إدارة migrations
- **PostgreSQL**: قاعدة البيانات الإنتاجية (مطلوبة في production)
- **SQLite**: مدعومة للتطوير فقط (ممنوعة في production)

### إدارة Migrations باستخدام Alembic

#### 1. عرض حالة قاعدة البيانات الحالية

```bash
# عرض الـ migration الحالي
alembic current

# عرض سجل جميع الـ migrations
alembic history --verbose
```

#### 2. تطبيق migrations

```bash
# تطبيق جميع الـ migrations المتبقية
alembic upgrade head

# تطبيق migration واحد فقط
alembic upgrade +1

# الرجوع إلى migration محدد
alembic downgrade <revision_id>

# الرجوع migration واحد
alembic downgrade -1

# العودة إلى البداية (حذف جميع الجداول)
alembic downgrade base
```

#### 3. إنشاء migration جديد

عند إضافة أو تعديل نموذج في `app/models/`:

```bash
# إنشاء migration تلقائياً بناءً على تغييرات Models
alembic revision --autogenerate -m "Add new column to users table"

# إنشاء migration فارغ (للتعديل يدوياً)
alembic revision -m "Custom migration"
```

#### 4. التحقق من صحة Migration قبل التطبيق

```bash
# عرض SQL الذي سيتم تنفيذه
alembic upgrade head --sql

# وضع dry-run (لا ينفذ شيء، فقط يعرض الأوامر)
alembic upgrade head --sql > migration.sql
```

### Workflow: إضافة عمود جديد (مثال عملي)

لنفترض أنك تريد إضافة عمود `phone_verified` لجدول المستخدمين:

#### الخطوة 1: تعديل Model

قم بتحديث `app/models/user.py`:

```python
class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    email: Mapped[str] = mapped_column(String, unique=True, index=True)
    # ... الحقول الموجودة

    # إضافة الحقل الجديد
    phone_verified: Mapped[bool] = mapped_column(Boolean, default=False, server_default="false")
```

#### الخطوة 2: إنشاء Migration

```bash
alembic revision --autogenerate -m "Add phone_verified to users"
```

#### الخطوة 3: مراجعة ملف Migration

افتح الملف المُنشأ في `alembic/versions/` وتحقق من أنه صحيح:

```python
def upgrade() -> None:
    op.add_column('users', sa.Column('phone_verified', sa.Boolean(),
                                      server_default='false', nullable=False))

def downgrade() -> None:
    op.drop_column('users', 'phone_verified')
```

#### الخطوة 4: تطبيق Migration

```bash
# تطبيق على قاعدة البيانات
alembic upgrade head

# إذا حدث خطأ، يمكنك الرجوع
alembic downgrade -1
```

### أوامر PostgreSQL المفيدة

```bash
# الاتصال بقاعدة البيانات
psql -U kt_user -d kitchentech_dev

# عرض جميع الجداول
\dt

# وصف جدول محدد
\d users

# عرض جميع الفهارس (indexes)
\di

# تصدير قاعدة البيانات
pg_dump -U kt_user kitchentech_dev > backup.sql

# استيراد قاعدة البيانات
psql -U kt_user kitchentech_dev < backup.sql

# حذف وإعادة إنشاء قاعدة البيانات (احذر!)
DROP DATABASE kitchentech_dev;
CREATE DATABASE kitchentech_dev;
GRANT ALL PRIVILEGES ON DATABASE kitchentech_dev TO kt_user;
```

### هيكل الـ Migrations

```
backend/
├── alembic/
│   ├── versions/                    # ملفات الـ migrations
│   │   └── a1b2c3d4e5f6_initial_migration.py  # Migration الأولي
│   ├── env.py                       # إعدادات Alembic
│   └── script.py.mako               # قالب لإنشاء migrations جديدة
├── alembic.ini                      # ملف تكوين Alembic
└── app/
    ├── database.py                  # Base metadata (مصدر البيانات لـ Alembic)
    └── models/                      # نماذج SQLAlchemy
```

### استكشاف الأخطاء (Troubleshooting)

#### مشكلة: "Target database is not up to date"

```bash
# عرض الحالة الحالية
alembic current

# تطبيق الـ migrations المتبقية
alembic upgrade head
```

#### مشكلة: "Can't locate revision identified by '...'"

```bash
# حذف السجل من قاعدة البيانات وإعادة البدء
# احذر: هذا سيحذف جميع البيانات!
alembic downgrade base
alembic upgrade head
```

#### مشكلة: Migration لم يكتشف التغييرات

```bash
# تأكد من:
# 1. أن Model يستورد في app/models/__init__.py
# 2. أن Base.metadata محدث في alembic/env.py
# 3. جرب إنشاء migration يدوياً:
alembic revision -m "Manual migration"
```

#### مشكلة: خطأ في الاتصال بـ PostgreSQL

```bash
# تحقق من أن PostgreSQL يعمل:
# Windows:
Get-Service postgresql*

# Linux:
sudo systemctl status postgresql

# تحقق من صحة DATABASE_URL في .env
python -c "from app.core.config import settings; print(settings.DATABASE_URL)"
```

### Best Practices

1. **لا تعدل migrations بعد تطبيقها**: إذا تم تطبيق migration على الإنتاج، لا تعدله، بل أنشئ migration جديد
2. **اختبر migrations على قاعدة بيانات تجريبية أولاً**: لا تطبق مباشرة على الإنتاج
3. **راجع الـ autogenerated migrations يدوياً**: Alembic قد لا يكتشف جميع التغييرات بشكل صحيح
4. **احتفظ بنسخ احتياطية**: قم بعمل backup قبل تطبيق migrations على الإنتاج
5. **استخدم transactions**: Alembic يدعم transactions - استخدمها لضمان الـ rollback عند حدوث خطأ

### البيئات المختلفة

#### Development (التطوير)

```env
KT_DATABASE_URL=postgresql+psycopg2://kt_user:kt_password@localhost:5432/kitchentech_dev
KT_DEBUG=True
```

#### Staging (الاختبار)

```env
KT_DATABASE_URL=postgresql+psycopg2://kt_user:secure_password@staging-db.example.com:5432/kitchentech_staging
KT_DEBUG=False
```

#### Production (الإنتاج)

```env
KT_DATABASE_URL=postgresql+psycopg2://kt_user:very_secure_password@prod-db.example.com:5432/kitchentech_prod
KT_DEBUG=False
```

⚠️ **تحذير**: استخدام SQLite في production سيؤدي إلى خطأ!

## 👥 أنواع المستخدمين

### 1. Client (عميل)

- البحث عن المطابخ
- إضافة إلى المفضلة
- التواصل مع المعلنين

### 2. Advertiser (معلن)

- نشر إعلانات المطابخ
- إدارة الإعلانات
- الاشتراك في الباقات

### 3. Admin (مدير النظام)

- إدارة المستخدمين
- مراجعة الإعلانات
- إدارة الباقات والأسعار
- إعدادات الموقع

## 📦 الباقات المتاحة

### 🟤 البرونزية - 199 ر.س/شهر

- 10 إعلانات شهرياً
- دعم فني عادي

### ⚪ الفضية - 499 ر.س/شهر

- 30 إعلان شهرياً
- 2 إعلان مميز
- دعم فني عادي

### 🟡 الذهبية - 999 ر.س/شهر

- إعلانات غير محدودة
- 5 إعلانات مميزة
- دعم فني أولوية

## 🔄 حالات الإعلانات

- **PENDING** (بانتظار المراجعة): إعلان جديد ينتظر موافقة المدير
- **APPROVED** (معتمدة): إعلان تمت الموافقة عليه ومرئي للجميع
- **REJECTED** (مرفوضة): إعلان مرفوض مع سبب الرفض
- **INACTIVE** (غير نشطة): إعلان غير نشط (أوقفه المعلن)

## 🛠️ التطوير

### تشغيل في وضع التطوير

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### متغيرات البيئة المطلوبة

يرجى الرجوع إلى ملف `.env.example` للحصول على قائمة كاملة بالمتغيرات المطلوبة:

```env
# قاعدة البيانات
KT_DATABASE_URL=postgresql+psycopg2://kt_user:kt_password@localhost:5432/kitchentech_dev

# الأمان
KT_SECRET_KEY=your-secret-key-here-min-32-chars
KT_DEBUG=True

# CORS
KT_CORS_ALLOW_ORIGINS=http://localhost:3000,http://localhost:5173

# Rate Limiting
KT_RATE_LIMIT_ENABLED=True
KT_RATE_LIMIT_PER_MINUTE=60
```

### سير عمل التطوير (Development Workflow)

1. **عمل fork وتنزيل المشروع**

```bash
git clone https://github.com/your-username/kitchentech.git
cd kitchentech/backend
```

2. **إنشاء بيئة افتراضية**

```bash
python -m venv .venv
.venv\Scripts\activate  # Windows
# source .venv/bin/activate  # Linux/Mac
```

3. **تثبيت المكتبات**

```bash
pip install -r requirements.txt
```

4. **إعداد قاعدة البيانات**

```bash
# إنشاء قاعدة بيانات PostgreSQL
createdb kitchentech_dev

# تطبيق migrations
alembic upgrade head

# تهيئة البيانات الافتراضية
python init_default_data.py
```

5. **تشغيل السيرفر**

```bash
uvicorn app.main:app --reload
```

6. **إنشاء feature جديد**

```bash
git checkout -b feature/my-new-feature
# قم بالتعديلات
git commit -m "Add my new feature"
git push origin feature/my-new-feature
```

## 🔒 الأمان

- جميع كلمات المرور محفوظة باستخدام bcrypt hashing
- JWT tokens لتأمين المصادقة
- تحقق من صلاحيات المستخدم لكل endpoint
- CORS middleware للتحكم في الوصول

## 📝 ملاحظات

- يجب تغيير كلمة مرور المدير الافتراضية فوراً
- في بيئة الإنتاج، استخدم PostgreSQL بدلاً من SQLite
- تأكد من إعداد ملف `.env` بالمتغيرات الصحيحة
- قم بتكوين CORS بشكل صحيح في الإنتاج

## 🤝 المساهمة

للمساهمة في المشروع:

1. قم بعمل Fork للمشروع
2. أنشئ فرع جديد (`git checkout -b feature/amazing-feature`)
3. قم بعمل Commit (`git commit -m 'Add amazing feature'`)
4. ادفع التغييرات (`git push origin feature/amazing-feature`)
5. افتح Pull Request

## � Production Deployment (Hetzner)

For deploying to production server (souqmatbakh.com), see complete deployment guide:

### 📁 Deployment Assets

All production deployment configurations are in the **`deploy/`** directory:

```
deploy/
├── README.md                          # Deployment overview and guide
├── backend.env.prod.example           # Production environment variables template
├── systemd/
│   └── souqmatbakh-backend.service   # Systemd service configuration
├── nginx/
│   └── souqmatbakh.com.conf          # Nginx server configuration
└── scripts/
    ├── deploy_backend.sh             # Automated deployment script
    └── first_time_server_setup.md    # First-time server setup guide
```

### Quick Links

- **[First-Time Setup Guide](../deploy/scripts/first_time_server_setup.md)** - Complete guide for initial server configuration
- **[Deployment README](../deploy/README.md)** - Overview of deployment assets and processes
- **[Deploy Script](../deploy/scripts/deploy_backend.sh)** - Automated deployment script

### Server Information

- **Domain**: souqmatbakh.com
- **Server**: Hetzner Ubuntu (91.99.106.230)
- **Stack**: Nginx + Gunicorn + Uvicorn + PostgreSQL + SSL
- **Backend Path**: `/var/www/souqmatbakh/backend`
- **Frontend Path**: `/var/www/souqmatbakh/frontend`

### Quick Deploy (for updates)

```bash
# SSH into server
ssh root@91.99.106.230

# Navigate to backend
cd /var/www/souqmatbakh/backend

# Run deployment script
sudo -u www-data ./deploy/scripts/deploy_backend.sh
```

### Production URLs

- **Website**: https://souqmatbakh.com
- **API**: https://souqmatbakh.com/api/
- **API Docs**: https://souqmatbakh.com/api/docs

---

## �📄 الترخيص

هذا المشروع خاص بمنصة كيتشن تك.

---

**تم التطوير بواسطة**: فريق كيتشن تك  
**الإصدار**: 2.0.0  
**التاريخ**: ديسمبر 2025
