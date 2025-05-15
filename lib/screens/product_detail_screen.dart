import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/product.dart';
import '../models/negotiation.dart';
import '../providers/cart_provider.dart';
import '../providers/negotiation_provider.dart';
import '../widgets/price_negotiation_dialog.dart';

class ProductDetailScreen extends ConsumerWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final negotiation = ref.watch(negotiationProvider(product.id));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with hero animation
            Hero(
              tag: 'product-image-${product.id}',
              child: Container(
                height: 300,
                width: double.infinity,
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(product.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: 24),

            // Product name and price
            Text(
              product.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '\$${product.basePrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
                if (product.price != product.basePrice) ...[
                  const SizedBox(width: 12),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Product description
            Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Negotiation section
            _buildNegotiationSection(context, ref, negotiation),
            const SizedBox(height: 24),

            // Add to cart button
            ElevatedButton(
              onPressed: () {
                if (negotiation.value != null &&
                    negotiation.value!.status == NegotiationStatus.accepted) {
                  ref
                      .read(cartProvider.notifier)
                      .addToCartWithNegotiatedPrice(
                        product,
                        negotiation.value!.proposedPrice,
                      );
                } else {
                  ref.read(cartProvider.notifier).addToCart(product);
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Added to cart'),
                    backgroundColor: Colors.green.shade800,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
                Navigator.pop(context);
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
              child: const Text('Add to Cart', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNegotiationSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<Negotiation?> negotiation,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.handshake, color: Colors.green.shade800),
              ),
              const SizedBox(width: 12),
              const Text(
                'Price Negotiation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Suggest your price for this product. The seller may accept, reject, or counter your offer.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          negotiation.when(
            data: (data) {
              if (data == null) {
                return _buildNegotiateButton(context);
              } else if (data.status == NegotiationStatus.proposed) {
                return _buildPendingOffer(data.proposedPrice);
              } else if (data.status == NegotiationStatus.counterOffered) {
                return _buildCounterOffer(context, ref, data);
              } else if (data.status == NegotiationStatus.accepted) {
                return _buildAcceptedOffer(data.proposedPrice);
              } else {
                return _buildRejectedOffer(context);
              }
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Error: $error'),
          ),
        ],
      ),
    );
  }

  Widget _buildNegotiateButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (context) => PriceNegotiationDialog(product: product),
        );
      },
      icon: const Icon(Icons.price_change),
      label: const Text(
        'Suggest a Price',
        style: TextStyle(color: Colors.black),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildPendingOffer(double proposedPrice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your offer: \$${proposedPrice.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.access_time, color: Colors.orange.shade800, size: 20),
            const SizedBox(width: 8),
            Text(
              'Waiting for seller response',
              style: TextStyle(color: Colors.orange.shade800),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCounterOffer(
    BuildContext context,
    WidgetRef ref,
    Negotiation negotiation,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your offer: \$${negotiation.proposedPrice.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          'Seller counter offer: \$${negotiation.counterPrice!.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  ref
                      .read(negotiationProvider(product.id).notifier)
                      .respondToProposal(negotiation.id, 'accepted');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Accept'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ref
                      .read(negotiationProvider(product.id).notifier)
                      .respondToProposal(negotiation.id, 'rejected');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade800,
                  side: BorderSide(color: Colors.red.shade800),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Decline'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAcceptedOffer(double acceptedPrice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade800),
            const SizedBox(width: 8),
            Text(
              'Offer Accepted!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Your price: \$${acceptedPrice.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'You can now add this item to your cart with the negotiated price.',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildRejectedOffer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.cancel, color: Colors.red.shade800),
            const SizedBox(width: 8),
            Text(
              'Offer Declined',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            await showDialog(
              context: context,
              builder: (context) => PriceNegotiationDialog(product: product),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade800,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Make New Offer'),
        ),
      ],
    );
  }
}
