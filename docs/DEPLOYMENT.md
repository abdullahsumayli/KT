# KitchenTech - GitHub Pages Deployment

هذا المجلد يحتوي على نسخة الـ Web المبنية من تطبيق KitchenTech Flutter.

## 🌐 الموقع المباشر

التطبيق متاح على:
**https://abdullahsumayli.github.io/KT/**

## 🚀 طريقة النشر

لتحديث الموقع، استخدم السكربت في جذر المشروع:

```powershell
.\deploy_web.ps1
```

بعد تشغيل السكربت، قم بـ:

```bash
git add docs
git commit -m "Update web deployment"
git push
```

## 📝 ملاحظات

- التطبيق مبني باستخدام `flutter build web --release --base-href /KT/`
- الملف `.nojekyll` مطلوب لـ GitHub Pages
- جميع ملفات الـ assets موجودة في `docs/assets/`
- الشعار موجود في `docs/assets/assets/images/logo.png`

## 🔧 إعدادات GitHub Pages

تأكد من تفعيل GitHub Pages من إعدادات المستودع:
1. اذهب إلى Settings → Pages
2. اختر Source: Deploy from a branch
3. اختر Branch: main
4. اختر Folder: /docs
5. اضغط Save

---

آخر تحديث: ديسمبر 2025
