/// Kitchen categories for the marketplace
class KitchenCategories {
  static const List<Category> all = [
    Category(
      id: 'modern',
      nameAr: 'مودرن',
      icon: 'kitchen',
    ),
    Category(
      id: 'classic',
      nameAr: 'كلاسيك',
      icon: 'chair',
    ),
    Category(
      id: 'budget',
      nameAr: 'مطابخ اقتصادية',
      icon: 'attach_money',
    ),
    Category(
      id: 'luxury',
      nameAr: 'مطابخ فاخرة',
      icon: 'diamond',
    ),
    Category(
      id: 'apartment',
      nameAr: 'مطابخ شقق',
      icon: 'apartment',
    ),
    Category(
      id: 'villa',
      nameAr: 'مطابخ فلل',
      icon: 'villa',
    ),
    Category(
      id: 'appliances',
      nameAr: 'أجهزة وإكسسوارات',
      icon: 'kitchen_outlined',
    ),
  ];

  // Simple list of category names for filters
  static List<String> get names => all.map((c) => c.nameAr).toList();
}

class Category {
  final String id;
  final String nameAr;
  final String icon;

  const Category({
    required this.id,
    required this.nameAr,
    required this.icon,
  });
}

/// Saudi cities
class SaudiCities {
  static const List<String> all = [
    'الرياض',
    'جدة',
    'مكة',
    'المدينة المنورة',
    'الدمام',
    'الخبر',
    'الظهران',
    'الطائف',
    'أبها',
    'تبوك',
    'بريدة',
    'خميس مشيط',
    'حائل',
    'نجران',
    'الجبيل',
    'الخرج',
    'ينبع',
    'الأحساء',
    'عرعر',
    'سكاكا',
  ];

  // Major cities for filters
  static const List<String> major = [
    'الرياض',
    'جدة',
    'الدمام',
    'مكة',
    'المدينة المنورة',
    'الخبر',
    'الطائف',
    'تبوك',
  ];
}

/// Kitchen materials
class KitchenMaterials {
  static const List<String> all = [
    'MDF',
    'خشب طبيعي',
    'ألمنيوم',
    'رخام',
    'جرانيت',
    'كوارتز',
    'أكريليك',
    'لامينيت',
    'مزيج',
  ];
}

/// Quality levels
class QualityLevels {
  static const List<String> all = [
    'اقتصادي',
    'متوسط',
    'فاخر',
    'فاخر جداً',
  ];
}

/// Services offered
class KitchenServices {
  static const List<String> all = [
    'تصميم ثلاثي الأبعاد',
    'إزالة المطبخ القديم',
    'تركيب',
    'شحن وتوصيل',
    'صيانة',
    'ضمان',
    'استشارة مجانية',
  ];
}

/// Budget ranges
class BudgetRanges {
  static const List<Map<String, String>> all = [
    {
      'label': 'أقل من 20,000 ريال',
      'value': '0-20000',
    },
    {
      'label': '20,000 - 40,000 ريال',
      'value': '20000-40000',
    },
    {
      'label': '40,000 - 70,000 ريال',
      'value': '40000-70000',
    },
    {
      'label': 'أكثر من 70,000 ريال',
      'value': '70000-999999',
    },
  ];

  // Legacy support
  static const List<BudgetRange> ranges = [
    BudgetRange(
      label: 'أقل من 20,000 ريال',
      min: 0,
      max: 20000,
    ),
    BudgetRange(
      label: '20,000 - 40,000 ريال',
      min: 20000,
      max: 40000,
    ),
    BudgetRange(
      label: '40,000 - 70,000 ريال',
      min: 40000,
      max: 70000,
    ),
    BudgetRange(
      label: 'أكثر من 70,000 ريال',
      min: 70000,
      max: double.infinity,
    ),
  ];
}

class BudgetRange {
  final String label;
  final double min;
  final double max;

  const BudgetRange({
    required this.label,
    required this.min,
    required this.max,
  });
}
