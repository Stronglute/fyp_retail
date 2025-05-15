import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Order History'),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 60,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Please login to view your order history',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    final ordersAsyncValue = ref.watch(currentUserOrdersProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Order History'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ordersAsyncValue.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You have no orders yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final timestamp = order['timestamp'] as Timestamp?;
              final date =
                  timestamp != null
                      ? DateFormat(
                        'MMM dd, yyyy - hh:mm a',
                      ).format(timestamp.toDate())
                      : 'Date not available';

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showOrderDetails(context, order),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order #${order['id'].substring(0, 8)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              _buildStatusBadge(order['status'] ?? 'pending'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(date, style: TextStyle(color: Colors.grey[600])),
                          const SizedBox(height: 16),
                          const Text(
                            'Items:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...List.generate((order['products'] as List).length, (
                            i,
                          ) {
                            final product = (order['products'] as List)[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${product['name']} x${product['quantity']}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '\$${product['lineTotal'].toStringAsFixed(2)}',
                                  ),
                                ],
                              ),
                            );
                          }),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '\$${order['total'].toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    _showOrderDetails(context, order);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.green.shade800,
                                    side: BorderSide(
                                      color: Colors.green.shade800,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text('View Details'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/delivary-tracking',
                                      arguments: {'orderId': order['id']},
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade800,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text('Track Order'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.2, end: 0),
              );
            },
          );
        },
        loading:
            () => Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.green.shade800,
                ),
              ),
            ),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading orders',
                    style: TextStyle(color: Colors.red[400], fontSize: 18),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        break;
      case 'processing':
        color = Colors.blue;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      case 'pending':
      default:
        color = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Order Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.receipt_long,
                            color: Colors.green.shade800,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order ID',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              order['id'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.calendar_today,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              DateFormat('MMM dd, yyyy - hh:mm a').format(
                                (order['timestamp'] as Timestamp).toDate(),
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              order['status'] ?? 'pending',
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.info_outline,
                            color: _getStatusColor(
                              order['status'] ?? 'pending',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              order['status'] ?? 'Pending',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(
                                  order['status'] ?? 'pending',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Order Items',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: (order['products'] as List).length,
                      itemBuilder: (context, index) {
                        final product = (order['products'] as List)[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey[200],
                                  image:
                                      product['imageUrl'] != null
                                          ? DecorationImage(
                                            image: NetworkImage(
                                              product['imageUrl'],
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                          : null,
                                ),
                                child:
                                    product['imageUrl'] == null
                                        ? Icon(
                                          Icons.shopping_bag,
                                          color: Colors.grey[400],
                                        )
                                        : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'SKU: ${product['sku']}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${product['quantity']} x ${product['unitPrice'].toStringAsFixed(2)}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  Text(
                                    '\$${product['lineTotal'].toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    _buildPriceRow('Subtotal', order['subtotal']),
                    _buildPriceRow('Tax', order['tax']),
                    _buildPriceRow('Total', order['total'], isBold: true),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/delivary-tracking',
                          arguments: {'orderId': order['id']},
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade800,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Track Order'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  Widget _buildPriceRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 16,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 16,
            ),
          ),
        ],
      ),
    );
  }
}
