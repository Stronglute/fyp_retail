import 'package:fyp_retail/models/product.dart';

import 'customer.dart';

class Order {
  final String id;
  final Customer customer;
  final List<Product> products;
  final double total;
  final String status;

  Order({
    required this.id,
    required this.customer,
    required this.products,
    required this.total,
    required this.status,
  });
}
