import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../providers/negotiation_provider.dart';
import '../providers/auth_provider.dart'; // Assuming you have this

class PriceNegotiationDialog extends ConsumerStatefulWidget {
  final Product product;

  const PriceNegotiationDialog({super.key, required this.product});

  @override
  ConsumerState<PriceNegotiationDialog> createState() =>
      _PriceNegotiationDialogState();
}

class _PriceNegotiationDialogState
    extends ConsumerState<PriceNegotiationDialog> {
  final TextEditingController _priceController = TextEditingController();
  String? _errorText;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Set initial value to the product's base price
    _priceController.text = widget.product.basePrice.toString();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _validatePrice(String value) {
    // Check if input is a valid number
    if (value.isEmpty) {
      setState(() => _errorText = 'Please enter a price');
      return;
    }

    try {
      final price = double.parse(value);

      // Implement your business rules for price validation
      if (price <= 0) {
        setState(() => _errorText = 'Price must be greater than zero');
      } else if (price > widget.product.basePrice * 1.5) {
        // Example rule: don't allow prices 50% higher than base price
        setState(
          () => _errorText = 'Price cannot be more than 50% above base price',
        );
      } else {
        setState(() => _errorText = null);
      }
    } catch (e) {
      setState(() => _errorText = 'Please enter a valid number');
    }
  }

  Future<void> _submitProposal() async {
    if (_errorText != null || _priceController.text.isEmpty) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final currentUser = ref.read(
        currentUserProvider,
      ); // Assuming you have this provider

      if (currentUser == null) {
        throw Exception('You must be logged in to propose a price');
      }

      await ref
          .read(negotiationProvider(widget.product.id).notifier)
          .proposePrice(
            currentUser.email,
            double.parse(_priceController.text),
            widget.product.basePrice,
            widget.product.username,
            //widget.product.id,
          );

      if (mounted) {
        Navigator.of(context).pop(true); // Success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit price: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Suggest a Price'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Base price: \$${widget.product.basePrice.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Your price offer',
              prefixText: '\$',
              errorText: _errorText,
              border: OutlineInputBorder(),
            ),
            onChanged: _validatePrice,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitProposal,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child:
              _isSubmitting
                  ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : Text('Submit Offer'),
        ),
      ],
    );
  }
}
