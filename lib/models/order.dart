import 'package:fyp_retail/models/product.dart';

import 'customer.dart';

import 'package:fyp_retail/models/product.dart';
import 'customer.dart';

/// Defines payment methods for an order.
enum PaymentMethod { card, cashOnDelivery }

class Order {
  final String id;
  final Customer customer;
  final List<Product> products;
  final double total;
  final String status;

  /// Indicates how the customer chose to pay.
  final PaymentMethod paymentMethod;

  /// Card details (only for PaymentMethod.card).
  final String? cardNumber;
  final String? cardExpiry;
  final String? cardCvv;

  Order({
    required this.id,
    required this.customer,
    required this.products,
    required this.total,
    required this.status,
    required this.paymentMethod,
    this.cardNumber,
    this.cardExpiry,
    this.cardCvv,
  });
}
