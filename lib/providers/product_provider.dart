import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/product_repository.dart';

final productRepositoryProvider = Provider((ref) => ProductRepository());

final productsStreamProvider = StreamProvider((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductsStream();
});
