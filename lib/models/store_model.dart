// lib/models/store_model.dart

class Store {
  final String id;
  final String category;
  final String imageUrl;
  final String name;
  final double rating;
  final int reviews;
  final String username;
  final String fbPageId;
  final String fbAccessToken;

  Store({
    required this.id,
    required this.category,
    required this.imageUrl,
    required this.name,
    required this.rating,
    required this.reviews,
    required this.username,
    this.fbPageId = '',
    this.fbAccessToken = '',
  });

  Map<String, dynamic> toMap() => {
    'category': category,
    'imageUrl': imageUrl,
    'name': name,
    'rating': rating,
    'reviews': reviews,
    'username': username,
    'fbPageId': fbPageId,
    'fbAccessToken': fbAccessToken,
  };

  factory Store.fromMap(String id, Map<String, dynamic> m) => Store(
    id: id,
    category: m['category'],
    imageUrl: m['imageUrl'],
    name: m['name'],
    rating: (m['rating'] as num).toDouble(),
    reviews: m['reviews'] as int,
    username: m['username'],
    fbPageId: m['fbPageId'] ?? '',
    fbAccessToken: m['fbAccessToken'] ?? '',
  );
}
