import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyp_retail/widgets/drawer.dart';
import '../providers/product_provider.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsyncValue = ref.watch(productsStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Management')),
      drawer: POSDrawer(),
      body: Column(
        children: [
          _buildAddProductButton(context, ref),
          Expanded(
            child: productsAsyncValue.when(
              data: (products) => _buildProductTable(context, ref, products),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddProductButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
        onPressed: () => _showProductDialog(context, ref),
      ),
    );
  }

  Widget _buildProductTable(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> products) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,  // ✅ Allows horizontal scrolling
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 16,  // ✅ Adjust spacing between columns
          columns: const [
            DataColumn(label: Text('Product')),
            DataColumn(label: Text('SKU')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Actions')),
          ],
          rows: products.map((product) => _buildProductRow(context, ref, product)).toList(),
        ),
      ),
    );
  }


  DataRow _buildProductRow(BuildContext context, WidgetRef ref, Map<String, dynamic> product) {
    print(product);
    return DataRow(
      cells: [
        DataCell(Text(product['name'])),
        DataCell(Text(product['sku'])),
        DataCell(Text(product['category'])),
        DataCell(Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showProductDialog(context, ref, product: product),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => ref.read(productRepositoryProvider).deleteProduct(product['id']),
            ),
          ],
        )),
      ],
    );
  }

  void _showProductDialog(BuildContext context, WidgetRef ref, {Map<String, dynamic>? product}) {
    final nameController = TextEditingController(text: product?['name'] ?? '');
    final skuController = TextEditingController(text: product?['sku'] ?? '');
    final categoryController = TextEditingController(text: product?['category'] ?? '');
    final imageController = TextEditingController(text: product?['imageUrl'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return  AlertDialog(
          title: Text(product == null ? 'Add Product' : 'Edit Product'),
          content: SingleChildScrollView(
            child: ConstrainedBox(  // ✅ FIX: Prevents Overflow
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,  // ✅ Limits height to 50% of screen
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Product Name')),
                  TextField(controller: skuController, decoration: const InputDecoration(labelText: 'SKU')),
                  TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
                  TextField(controller: imageController, decoration: const InputDecoration(labelText: 'Image URL')),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final repository = ref.read(productRepositoryProvider);
                if (product == null) {
                  repository.addProduct(nameController.text, skuController.text, categoryController.text, imageController.text);
                } else {
                  repository.updateProduct(
                    product['id'],
                    nameController.text,
                    skuController.text,
                    categoryController.text,
                    imageController.text,
                  );
                }
                Navigator.pop(context);
              },
              child: Text(product == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }
}

