import 'package:flutter/material.dart';
import 'package:fyp_retail/widgets/drawer.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: POSDrawer(),
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: () {
              // TODO: Add theme toggle logic if needed
            },
          ),
          const CircleAvatar(child: Text('JD')),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCard(
              'Total Revenue',
              '\$45,231.89',
              '+20.1% from last month',
              Icons.attach_money,
            ),
            _buildStatCard(
              'Sales',
              '+2350',
              '+10.1% from last month',
              Icons.shopping_cart,
            ),
            _buildStatCard(
              'Products',
              '124',
              '+12 new products added',
              Icons.inventory,
            ),
            _buildStatCard(
              'Customers',
              '573',
              '+18 new customers',
              Icons.people,
            ),
            const SizedBox(height: 16),
            _buildRecentSalesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
  ) {
    return Card(
      color: Colors.black87,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 36, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSalesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Sales',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: null, // Implement "View All" navigation
                child: Row(
                  children: [
                    Text('View All', style: TextStyle(color: Colors.green)),
                    Icon(Icons.arrow_forward, size: 16, color: Colors.green),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Text(
          "Today's sales transactions",
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 8),
        _buildRecentSalesTable(),
      ],
    );
  }

  Widget _buildRecentSalesTable() {
    final sales = [
      {
        'id': 'ORD-001',
        'customer': 'John Smith',
        'status': 'Completed',
        'amount': '\$125.99',
      },
      {
        'id': 'ORD-002',
        'customer': 'Sarah Johnson',
        'status': 'Processing',
        'amount': '\$42.50',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DataTable(
        headingRowHeight: 36,
        dataRowHeight: 48,
        columnSpacing: 12,
        headingRowColor: WidgetStateProperty.all(Colors.black54),
        columns: const [
          DataColumn(
            label: Text('Order ID', style: TextStyle(color: Colors.white)),
          ),
          DataColumn(
            label: Text('Customer', style: TextStyle(color: Colors.white)),
          ),
          DataColumn(
            label: Text('Status', style: TextStyle(color: Colors.white)),
          ),
          DataColumn(
            label: Text('Amount', style: TextStyle(color: Colors.white)),
          ),
        ],
        rows: sales.map((sale) => _buildRecentSalesRow(sale)).toList(),
      ),
    );
  }

  DataRow _buildRecentSalesRow(Map<String, String> sale) {
    return DataRow(
      cells: [
        DataCell(
          Text(sale['id']!, style: const TextStyle(color: Colors.white)),
        ),
        DataCell(
          Text(sale['customer']!, style: const TextStyle(color: Colors.white)),
        ),
        DataCell(_buildStatusChip(sale['status']!)),
        DataCell(
          Text(sale['amount']!, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor = Colors.grey;
    Color textColor = Colors.white;

    switch (status) {
      case 'Completed':
        backgroundColor = Colors.green;
        break;
      case 'Processing':
        backgroundColor = Colors.orange;
        break;
      case 'Cancelled':
        backgroundColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}
