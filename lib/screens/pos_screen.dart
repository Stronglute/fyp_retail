import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import 'package:fyp_retail/widgets/drawer.dart';

import '../services/order_service.dart';

class POSScreen extends ConsumerStatefulWidget {
  const POSScreen({super.key});

  @override
  ConsumerState<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends ConsumerState<POSScreen> {
  // The cart now holds Product items with a "quantity" property for cart usage.
  final List<Product> cart = [];

  // Subtotal is computed using the product price multiplied by its quantity in the cart.
  double get subtotal =>
      cart.fold(0, (sum, item) => sum + (item.price * item.quantity));

  double get tax => subtotal * 0.08;

  double get total => subtotal + tax;

  @override
  Widget build(BuildContext context) {
    final productsStream = ref.watch(productsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('POS System')),
      drawer: POSDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search products...',
              ),
            ),
          ),
          Expanded(
            child: productsStream.when(
              data: (productList) {
                // Assuming productList is a List<Map<String, dynamic>>
                final products = productList.map((map) {
                  // Retrieve the id from the map (adjust this if your data stores id differently)
                  final id = map['id'];
                  return Product.fromMap(id, map);
                }).toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return GestureDetector(
                      onTap: () => _addToCart(product),
                      child: Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                color: Colors.grey[300],
                                child: Image.network(
                                  product.imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.green),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Chip(label: Text(product.category)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () =>
              const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text('Error: $error')),
            ),
          ),
          _buildCartSummary(),
        ],
      ),
    );
  }

  Widget _buildCartSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.black87,
      child: Column(
        children: [
          const Text(
            'Current Order',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          if (cart.isEmpty)
            Column(
              children: const [
                Icon(Icons.shopping_cart, size: 50, color: Colors.grey),
                Text('Your cart is empty',
                    style: TextStyle(color: Colors.grey)),
                Text('Add products to get started',
                    style: TextStyle(color: Colors.grey)),
              ],
            )
          else
            Column(
              children: cart.map((product) {
                return ListTile(
                  title: Text(product.name,
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                    '\$${product.price.toStringAsFixed(2)} x ${product
                        .quantity}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.white),
                        onPressed: () => _updateProductQuantity(product, -1),
                      ),
                      Text(product.quantity.toString(),
                          style: const TextStyle(color: Colors.white)),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () => _updateProductQuantity(product, 1),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          const Divider(color: Colors.grey),
          _buildPriceRow('Subtotal', subtotal),
          _buildPriceRow('Tax (8%)', tax),
          _buildPriceRow('Total', total, isBold: true),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50)),
            onPressed: cart.isEmpty ? null : _checkout,
            child: const Text('Checkout'),
          )
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text('\$${value.toStringAsFixed(2)}',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  // Add a product to the cart; if it already exists, increment its quantity.
  void _addToCart(Product product) {
    setState(() {
      final index = cart.indexWhere((p) => p.sku == product.sku);
      if (index != -1) {
        final updatedProduct =
        cart[index].copyWith(quantity: cart[index].quantity + 1);
        cart[index] = updatedProduct;
      } else {
        cart.add(product.copyWith(quantity: 1));
      }
    });
  }

  // Update the product quantity in the cart based on the change value (+1 or -1)
  void _updateProductQuantity(Product product, int change) {
    setState(() {
      final index = cart.indexWhere((p) => p.sku == product.sku);
      if (index != -1) {
        final newQuantity = cart[index].quantity + change;
        if (newQuantity <= 0) {
          cart.removeAt(index);
        } else {
          final updatedProduct = cart[index].copyWith(quantity: newQuantity);
          cart[index] = updatedProduct;
        }
      }
    });
  }

  // Called when the Checkout button is pressed.
  void _checkout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Order Summary"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    "Items:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                // Display each cart item with its quantity and line total
                ...cart.map((item) =>
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        "${item.name} x${item.quantity} - \$${(item.price *
                            item.quantity).toStringAsFixed(2)}",
                      ),
                    )),
                const Divider(),
                _buildPriceRow('Subtotal', subtotal),
                _buildPriceRow('Tax (8%)', tax),
                _buildPriceRow('Total', total, isBold: true),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Implement your print functionality here.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Printing order...")),
                );
              },
              child: const Text("Print"),
            ),
            ElevatedButton(
              onPressed: () async {
                // Place order using the OrderService provider.
                await ref.read(orderServiceProvider).placeOrder(cart);
                Navigator.pop(context); // Dismiss the dialog.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Order submitted successfully!")),
                );
                setState(() {
                  cart.clear();
                });
              },
              child: const Text("Confirm Order"),
            ),
          ],
        );
      },
    );
  }
}



