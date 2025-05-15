import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/negotiation.dart';
import '../providers/auth_provider.dart';
import '../providers/negotiation_provider.dart';
import '../providers/product_provider.dart';

class SellerNegotiationScreen extends ConsumerWidget {
  const SellerNegotiationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Negotiation Requests'),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(
                'Please login as seller',
                style: TextStyle(color: Colors.red[400], fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    ref.invalidate(sellerNegotiationsProvider(user.id));
    final sellerNegotiationsAsync = ref.watch(
      sellerNegotiationsProvider(user.email),
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Negotiation Requests'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: sellerNegotiationsAsync.when(
        data: (negotiations) {
          if (negotiations.isEmpty) {
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
                    'No negotiation requests found',
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: negotiations.length,
            itemBuilder: (context, index) {
              final negotiation = negotiations[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder(
                          future: ref.read(
                            productByIdProvider(negotiation.productId).future,
                          ),

                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            final product = snapshot.data!;
                            return Column(
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
                                          (product.imageUrl as String?) == null
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
                                            'SKU: ${product.sku}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Original Price:',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              '\$${negotiation.originalPrice.toStringAsFixed(2)}',
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
                              'Buyer Offer:',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              '\$${negotiation.proposedPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ],
                        ),
                        if (negotiation.status ==
                            NegotiationStatus.counterOffered)
                          Column(
                            children: [
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Your Counter:',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  Text(
                                    '\$${negotiation.counterPrice?.toStringAsFixed(2) ?? 'N/A'}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        const SizedBox(height: 16),
                        _buildStatusIndicator(negotiation.status),
                        if (negotiation.status == NegotiationStatus.proposed)
                          Column(
                            children: [
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () async {
                                        await ref
                                            .read(
                                              negotiationProvider(
                                                negotiation.productId,
                                              ).notifier,
                                            )
                                            .respondToProposal(
                                              negotiation.id,
                                              'accepted',
                                            );
                                        ref.invalidate(
                                          sellerNegotiationsProvider(
                                            negotiation.sellerId,
                                          ),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.green.shade800,
                                        side: BorderSide(
                                          color: Colors.green.shade800,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      child: const Text('Accept'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () async {
                                        await ref
                                            .read(
                                              negotiationProvider(
                                                negotiation.productId,
                                              ).notifier,
                                            )
                                            .respondToProposal(
                                              negotiation.id,
                                              'rejected',
                                            );
                                        ref.invalidate(
                                          sellerNegotiationsProvider(
                                            negotiation.sellerId,
                                          ),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red.shade800,
                                        side: BorderSide(
                                          color: Colors.red.shade800,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      child: const Text('Reject'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed:
                                    () => _showCounterOfferDialog(
                                      context,
                                      negotiation,
                                      ref,
                                    ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade800,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Counter Offer'),
                              ),
                            ],
                          ),
                      ],
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
            (err, stack) => Center(
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
      ),
    );
  }

  Widget _buildStatusIndicator(NegotiationStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case NegotiationStatus.accepted:
        color = Colors.green;
        text = 'Offer Accepted';
        icon = Icons.check_circle;
        break;
      case NegotiationStatus.rejected:
        color = Colors.red;
        text = 'Offer Rejected';
        icon = Icons.cancel;
        break;
      case NegotiationStatus.counterOffered:
        color = Colors.orange;
        text = 'Counter Offer Sent';
        icon = Icons.swap_horiz;
        break;
      case NegotiationStatus.proposed:
      default:
        color = Colors.blue;
        text = 'New Offer Received';
        icon = Icons.notifications_active;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showCounterOfferDialog(
    BuildContext context,
    Negotiation negotiation,
    WidgetRef ref,
  ) {
    final counterPriceController = TextEditingController(
      text: negotiation.proposedPrice.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder:
          (dialogContext) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Make Counter Offer',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: counterPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Your Price',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.attach_money),
                      prefixText: '\$',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[800],
                            side: BorderSide(color: Colors.grey[400]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final counterPrice = double.tryParse(
                              counterPriceController.text,
                            );
                            if (counterPrice != null) {
                              try {
                                await ref
                                    .read(
                                      negotiationProvider(
                                        negotiation.productId,
                                      ).notifier,
                                    )
                                    .respondToProposal(
                                      negotiation.id,
                                      'counter_offered',
                                      counterPrice,
                                    );
                                ref.invalidate(
                                  sellerNegotiationsProvider(
                                    negotiation.sellerId,
                                  ),
                                );
                                Navigator.pop(dialogContext);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error submitting counter offer: $e',
                                    ),
                                    backgroundColor: Colors.red[400],
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please enter a valid price'),
                                  backgroundColor: Colors.red[400],
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade800,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
