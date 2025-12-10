class KitchenListing {
  final String id;
  final String title;
  final String description;
  final double price;
  final String city;
  final String status; // active / inactive
  final String type; // new / used / ready / custom
  final String material; // wood / aluminum / mixed / unknown
  final double? lengthM;
  final double? widthM;
  final double? heightM;
  final bool isFeatured;
  final DateTime createdAt;

  const KitchenListing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.city,
    required this.status,
    required this.type,
    required this.material,
    this.lengthM,
    this.widthM,
    this.heightM,
    required this.isFeatured,
    required this.createdAt,
  });

  factory KitchenListing.fromJson(Map<String, dynamic> json) {
    return KitchenListing(
      id: json['id'].toString(),
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      city: json['city'] as String,
      status: json['status'] as String? ?? 'active',
      type: json['type'] as String? ?? 'unknown',
      material: json['material'] as String? ?? 'unknown',
      lengthM: json['length_m'] != null ? (json['length_m'] as num).toDouble() : null,
      widthM: json['width_m'] != null ? (json['width_m'] as num).toDouble() : null,
      heightM: json['height_m'] != null ? (json['height_m'] as num).toDouble() : null,
      isFeatured: json['is_featured'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'city': city,
      'status': status,
      'type': type,
      'material': material,
      'length_m': lengthM,
      'width_m': widthM,
      'height_m': heightM,
      'is_featured': isFeatured,
      'created_at': createdAt.toIso8601String(),
    };
  }

  KitchenListing copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? city,
    String? status,
    String? type,
    String? material,
    double? lengthM,
    double? widthM,
    double? heightM,
    bool? isFeatured,
    DateTime? createdAt,
  }) {
    return KitchenListing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      city: city ?? this.city,
      status: status ?? this.status,
      type: type ?? this.type,
      material: material ?? this.material,
      lengthM: lengthM ?? this.lengthM,
      widthM: widthM ?? this.widthM,
      heightM: heightM ?? this.heightM,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
