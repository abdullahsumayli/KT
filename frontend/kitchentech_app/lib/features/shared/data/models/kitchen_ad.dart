enum KitchenType {
  modern,
  classic,
  neoClassic,
  open,
  closed,
  economic,
  luxury,
  apartment,
  villa,
}

enum KitchenAdStatus {
  pending,
  active,
  rejected,
  expired,
  paused,
}

class KitchenAd {
  final String id;
  final String title;
  final String description;
  final String advertiserId;
  final String advertiserName;
  final String city;
  final KitchenType kitchenType;
  final double priceFrom;
  final double priceTo;
  final List<String> galleryImages;
  final String? mainImage;
  final String? videoUrl;
  final double? rating;
  final int? reviewCount;
  final bool isFeatured;
  final KitchenAdStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Technical specs
  final String? material;
  final String? area;
  final int? completionDays;
  final int? warrantyYears;

  // Services
  final bool has3DDesign;
  final bool hasInstallation;
  final bool hasRemoval;
  final bool hasShipping;

  // Contact
  final String? phone;
  final String? whatsapp;

  // Stats
  final int viewCount;
  final int contactClickCount;

  const KitchenAd({
    required this.id,
    required this.title,
    required this.description,
    required this.advertiserId,
    required this.advertiserName,
    required this.city,
    required this.kitchenType,
    required this.priceFrom,
    required this.priceTo,
    this.galleryImages = const [],
    this.mainImage,
    this.videoUrl,
    this.rating,
    this.reviewCount,
    this.isFeatured = false,
    this.status = KitchenAdStatus.active,
    required this.createdAt,
    this.updatedAt,
    this.material,
    this.area,
    this.completionDays,
    this.warrantyYears,
    this.has3DDesign = false,
    this.hasInstallation = false,
    this.hasRemoval = false,
    this.hasShipping = false,
    this.phone,
    this.whatsapp,
    this.viewCount = 0,
    this.contactClickCount = 0,
  });

  KitchenAd copyWith({
    String? id,
    String? title,
    String? description,
    String? advertiserId,
    String? advertiserName,
    String? city,
    KitchenType? kitchenType,
    double? priceFrom,
    double? priceTo,
    List<String>? galleryImages,
    String? mainImage,
    String? videoUrl,
    double? rating,
    int? reviewCount,
    bool? isFeatured,
    KitchenAdStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? material,
    String? area,
    int? completionDays,
    int? warrantyYears,
    bool? has3DDesign,
    bool? hasInstallation,
    bool? hasRemoval,
    bool? hasShipping,
    String? phone,
    String? whatsapp,
    int? viewCount,
    int? contactClickCount,
  }) {
    return KitchenAd(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      advertiserId: advertiserId ?? this.advertiserId,
      advertiserName: advertiserName ?? this.advertiserName,
      city: city ?? this.city,
      kitchenType: kitchenType ?? this.kitchenType,
      priceFrom: priceFrom ?? this.priceFrom,
      priceTo: priceTo ?? this.priceTo,
      galleryImages: galleryImages ?? this.galleryImages,
      mainImage: mainImage ?? this.mainImage,
      videoUrl: videoUrl ?? this.videoUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isFeatured: isFeatured ?? this.isFeatured,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      material: material ?? this.material,
      area: area ?? this.area,
      completionDays: completionDays ?? this.completionDays,
      warrantyYears: warrantyYears ?? this.warrantyYears,
      has3DDesign: has3DDesign ?? this.has3DDesign,
      hasInstallation: hasInstallation ?? this.hasInstallation,
      hasRemoval: hasRemoval ?? this.hasRemoval,
      hasShipping: hasShipping ?? this.hasShipping,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      viewCount: viewCount ?? this.viewCount,
      contactClickCount: contactClickCount ?? this.contactClickCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'advertiserId': advertiserId,
      'advertiserName': advertiserName,
      'city': city,
      'kitchenType': kitchenType.name,
      'priceFrom': priceFrom,
      'priceTo': priceTo,
      'galleryImages': galleryImages,
      'mainImage': mainImage,
      'videoUrl': videoUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'isFeatured': isFeatured,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'material': material,
      'area': area,
      'completionDays': completionDays,
      'warrantyYears': warrantyYears,
      'has3DDesign': has3DDesign,
      'hasInstallation': hasInstallation,
      'hasRemoval': hasRemoval,
      'hasShipping': hasShipping,
      'phone': phone,
      'whatsapp': whatsapp,
      'viewCount': viewCount,
      'contactClickCount': contactClickCount,
    };
  }

  factory KitchenAd.fromJson(Map<String, dynamic> json) {
    return KitchenAd(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      advertiserId: json['advertiserId'] as String,
      advertiserName: json['advertiserName'] as String,
      city: json['city'] as String,
      kitchenType: KitchenType.values.firstWhere(
        (e) => e.name == json['kitchenType'],
        orElse: () => KitchenType.modern,
      ),
      priceFrom: (json['priceFrom'] as num).toDouble(),
      priceTo: (json['priceTo'] as num).toDouble(),
      galleryImages:
          (json['galleryImages'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      mainImage: json['mainImage'] as String?,
      videoUrl: json['videoUrl'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['reviewCount'] as int?,
      isFeatured: json['isFeatured'] as bool? ?? false,
      status: KitchenAdStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => KitchenAdStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      material: json['material'] as String?,
      area: json['area'] as String?,
      completionDays: json['completionDays'] as int?,
      warrantyYears: json['warrantyYears'] as int?,
      has3DDesign: json['has3DDesign'] as bool? ?? false,
      hasInstallation: json['hasInstallation'] as bool? ?? false,
      hasRemoval: json['hasRemoval'] as bool? ?? false,
      hasShipping: json['hasShipping'] as bool? ?? false,
      phone: json['phone'] as String?,
      whatsapp: json['whatsapp'] as String?,
      viewCount: json['viewCount'] as int? ?? 0,
      contactClickCount: json['contactClickCount'] as int? ?? 0,
    );
  }
}
