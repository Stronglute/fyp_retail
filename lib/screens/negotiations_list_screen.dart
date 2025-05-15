import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/negotiation_provider.dart';
import '../providers/product_provider.dart';
import 'product_detail_screen.dart';
import '../models/negotiation.dart';

class NegotiationsListScreen extends ConsumerWidget {
  final String buyerId;
  const NegotiationsListScreen({Key? key, required this.buyerId})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final negotiationsAsync = ref.watch(buyerNegotiationsProvider(buyerId));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Negotiations'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: negotiationsAsync.when(
        loading:
            () => Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.green.shade800,
                ),
              ),
            ),
        error:
            (e, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading negotiations',
                    style: TextStyle(color: Colors.red[400], fontSize: 18),
                  ),
                ],
              ),
            ),
        data: (negos) {
          if (negos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.handshake_outlined,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No negotiations yet',
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: negos.length,
            itemBuilder: (ctx, i) {
              final n = negos[i];
              final productAsync = ref.watch(productByIdProvider(n.productId));

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: productAsync.when(
                    loading:
                        () => const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    error:
                        (e, _) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('Error loading product: $e'),
                        ),
                    data:
                        (product) => InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        ProductDetailScreen(product: product),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey[200],
                                        image:
                                            product.imageUrl != null
                                                ? DecorationImage(
                                                  image: NetworkImage(
                                                    product.imageUrl,
                                                  ),
                                                  fit: BoxFit.cover,
                                                )
                                                : null,
                                      ),
                                      child:
                                          product.imageUrl == null
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
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Your offer: \$${n.proposedPrice.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Colors.green.shade800,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _buildStatusBadge(n.status),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Original Price: \$${product.price.toStringAsFixed(2)}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    Text(
                                      '${((n.proposedPrice - product.price) / product.price * 100).toStringAsFixed(1)}% off',
                                      style: TextStyle(
                                        color: Colors.green.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                  ),
                ).animate().fadeIn(delay: (100 * i).ms).slideX(begin: 0.2, end: 0),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(NegotiationStatus status) {
    Color color;
    String text;
    switch (status) {
      case NegotiationStatus.accepted:
        color = Colors.green;
        text = 'Accepted';
        break;
      case NegotiationStatus.rejected:
        color = Colors.red;
        text = 'Rejected';
        break;
      case NegotiationStatus.counterOffered:
        color = Colors.orange;
        text = 'Countered';
        break;
      case NegotiationStatus.proposed:
      default:
        color = Colors.blue;
        text = 'Pending';
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
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
