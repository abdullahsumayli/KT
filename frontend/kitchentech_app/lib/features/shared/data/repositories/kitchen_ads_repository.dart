import '../models/kitchen_ad.dart';

class KitchenAdsRepository {
  Future<List<KitchenAd>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockKitchenAdsRepository.all;
  }

  Future<KitchenAd?> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockKitchenAdsRepository.all.firstWhere((ad) => ad.id == id);
  }

  Future<List<KitchenAd>> getByAdvertiser(String advertiserId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockKitchenAdsRepository.all.where((ad) => ad.advertiserId == advertiserId).toList();
  }

  Future<List<KitchenAd>> search({
    String? query,
    String? city,
    KitchenType? kitchenType,
    double? minPrice,
    double? maxPrice,
    double? minRating,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    var results = MockKitchenAdsRepository.all;

    if (query != null && query.isNotEmpty) {
      results = results
          .where((ad) =>
              ad.title.toLowerCase().contains(query.toLowerCase()) ||
              ad.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    if (city != null && city.isNotEmpty) {
      results = results.where((ad) => ad.city == city).toList();
    }

    if (kitchenType != null) {
      results = results.where((ad) => ad.kitchenType == kitchenType).toList();
    }

    if (minPrice != null) {
      results = results.where((ad) => ad.priceFrom >= minPrice).toList();
    }

    if (maxPrice != null) {
      results = results.where((ad) => ad.priceTo <= maxPrice).toList();
    }

    if (minRating != null) {
      results = results.where((ad) => (ad.rating ?? 0) >= minRating).toList();
    }

    return results;
  }

  Future<List<KitchenAd>> getFeatured() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockKitchenAdsRepository.all.where((ad) => ad.isFeatured).toList();
  }

  Future<void> incrementViews(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // In a real app, this would update the backend
  }

  Future<void> incrementContactClicks(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // In a real app, this would update the backend
  }

  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // In a real app, this would delete from backend
    MockKitchenAdsRepository.all.removeWhere((ad) => ad.id == id);
  }
}

class MockKitchenAdsRepository extends KitchenAdsRepository {
  static final all = [
    KitchenAd(
      id: '1',
      title: 'مطبخ إيطالي فاخر',
      description: 'مطبخ إيطالي فاخر بتصميم عصري، مصنوع من خشب طبيعي عالي الجودة',
      advertiserId: 'adv1',
      advertiserName: 'الأناقة للمطابخ',
      city: 'الرياض',
      kitchenType: KitchenType.luxury,
      priceFrom: 45000,
      priceTo: 65000,
      galleryImages: [
        'https://images.unsplash.com/photo-1556911220-bff31c812dba?w=800',
        'https://images.unsplash.com/photo-1556909212-d5b604d0c90d?w=800',
        'https://images.unsplash.com/photo-1556912172-45b7abe8b7e1?w=800',
      ],
      mainImage: 'https://images.unsplash.com/photo-1556911220-bff31c812dba?w=800',
      rating: 4.8,
      reviewCount: 24,
      isFeatured: true,
      status: KitchenAdStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      material: 'خشب طبيعي',
      area: '12-15 متر مربع',
      completionDays: 30,
      warrantyYears: 5,
      has3DDesign: true,
      hasInstallation: true,
      hasShipping: true,
      phone: '0501234567',
      whatsapp: '966501234567',
      viewCount: 245,
      contactClickCount: 18,
    ),
    KitchenAd(
      id: '2',
      title: 'مطبخ مودرن اقتصادي',
      description: 'مطبخ عصري بأسعار منافسة، مناسب للشقق الصغيرة',
      advertiserId: 'adv2',
      advertiserName: 'مطابخ الخليج',
      city: 'جدة',
      kitchenType: KitchenType.modern,
      priceFrom: 18000,
      priceTo: 28000,
      galleryImages: [
        'https://images.unsplash.com/photo-1556912172-45b7abe8b7e1?w=800',
        'https://images.unsplash.com/photo-1556911220-bff31c812dba?w=800',
      ],
      mainImage: 'https://images.unsplash.com/photo-1556912172-45b7abe8b7e1?w=800',
      rating: 4.5,
      reviewCount: 15,
      isFeatured: true,
      status: KitchenAdStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      material: 'MDF',
      area: '8-10 متر مربع',
      completionDays: 20,
      warrantyYears: 2,
      has3DDesign: true,
      hasInstallation: true,
      phone: '0507654321',
      whatsapp: '966507654321',
      viewCount: 189,
      contactClickCount: 12,
    ),
    KitchenAd(
      id: '3',
      title: 'مطبخ كلاسيكي راقي',
      description: 'مطبخ كلاسيكي بلمسات ذهبية وتفاصيل منحوتة',
      advertiserId: 'adv1',
      advertiserName: 'الأناقة للمطابخ',
      city: 'الدمام',
      kitchenType: KitchenType.classic,
      priceFrom: 52000,
      priceTo: 75000,
      galleryImages: [
        'https://images.unsplash.com/photo-1556909212-d5b604d0c90d?w=800',
        'https://images.unsplash.com/photo-1556911220-bff31c812dba?w=800',
      ],
      mainImage: 'https://images.unsplash.com/photo-1556909212-d5b604d0c90d?w=800',
      rating: 4.9,
      reviewCount: 31,
      isFeatured: true,
      status: KitchenAdStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      material: 'خشب طبيعي + ألمنيوم',
      area: '15-20 متر مربع',
      completionDays: 45,
      warrantyYears: 7,
      has3DDesign: true,
      hasInstallation: true,
      hasRemoval: true,
      hasShipping: true,
      phone: '0509876543',
      whatsapp: '966509876543',
      viewCount: 312,
      contactClickCount: 25,
    ),
    KitchenAd(
      id: '4',
      title: 'مطبخ مفتوح على الصالة',
      description: 'تصميم مفتوح مع جزيرة عصرية، مثالي للفلل الكبيرة',
      advertiserId: 'adv3',
      advertiserName: 'التميز للمطابخ',
      city: 'الرياض',
      kitchenType: KitchenType.open,
      priceFrom: 60000,
      priceTo: 85000,
      galleryImages: [
        'https://images.unsplash.com/photo-1556911220-bff31c812dba?w=800',
      ],
      mainImage: 'https://images.unsplash.com/photo-1556911220-bff31c812dba?w=800',
      rating: 4.7,
      reviewCount: 19,
      isFeatured: false,
      status: KitchenAdStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      material: 'MDF + رخام',
      area: '20+ متر مربع',
      completionDays: 40,
      warrantyYears: 5,
      has3DDesign: true,
      hasInstallation: true,
      hasShipping: true,
      phone: '0505556666',
      whatsapp: '966505556666',
      viewCount: 178,
      contactClickCount: 14,
    ),
    KitchenAd(
      id: '5',
      title: 'مطبخ شقة صغيرة',
      description: 'حل ذكي للمساحات الصغيرة مع تخزين عملي',
      advertiserId: 'adv2',
      advertiserName: 'مطابخ الخليج',
      city: 'جدة',
      kitchenType: KitchenType.apartment,
      priceFrom: 15000,
      priceTo: 22000,
      galleryImages: [
        'https://images.unsplash.com/photo-1556912172-45b7abe8b7e1?w=800',
      ],
      mainImage: 'https://images.unsplash.com/photo-1556912172-45b7abe8b7e1?w=800',
      rating: 4.4,
      reviewCount: 11,
      isFeatured: false,
      status: KitchenAdStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      material: 'MDF',
      area: '5-8 متر مربع',
      completionDays: 15,
      warrantyYears: 2,
      has3DDesign: false,
      hasInstallation: true,
      phone: '0507654321',
      whatsapp: '966507654321',
      viewCount: 145,
      contactClickCount: 9,
    ),
  ];
}
