import 'package:cloud_firestore/cloud_firestore.dart';

class ProductRepository {
  final CollectionReference productsRef = FirebaseFirestore.instance.collection('inventory');

  Stream<List<Map<String, dynamic>>> getProductsStream() {
    return productsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    });
  }

  Future<void> addProduct(String name, String sku, String category, String imageUrl) {
    return productsRef.add({'name': name, 'sku': sku, 'category': category, 'imageUrl': imageUrl});
  }

  Future<void> updateProduct(String id, String name, String sku, String category, String imageUrl) {
    return productsRef.doc(id).update({'name': name, 'sku': sku, 'category': category, 'imageUrl': imageUrl});
  }

  Future<void> deleteProduct(String id) {
    return productsRef.doc(id).delete();
  }
}
