class Product {
  final String id;
  final String name;
  final String sku;
  final String category;
  final double basePrice; // Renamed from price to basePrice
  final double? negotiatedPrice; // New field for negotiated price
  final int stock;
  final String username;
  final String storename;
  final String imageUrl;
  final int quantity; // Cart quantity
  final bool isNegotiable; // New field to indicate if price is negotiable

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.basePrice,
    this.negotiatedPrice,
    this.storename = '',
    required this.stock,
    required this.username,
    required this.imageUrl,
    this.quantity = 1,
    this.isNegotiable = false, // Default to false
  });

  // Computed property to get the effective price (negotiated or base)
  double get price => negotiatedPrice ?? basePrice;

  // Convert Firestore Document to Product Model
  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      sku: data['sku'] ?? '',
      category: data['category'] ?? '',
      basePrice:
          (data['basePrice'] ?? data['price'] ?? 0.0)
              .toDouble(), // Handle both old and new field names
      negotiatedPrice:
          data['negotiatedPrice'] != null
              ? (data['negotiatedPrice'] as num).toDouble()
              : null,
      stock: data['stock'] ?? 0,
      username: data['username'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      quantity: data['quantity'] ?? 1,
      storename: data['storename'] ?? '',
      isNegotiable: data['isNegotiable'] ?? false,
    );
  }

  String get image => imageUrl;

  String get description => '';

  // Convert Product Model to Firestore Document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sku': sku,
      'category': category,
      'basePrice': basePrice,
      'negotiatedPrice': negotiatedPrice,
      'stock': stock,
      'username': username,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'storename': storename,
      'isNegotiable': isNegotiable,
    };
  }

  // copyWith method to update fields including negotiated price
  Product copyWith({
    String? id,
    String? name,
    String? sku,
    String? category,
    double? basePrice,
    double? negotiatedPrice,
    bool clearNegotiatedPrice = false, // Special flag to clear negotiated price
    int? stock,
    String? username,
    String? imageUrl,
    int? quantity,
    bool? isNegotiable,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      basePrice: basePrice ?? this.basePrice,
      negotiatedPrice:
          clearNegotiatedPrice
              ? null
              : (negotiatedPrice ?? this.negotiatedPrice),
      stock: stock ?? this.stock,
      username: username ?? this.username,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      isNegotiable: isNegotiable ?? this.isNegotiable,
    );
  }

  // Helper method to create a copy with a negotiated price
  Product copyWithNegotiatedPrice(double newPrice) {
    return copyWith(negotiatedPrice: newPrice);
  }
}
