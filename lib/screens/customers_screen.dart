import 'package:flutter/material.dart';

import '../widgets/drawer.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      drawer: POSDrawer(),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Customer $index'),
            subtitle: const Text('customer@example.com'),
          );
        },
      ),
    );
  }
}
