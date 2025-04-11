class Store {
  final String id;
  final String name;
  final String category;
  final double rating;
  final int reviews;
  final String imageUrl;

  Store({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.reviews,
    required this.imageUrl,
  });

  // Convert Firestore Document to Store Model
  factory Store.fromMap(String id, Map<String, dynamic> data) {
    return Store(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      reviews: data['reviews'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  // Convert Store Model to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'rating': rating,
      'reviews': reviews,
      'imageUrl': imageUrl,
    };
  }
}

