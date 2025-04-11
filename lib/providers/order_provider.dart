import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyp_retail/services/order_service.dart';

final ordersStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getOrders();
});
