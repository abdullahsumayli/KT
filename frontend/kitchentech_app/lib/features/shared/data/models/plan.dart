class Plan {
  final String id;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final double monthlyPrice;
  final int maxAds;
  final int featuredSlots;
  final bool priorityRanking;
  final bool support247;
  final bool analytics;
  final bool customBranding;
  final List<String> features;
  final bool isPopular;

  const Plan({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.monthlyPrice,
    required this.maxAds,
    this.featuredSlots = 0,
    this.priorityRanking = false,
    this.support247 = false,
    this.analytics = false,
    this.customBranding = false,
    this.features = const [],
    this.isPopular = false,
  });

  Plan copyWith({
    String? id,
    String? nameAr,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    double? monthlyPrice,
    int? maxAds,
    int? featuredSlots,
    bool? priorityRanking,
    bool? support247,
    bool? analytics,
    bool? customBranding,
    List<String>? features,
    bool? isPopular,
  }) {
    return Plan(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      maxAds: maxAds ?? this.maxAds,
      featuredSlots: featuredSlots ?? this.featuredSlots,
      priorityRanking: priorityRanking ?? this.priorityRanking,
      support247: support247 ?? this.support247,
      analytics: analytics ?? this.analytics,
      customBranding: customBranding ?? this.customBranding,
      features: features ?? this.features,
      isPopular: isPopular ?? this.isPopular,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'monthlyPrice': monthlyPrice,
      'maxAds': maxAds,
      'featuredSlots': featuredSlots,
      'priorityRanking': priorityRanking,
      'support247': support247,
      'analytics': analytics,
      'customBranding': customBranding,
      'features': features,
      'isPopular': isPopular,
    };
  }

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] as String,
      nameAr: json['nameAr'] as String,
      nameEn: json['nameEn'] as String,
      descriptionAr: json['descriptionAr'] as String,
      descriptionEn: json['descriptionEn'] as String,
      monthlyPrice: (json['monthlyPrice'] as num).toDouble(),
      maxAds: json['maxAds'] as int,
      featuredSlots: json['featuredSlots'] as int? ?? 0,
      priorityRanking: json['priorityRanking'] as bool? ?? false,
      support247: json['support247'] as bool? ?? false,
      analytics: json['analytics'] as bool? ?? false,
      customBranding: json['customBranding'] as bool? ?? false,
      features: (json['features'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      isPopular: json['isPopular'] as bool? ?? false,
    );
  }
}

// Mock Plans Data
class MockPlans {
  static const free = Plan(
    id: 'free',
    nameAr: 'مجاني',
    nameEn: 'Free',
    descriptionAr: 'مثالي للبدء',
    descriptionEn: 'Perfect to get started',
    monthlyPrice: 0,
    maxAds: 2,
    features: [
      'حتى 2 إعلانات',
      'دعم فني أساسي',
      'عرض في نتائج البحث',
    ],
  );

  static const basic = Plan(
    id: 'basic',
    nameAr: 'أساسي',
    nameEn: 'Basic',
    descriptionAr: 'للشركات الناشئة',
    descriptionEn: 'For startups',
    monthlyPrice: 299,
    maxAds: 10,
    featuredSlots: 2,
    features: [
      'حتى 10 إعلانات',
      'إبراز 2 إعلانات',
      'دعم فني عبر البريد',
      'إحصائيات أساسية',
    ],
  );

  static const pro = Plan(
    id: 'pro',
    nameAr: 'احترافي',
    nameEn: 'Professional',
    descriptionAr: 'الأكثر شعبية',
    descriptionEn: 'Most popular',
    monthlyPrice: 599,
    maxAds: 30,
    featuredSlots: 5,
    priorityRanking: true,
    analytics: true,
    isPopular: true,
    features: [
      'حتى 30 إعلان',
      'إبراز 5 إعلانات',
      'أولوية في نتائج البحث',
      'إحصائيات متقدمة',
      'دعم فني ذو أولوية',
      'شارة "موثق"',
    ],
  );

  static List<Plan> get all => [free, basic, pro];
}
