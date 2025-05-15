import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import '../providers/selected_products_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final Set<String> selectedItems = {};

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body:
          cartItems.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Your cart is empty",
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final product = cartItems[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: selectedItems.contains(product.id),
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          selectedItems.add(product.id);
                                        } else {
                                          selectedItems.remove(product.id);
                                        }
                                      });
                                    },
                                    activeColor: Colors.green.shade800,
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.grey[200],
                                      image:
                                          product.imageUrl.isNotEmpty
                                              ? DecorationImage(
                                                image: NetworkImage(
                                                  product.imageUrl,
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                              : null,
                                    ),
                                    child:
                                        product.imageUrl.isEmpty
                                            ? Icon(
                                              Icons.shopping_bag,
                                              color: Colors.grey[400],
                                            )
                                            : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        if (product.price != product.basePrice)
                                          Text(
                                            "\$${product.basePrice.toStringAsFixed(2)}",
                                            style: TextStyle(
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        Text(
                                          "\$${product.price.toStringAsFixed(2)}",
                                          style: TextStyle(
                                            color:
                                                product.price !=
                                                        product.basePrice
                                                    ? Colors.green.shade800
                                                    : Colors.grey[800],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red[400],
                                    ),
                                    onPressed:
                                        () => ref
                                            .read(cartProvider.notifier)
                                            .removeFromCart(product.id),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(delay: (50 * index).ms),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Selected Items:',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              selectedItems.length.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total:',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              '\$${_calculateTotal(cartItems).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed:
                              selectedItems.isEmpty
                                  ? null
                                  : () async {
                                    final selectedProducts =
                                        cartItems
                                            .where(
                                              (item) => selectedItems.contains(
                                                item.id,
                                              ),
                                            )
                                            .toList();

                                    ref
                                        .read(selectedProductsProvider.notifier)
                                        .setSelectedProducts(selectedProducts);

                                    for (String id in selectedItems) {
                                      ref
                                          .read(cartProvider.notifier)
                                          .removeFromCart(id);
                                    }

                                    Navigator.pushNamed(context, '/checkout');
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade800,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: const Text(
                            'Proceed to Checkout',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  double _calculateTotal(List<Product> cartItems) {
    return cartItems
        .where((item) => selectedItems.contains(item.id))
        .fold(0, (sum, item) => sum + item.price);
  }
}
