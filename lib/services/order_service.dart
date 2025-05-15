import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../services/jazzcash_payment_service.dart';
import '../providers/payment_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final orderServiceProvider = Provider((ref) {
  final paymentService = ref.read(jazzCashServiceProvider);
  return OrderService(paymentService);
});

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final JazzCashPaymentService _paymentService;

  // Add public getter
  FirebaseFirestore get firestore => _firestore;

  OrderService(this._paymentService);

  Future<void> _addDeliveryInfo(String orderId, String deliveryPersonId) async {
    final estimatedTime = DateTime.now().add(const Duration(hours: 2));

    await _firestore.collection('orders').doc(orderId).update({
      'deliveryPersonId': deliveryPersonId,
      'estimatedDeliveryTime': estimatedTime,
      'status': 'preparing',
    });
  }

  /// Get delivery person info
  Future<Map<String, dynamic>> getDeliveryPersonInfo(
    String deliveryPersonId,
  ) async {
    final doc =
        await _firestore
            .collection('deliveryPersons')
            .doc(deliveryPersonId)
            .get();
    return doc.data() ?? {};
  }

  /// Get live location of delivery person
  Stream<Position> getDeliveryPersonLocation(String deliveryPersonId) {
    return _firestore
        .collection('deliveryPersonLocations')
        .doc(deliveryPersonId)
        .snapshots()
        .map((snapshot) {
          final data = snapshot.data();
          return Position(
            latitude: data?['latitude'] ?? 0,
            longitude: data?['longitude'] ?? 0,
            timestamp: DateTime.now(),
            altitudeAccuracy: 0.2,
            headingAccuracy: 0.2,
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
          );
        });
  }

  /// Checkout flow supporting both card and cash-on-delivery
  Future<void> checkout(
    List<Product> cartItems, {
    required String userId,
    required String userEmail,
    required String paymentMethod, // 'card' or 'cash_on_delivery'
    String? cardNumber,
    String? cardExpiry,
    String? cardCvv,
  }) async {
    // Calculate totals
    final subtotal = cartItems.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    final tax = subtotal * 0.08;
    final total = subtotal + tax;
    final amountInPaisa = (total * 100).toInt();

    // Only authorize payment if paying by card
    if (paymentMethod == 'card') {
      // Generate a unique transaction reference
      final txnRef = 'TXN-\${DateTime.now().millisecondsSinceEpoch}';

      final authResp = await _paymentService.authorize(
        txnRefNo: txnRef,
        amount: amountInPaisa,
        cardNumber: cardNumber!.trim(),
        cardExpiry: cardExpiry!.trim(),
        cardCvv: cardCvv!.trim(),
      );

      if (authResp['responseCode'] != '000') {
        throw Exception(
          authResp['responseMessage'] ?? 'Payment authorization failed',
        );
      }
    }

    // Place order regardless of payment method
    await _placeOrder(
      cartItems,
      userId: userId,
      userEmail: userEmail,
      paymentMethod: paymentMethod,
      cardNumber: cardNumber,
      cardExpiry: cardExpiry,
      cardCvv: cardCvv,
    );
  }

  /// Existing method: place order without payment
  Future<void> placeOrder(
    List<Product> cartItems, {
    String? userId,
    String? userEmail,
  }) async {
    double subtotal = cartItems.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    double tax = subtotal * 0.08;
    double total = subtotal + tax;

    final orderItems =
        cartItems
            .map(
              (item) => {
                'id': item.id,
                'name': item.name,
                'sku': item.sku,
                'quantity': item.quantity,
                'price': item.price,
                'basePrice': item.basePrice,
                'isNegotiated': item.negotiatedPrice != null,
                'lineTotal': item.price * item.quantity,
              },
            )
            .toList();

    await _firestore.collection('orders').add({
      'userId': userId,
      'userEmail': userEmail,
      'products': orderItems,
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Inserts the order document into Firestore
  Future<void> _placeOrder(
    List<Product> cartItems, {
    required String userId,
    required String userEmail,
    required String paymentMethod,
    String? cardNumber,
    String? cardExpiry,
    String? cardCvv,
  }) async {
    final subtotal = cartItems.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    final tax = subtotal * 0.08;
    final total = subtotal + tax;

    final orderItems =
        cartItems
            .map(
              (item) => {
                'id': item.id,
                'name': item.name,
                'sku': item.sku,
                'quantity': item.quantity,
                'unitPrice': item.price,
                'lineTotal': item.price * item.quantity,
              },
            )
            .toList();

    final orderRef = await _firestore.collection('orders').add({
      'userId': userId,
      'userEmail': userEmail,
      'products': orderItems,
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'paymentMethod': paymentMethod,
      'cardNumber': cardNumber,
      'cardExpiry': cardExpiry,
      'cardCvv': cardCvv,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // final orderRef = await _firestore.collection('orders').add({
    //   // ... existing fields ...
    //   'deliveryStatus': 'pending',
    //   'createdAt': FieldValue.serverTimestamp(),
    // });

    await _addDeliveryInfo(orderRef.id, 'delivery_person_1');
  }

  /// Streams all orders
  Stream<List<Map<String, dynamic>>> getOrders() {
    return _firestore
        .collection('orders')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data();
                return {
                  'id': doc.id,
                  'products': List<Map<String, dynamic>>.from(data['products']),
                  'subtotal': data['subtotal'],
                  'tax': data['tax'],
                  'total': data['total'],
                  'paymentMethod': data['paymentMethod'],
                  'status': data['status'] ?? 'pending',
                  'timestamp': data['timestamp'],
                };
              }).toList(),
        );
  }

  /// Streams orders for a specific user
  Stream<List<Map<String, dynamic>>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data();
                return {
                  'id': doc.id,
                  'products': List<Map<String, dynamic>>.from(data['products']),
                  'subtotal': data['subtotal'],
                  'tax': data['tax'],
                  'total': data['total'],
                  'paymentMethod': data['paymentMethod'],
                  'status': data['status'] ?? 'pending',
                  'timestamp': data['timestamp'],
                };
              }).toList(),
        );
  }
}
