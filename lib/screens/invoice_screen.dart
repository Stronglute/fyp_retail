import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InvoiceScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  const InvoiceScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final id = order['id'] as String;
    final products = List<Map<String, dynamic>>.from(order['products']);
    final subtotal = order['subtotal'] as num;
    final tax = order['tax'] as num;
    final total = order['total'] as num;
    final timestamp = order['timestamp'] as Timestamp?;
    final dateStr =
        timestamp != null
            ? DateFormat.yMMMd().add_jm().format(timestamp.toDate())
            : 'N/A';
    final userEmail = order['userEmail'] as String?;

    return Scaffold(
      appBar: AppBar(title: Text('Invoice #$id')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('INVOICE', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Invoice No: $id'), Text('Date: $dateStr')],
            ),
            if (userEmail != null) ...[
              const SizedBox(height: 4),
              Text('Billed To: $userEmail'),
            ],
            const Divider(height: 32, thickness: 2),

            // Line items
            Expanded(
              child: ListView(
                children: [
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(4),
                      1: FlexColumnWidth(1.5),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(2),
                    },
                    children: [
                      TableRow(
                        children: [
                          Text('Item', style: _headerStyle),
                          Text('Qty', style: _headerStyle),
                          Text('Price', style: _headerStyle),
                          Text('Line Total', style: _headerStyle),
                        ],
                      ),
                      ...products.map((p) {
                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(p['name'] as String),
                            ),
                            Text('${p['quantity']}'),
                            Text('\$${(p['price'] as num).toStringAsFixed(2)}'),
                            Text(
                              '\$${(p['lineTotal'] as num).toStringAsFixed(2)}',
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 32),

            // Totals
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildTotalRow('Subtotal', subtotal),
                  const SizedBox(height: 4),
                  _buildTotalRow('Tax', tax),
                  const SizedBox(height: 4),
                  _buildTotalRow('Total', total, isBold: true, fontSize: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const TextStyle _headerStyle = TextStyle(fontWeight: FontWeight.bold);

  Widget _buildTotalRow(
    String label,
    num amount, {
    bool isBold = false,
    double fontSize = 14,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: fontSize,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}
