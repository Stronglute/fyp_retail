import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/delivery_service.dart';
import '../services/order_service.dart';


/// Provider for the delivery service
final deliveryServiceProvider = Provider((ref) => DeliveryService());

/// StreamProvider for delivery history of a specific order
final deliveryHistoryProvider =
    StreamProvider.family<List<DeliveryEvent>, String>((ref, orderId) {
      final svc = ref.read(deliveryServiceProvider);
      return svc.getDeliveryHistory(orderId);
    });
    

final deliveryTrackingProvider = StreamProvider.family<Map<String, dynamic>, String>((ref, orderId) async* {
  final orderService = ref.read(orderServiceProvider);
  
  // Use public getter instead of direct access
  final orderDoc = await orderService.firestore.collection('orders').doc(orderId).get();
  final orderData = orderDoc.data() ?? {};
  
  // Get delivery person info
  final deliveryPersonId = orderData['deliveryPersonId'];
  final deliveryPersonInfo = await orderService.getDeliveryPersonInfo(deliveryPersonId);
  
  // Get live location
  final locationStream = orderService.getDeliveryPersonLocation(deliveryPersonId);
  
  await for (final position in locationStream) {
    yield {
      'order': orderData,
      'deliveryPerson': deliveryPersonInfo,
      'currentLocation': {
        'lat': position.latitude,
        'lng': position.longitude,
      },
      'estimatedDeliveryTime': orderData['estimatedDeliveryTime'],
    };
  }
});