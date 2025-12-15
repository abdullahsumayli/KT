#!/usr/bin/env python3
"""
اختبار API طلبات عروض الأسعار
يختبر الاتصال المباشر بـ https://souqmatbakh.com/api/v1/quotes/
"""

import requests
import json
from datetime import datetime

API_URL = "https://souqmatbakh.com/api/v1/quotes/"

def test_quote_request():
    """اختبار إرسال طلب عرض سعر"""
    
    print("=" * 60)
    print("🧪 اختبار API طلبات عروض الأسعار")
    print("=" * 60)
    print(f"📡 URL: {API_URL}")
    print(f"🕐 الوقت: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()
    
    # بيانات الطلب
    test_data = {
        "style": "modern",
        "city": "riyadh",
        "phone": "0512345678"  # رقم تجريبي
    }
    
    print("📤 البيانات المرسلة:")
    print(json.dumps(test_data, indent=2, ensure_ascii=False))
    print()
    
    try:
        # إرسال الطلب
        print("🚀 إرسال الطلب...")
        response = requests.post(
            API_URL,
            json=test_data,
            headers={
                "Content-Type": "application/json",
                "Accept": "application/json",
            },
            timeout=10
        )
        
        print(f"📥 رمز الاستجابة: {response.status_code}")
        print()
        
        # طباعة headers
        print("📋 Response Headers:")
        for key, value in response.headers.items():
            if key.lower() in ['content-type', 'x-ratelimit', 'content-length']:
                print(f"  {key}: {value}")
        print()
        
        # محاولة parse الاستجابة
        try:
            response_json = response.json()
            print("✅ الاستجابة (JSON):")
            print(json.dumps(response_json, indent=2, ensure_ascii=False))
        except:
            print("⚠️  الاستجابة (Text):")
            print(response.text[:500])  # أول 500 حرف فقط
        
        print()
        
        # تحليل النتيجة
        if response.status_code == 201:
            print("✅ نجح! تم إنشاء طلب العرض")
        elif response.status_code == 401:
            print("❌ خطأ 401: غير مصادق (Not Authenticated)")
            print("   💡 المشكلة: الـ endpoint يطلب token لكنه يجب أن يكون عام")
        elif response.status_code == 403:
            print("❌ خطأ 403: ممنوع (Forbidden)")
            print("   💡 المشكلة: لا يوجد صلاحيات كافية")
        elif response.status_code == 409:
            print("⚠️  خطأ 409: طلب مكرر")
            print("   💡 تم إرسال طلب من هذا الرقم خلال آخر 24 ساعة")
        elif response.status_code == 429:
            print("⚠️  خطأ 429: تجاوز حد الطلبات")
            print("   💡 انتظر دقيقة ثم حاول مرة أخرى")
        elif response.status_code >= 500:
            print(f"❌ خطأ في السيرفر ({response.status_code})")
        else:
            print(f"⚠️  استجابة غير متوقعة ({response.status_code})")
        
    except requests.exceptions.Timeout:
        print("❌ انتهى وقت الطلب (Timeout)")
    except requests.exceptions.ConnectionError:
        print("❌ فشل الاتصال بالسيرفر")
    except Exception as e:
        print(f"❌ خطأ غير متوقع: {e}")
    
    print()
    print("=" * 60)


def test_health_check():
    """اختبار health check"""
    print("\n🏥 اختبار Health Check...")
    try:
        response = requests.get("https://souqmatbakh.com/health", timeout=5)
        if response.status_code == 200:
            print(f"✅ السيرفر يعمل: {response.json()}")
        else:
            print(f"⚠️  رمز الاستجابة: {response.status_code}")
    except Exception as e:
        print(f"❌ فشل: {e}")


if __name__ == "__main__":
    # اختبار health check أولاً
    test_health_check()
    print()
    
    # اختبار API الرئيسي
    test_quote_request()
    
    print("\n💡 نصائح التشخيص:")
    print("  1. إذا كانت المشكلة 401/403: تحقق من إعدادات FastAPI routes")
    print("  2. إذا كان السيرفر لا يستجيب: تحقق من أن Backend يعمل")
    print("  3. إذا كان 409: الرقم مستخدم مسبقاً، غيّر الرقم في الكود")
    print("  4. تحقق من logs السيرفر: sudo journalctl -u souqmatbakh-backend -f")
