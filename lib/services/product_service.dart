import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch All Products from Firestore
  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromMap(doc.id, doc.data())).toList();
    });
  }

  // Add New Product to Firestore
  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').add(product.toMap());
  }
}
