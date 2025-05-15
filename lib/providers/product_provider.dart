import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/product_repository.dart';
import 'package:fyp_retail/services/product_service.dart';
import 'package:fyp_retail/models/product.dart';

final productRepositoryProvider = Provider((ref) => ProductRepository());

final productsStreamProvider = StreamProvider((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductsStream();
});

final productByIdProvider = StreamProvider.family<Product, String>(
  (ref, productId) =>
      ref.watch(productServiceProvider).getProductById(productId),
);

// 1) expose the service
final productServiceProvider = Provider((ref) => ProductService());

// 2) a StreamProvider.family keyed on storeName
final productsByStoreProvider = StreamProvider.family<List<Product>, String>(
  (ref, storeName) =>
      ref.watch(productServiceProvider).getProductsByStore(storeName),
);
