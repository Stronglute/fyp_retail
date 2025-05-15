import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

// Provider to store selected products for checkout
final selectedProductsProvider = StateNotifierProvider<SelectedProductsNotifier, List<Product>>((ref) {
  return SelectedProductsNotifier();
});

class SelectedProductsNotifier extends StateNotifier<List<Product>> {
  SelectedProductsNotifier() : super([]);

  void setSelectedProducts(List<Product> products) {
    state = products;
  }

  void clearSelectedProducts() {
    state = [];
  }
}