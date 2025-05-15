import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyp_retail/services/order_service.dart';
import '../providers/auth_provider.dart';

final ordersStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getOrders();
});

final userOrdersStreamProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, userId) {
      final orderService = ref.watch(orderServiceProvider);
      return orderService.getUserOrders(userId);
    });

final currentUserOrdersProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  final user = ref.watch(authProvider);
  final orderService = ref.watch(orderServiceProvider);

  if (user == null) {
    return Stream.value([]);
  }

  return orderService.getUserOrders(user.id);
});
