import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

final orderServiceProvider = Provider((ref) => OrderService());

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> placeOrder(List<Product> cartItems) async {
    // Calculate the order amounts
    double subtotal = cartItems.fold(
        0, (sum, item) => sum + (item.price * item.quantity));
    double tax = subtotal * 0.08;
    double total = subtotal + tax;

    // Prepare a list of order items with detailed line totals
    final orderItems = cartItems.map((item) => {
      'id': item.id,
      'name': item.name,
      'sku': item.sku,
      'quantity': item.quantity,
      'price': item.price,
      'lineTotal': item.price * item.quantity,
    }).toList();

    // Create the order document in the 'orders' collection
    await _firestore.collection('orders').add({
      'products': orderItems,
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getOrders() {
    return _firestore
        .collection('orders')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'subtotal': data['subtotal'],
            'tax': data['tax'],
            'total': data['total'],
            'products': List<Map<String, dynamic>>.from(data['products']),
            'timestamp': data['timestamp'],
          };
        }).toList();
      },
    );
  }
}
