class ListingModel {
  final String id;
  final String userId;
  final String listingType; // 'sell' | 'trade' | 'donate'
  final String title;
  final String description;
  final List<String> imageUrls;
  final double? price;
  final String? tradeDetails;
  final String? deviceType;
  final String? brand;
  final String? model;
  final String status; // 'active' | 'sold' | 'traded' | 'donated' | 'cancelled'
  final DateTime createdAt;

  ListingModel({
    required this.id,
    required this.userId,
    required this.listingType,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.status,
    required this.createdAt,
    this.price,
    this.tradeDetails,
    this.deviceType,
    this.brand,
    this.model,
  });

  factory ListingModel.fromMap(Map<String, dynamic> map) {
    return ListingModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      listingType: map['listing_type'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      imageUrls: (map['image_urls'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
      price: (map['price'] is num) ? (map['price'] as num).toDouble() : null,
      tradeDetails: map['trade_details'] as String?,
      deviceType: map['device_type'] as String?,
      brand: map['brand'] as String?,
      model: map['model'] as String?,
      status: map['status'] as String? ?? 'active',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'listing_type': listingType,
      'title': title,
      'description': description,
      'image_urls': imageUrls,
      'price': price,
      'trade_details': tradeDetails,
      'device_type': deviceType,
      'brand': brand,
      'model': model,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}


