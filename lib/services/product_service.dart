import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch All Products from Firestore
  Stream<List<Product>> getProducts() {
    return _firestore.collection('inventory').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  /// Stream a single product document by its ID
  Stream<Product> getProductById(String productId) {
    return _firestore
        .collection('inventory')
        .doc(productId)
        .snapshots()
        .where((snapshot) => snapshot.exists)
        .map((doc) => Product.fromMap(doc.id, doc.data()!));
  }

  Stream<List<Product>> getProductsByStore(String storeName) {
    return _firestore
        .collection('inventory')
        .where('storename', isEqualTo: storeName)
        .snapshots()
        .asyncMap((snapshot) async {
          return snapshot.docs
              .map((doc) => Product.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  // Add New Product to Firestore
  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').add(product.toMap());
  }
}
