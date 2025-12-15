from PIL import Image
from collections import Counter
import colorsys

def get_dominant_colors(image_path, num_colors=5):
    # فتح الصورة
    img = Image.open(image_path)
    
    # تحويلها إلى RGB إذا كانت RGBA
    if img.mode == 'RGBA':
        img = img.convert('RGB')
    
    # تصغير الصورة للمعالجة الأسرع
    img = img.resize((150, 150))
    
    # الحصول على جميع الألوان
    pixels = list(img.getdata())
    
    # تجاهل الألوان البيضاء والقريبة من الأبيض والشفافة
    filtered_pixels = []
    for pixel in pixels:
        r, g, b = pixel
        # تجاهل الألوان الفاتحة جداً (البيضاء والرمادية الفاتحة)
        if not (r > 240 and g > 240 and b > 240):
            filtered_pixels.append(pixel)
    
    # حساب الألوان الأكثر شيوعاً
    pixel_counter = Counter(filtered_pixels)
    most_common = pixel_counter.most_common(num_colors)
    
    print(f"\n🎨 الألوان الأساسية في الشعار:\n")
    print("=" * 60)
    
    for i, (color, count) in enumerate(most_common, 1):
        r, g, b = color
        hex_color = f"#{r:02X}{g:02X}{b:02X}"
        percentage = (count / len(filtered_pixels)) * 100
        
        # تحديد نوع اللون
        h, s, v = colorsys.rgb_to_hsv(r/255, g/255, b/255)
        
        color_name = ""
        if s < 0.1:  # ألوان رمادية
            if v > 0.8:
                color_name = "أبيض/فاتح جداً"
            elif v > 0.5:
                color_name = "رمادي فاتح"
            elif v > 0.3:
                color_name = "رمادي"
            else:
                color_name = "رمادي غامق/أسود"
        else:  # ألوان ملونة
            if h < 0.05 or h > 0.95:
                color_name = "أحمر"
            elif h < 0.15:
                color_name = "برتقالي/بني"
            elif h < 0.20:
                color_name = "ذهبي/أصفر"
            elif h < 0.45:
                color_name = "أخضر"
            elif h < 0.65:
                color_name = "أزرق/سماوي"
            elif h < 0.75:
                color_name = "بنفسجي"
            else:
                color_name = "وردي/أحمر"
                
            # إضافة درجة اللون
            if v < 0.3:
                color_name += " غامق جداً"
            elif v < 0.5:
                color_name += " غامق"
            elif v > 0.8 and s < 0.5:
                color_name += " فاتح"
        
        print(f"{i}. {color_name}")
        print(f"   RGB: ({r}, {g}, {b})")
        print(f"   Hex: {hex_color}")
        print(f"   النسبة: {percentage:.1f}%")
        print()

# تحليل الشعار
logo_path = r"d:\KT\frontend\kitchentech_app\assets\images\logo.png"
get_dominant_colors(logo_path, num_colors=8)
