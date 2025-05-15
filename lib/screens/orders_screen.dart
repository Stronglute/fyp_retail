import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/order_provider.dart';
import 'package:fyp_retail/widgets/drawer.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsyncValue = ref.watch(ordersStreamProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: POSDrawer(),
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: ordersAsyncValue.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text("No orders found."));
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              // Format timestamp if available
              final timestamp =
                  order['timestamp'] != null
                      ? DateFormat.yMMMd().add_jm().format(
                        (order['timestamp'] as Timestamp).toDate(),
                      )
                      : "No date";
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ExpansionTile(
                  title: Text(
                    "Order ${order['id']} - \$${(order['total'] as num).toStringAsFixed(2)}",
                  ),
                  subtitle: Text("Placed on: $timestamp"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Items",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Divider(),
                          ...List<Widget>.from(
                            (order['products'] as List<dynamic>).map((product) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product image placeholder
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product["name"],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'SKU: ${product["sku"]}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text(
                                                '\$${(product["price"] as num).toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                ' × ${product["quantity"]}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '\$${(product["lineTotal"] as num).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Subtotal',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              Text(
                                '\$${(order["subtotal"] as num).toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tax',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              Text(
                                '\$${(order["tax"] as num).toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                '\$${(order["total"] as num).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.indigo,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/addstore',
                              arguments: {'order': order},
                            );
                          },
                          child: const Text('View Invoice'),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text("Error: $error")),
      ),
    );
  }
}
