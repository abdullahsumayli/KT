enum AdvertiserType {
  company,
  workshop,
  freelancer,
}

class Advertiser {
  final String id;
  final String companyName;
  final AdvertiserType type;
  final String city;
  final String? commercialRegistration;
  final String email;
  final String phone;
  final String? website;
  final String? instagram;
  final String? logo;
  final String? bio;
  final double? rating;
  final int totalAds;
  final int activeAds;
  final DateTime joinedAt;
  final bool isVerified;
  final String? currentPlanId;

  const Advertiser({
    required this.id,
    required this.companyName,
    required this.type,
    required this.city,
    this.commercialRegistration,
    required this.email,
    required this.phone,
    this.website,
    this.instagram,
    this.logo,
    this.bio,
    this.rating,
    this.totalAds = 0,
    this.activeAds = 0,
    required this.joinedAt,
    this.isVerified = false,
    this.currentPlanId,
  });

  Advertiser copyWith({
    String? id,
    String? companyName,
    AdvertiserType? type,
    String? city,
    String? commercialRegistration,
    String? email,
    String? phone,
    String? website,
    String? instagram,
    String? logo,
    String? bio,
    double? rating,
    int? totalAds,
    int? activeAds,
    DateTime? joinedAt,
    bool? isVerified,
    String? currentPlanId,
  }) {
    return Advertiser(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      type: type ?? this.type,
      city: city ?? this.city,
      commercialRegistration: commercialRegistration ?? this.commercialRegistration,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      instagram: instagram ?? this.instagram,
      logo: logo ?? this.logo,
      bio: bio ?? this.bio,
      rating: rating ?? this.rating,
      totalAds: totalAds ?? this.totalAds,
      activeAds: activeAds ?? this.activeAds,
      joinedAt: joinedAt ?? this.joinedAt,
      isVerified: isVerified ?? this.isVerified,
      currentPlanId: currentPlanId ?? this.currentPlanId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'type': type.name,
      'city': city,
      'commercialRegistration': commercialRegistration,
      'email': email,
      'phone': phone,
      'website': website,
      'instagram': instagram,
      'logo': logo,
      'bio': bio,
      'rating': rating,
      'totalAds': totalAds,
      'activeAds': activeAds,
      'joinedAt': joinedAt.toIso8601String(),
      'isVerified': isVerified,
      'currentPlanId': currentPlanId,
    };
  }

  factory Advertiser.fromJson(Map<String, dynamic> json) {
    return Advertiser(
      id: json['id'] as String,
      companyName: json['companyName'] as String,
      type: AdvertiserType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AdvertiserType.company,
      ),
      city: json['city'] as String,
      commercialRegistration: json['commercialRegistration'] as String?,
      email: json['email'] as String,
      phone: json['phone'] as String,
      website: json['website'] as String?,
      instagram: json['instagram'] as String?,
      logo: json['logo'] as String?,
      bio: json['bio'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      totalAds: json['totalAds'] as int? ?? 0,
      activeAds: json['activeAds'] as int? ?? 0,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      isVerified: json['isVerified'] as bool? ?? false,
      currentPlanId: json['currentPlanId'] as String?,
    );
  }
}
