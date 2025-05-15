// providers/cart_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

final cartProvider = StateNotifierProvider<CartNotifier, List<Product>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<Product>> {
  CartNotifier() : super([]);

  void addToCart(Product product) {
    state = [...state, product];
  }
  
  // Add a product with a negotiated price
  void addToCartWithNegotiatedPrice(Product product, double negotiatedPrice) {
    // Create a copy of the product with the negotiated price
    final productWithNegotiatedPrice = product.copyWithNegotiatedPrice(negotiatedPrice);
    state = [...state, productWithNegotiatedPrice];
  }

  void removeFromCart(String productId) {
    state = state.where((product) => product.id != productId).toList();
  }

  void clearCart() {
    state = [];
  }
}

