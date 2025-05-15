class FacebookProduct {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;

  FacebookProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
  });

  factory FacebookProduct.fromJson(Map<String, dynamic> j) => FacebookProduct(
        id: j['id'],
        name: j['name'] ?? '',
        description: j['description'] ?? '',
        imageUrl: j['image_link'] ?? '',
        price: double.tryParse(j['price']?.toString() ?? '') ?? 0.0,
      );
}
