class Listing {
  final int? id;
  final String title;
  final String? description;
  final String address;
  final String city;
  final String? state;
  final String? zipCode;
  final double pricePerHour;
  final double? pricePerDay;
  final String? kitchenType;
  final int? squareFootage;
  final String? equipment;
  final bool isAvailable;
  final DateTime? availableFrom;
  final DateTime? availableTo;
  final int? ownerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? aiGeneratedDescription;
  final double? aiSuggestedPrice;

  Listing({
    this.id,
    required this.title,
    this.description,
    required this.address,
    required this.city,
    this.state,
    this.zipCode,
    required this.pricePerHour,
    this.pricePerDay,
    this.kitchenType,
    this.squareFootage,
    this.equipment,
    this.isAvailable = true,
    this.availableFrom,
    this.availableTo,
    this.ownerId,
    this.createdAt,
    this.updatedAt,
    this.aiGeneratedDescription,
    this.aiSuggestedPrice,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zip_code'],
      pricePerHour: json['price_per_hour'].toDouble(),
      pricePerDay: json['price_per_day']?.toDouble(),
      kitchenType: json['kitchen_type'],
      squareFootage: json['square_footage'],
      equipment: json['equipment'],
      isAvailable: json['is_available'] ?? true,
      availableFrom: json['available_from'] != null ? DateTime.parse(json['available_from']) : null,
      availableTo: json['available_to'] != null ? DateTime.parse(json['available_to']) : null,
      ownerId: json['owner_id'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      aiGeneratedDescription: json['ai_generated_description'],
      aiSuggestedPrice: json['ai_suggested_price']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'address': address,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'price_per_hour': pricePerHour,
      'price_per_day': pricePerDay,
      'kitchen_type': kitchenType,
      'square_footage': squareFootage,
      'equipment': equipment,
      'is_available': isAvailable,
      'available_from': availableFrom?.toIso8601String(),
      'available_to': availableTo?.toIso8601String(),
    };
  }
}
