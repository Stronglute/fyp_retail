class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String address;
  final String city;
  final String country;
  final String phoneNumber; // ← new

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.address,
    required this.city,
    required this.country,
    required this.phoneNumber, // ← new
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      phoneNumber: json['phoneNumber'] as String, // ← new
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'address': address,
      'city': city,
      'country': country,
      'phoneNumber': phoneNumber, // ← new
    };
  }
}
