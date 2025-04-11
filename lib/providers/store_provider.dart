import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/store_model.dart';
import '../services/store_service.dart';

// Store Service Provider
final storeServiceProvider = Provider((ref) => StoreService());

// Store Data Provider
final storeProvider = StreamProvider<List<Store>>((ref) {
  return ref.read(storeServiceProvider).getStores();
});
