import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';

class StoreScreen extends ConsumerWidget {
  final String storeName;
  final String storeCategory;

  StoreScreen({required this.storeName, required this.storeCategory});

  final List<Map<String, dynamic>> products = [
    {'id': '1', 'name': 'Fresh Apples', 'price': 3.99, 'image': '🍏'},
    {'id': '2', 'name': 'Organic Milk', 'price': 2.49, 'image': '🥛'},
    {'id': '3', 'name': 'Whole Wheat Bread', 'price': 1.99, 'image': '🍞'},
    {'id': '4', 'name': 'Carrots', 'price': 1.49, 'image': '🥕'},
    {'id': '5', 'name': 'Cheddar Cheese', 'price': 4.99, 'image': '🧀'},
    {'id': '6', 'name': 'Strawberries', 'price': 5.99, 'image': '🍓'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(storeName, style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.green),
            onPressed: () {
              Navigator.pushNamed(context, '/cart'); // Navigate to Cart Screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store Banner
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.green, Colors.lightGreen]),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
              ),
              child: Center(
                child: Text(
                  storeName,
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Store Info
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Categories: $storeCategory', style: TextStyle(color: Colors.grey[700])),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(' 4.5 (200 reviews)', style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Product List Grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Available Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            SizedBox(height: 10),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _buildProductCard(
                    product['id'],
                    product['name'],
                    product['price'],
                    product['image'],
                    ref,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Product Card Widget
  Widget _buildProductCard(String id, String name, double price, String image, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(image, style: TextStyle(fontSize: 40)),
            SizedBox(height: 10),
            Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text("\$${price.toStringAsFixed(2)}", style: TextStyle(color: Colors.green)),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final product = Product(id: id, name: name, price: price, sku: 'SKU$id', category: 'General', stock: 2, username: '', imageUrl: '');
                ref.read(cartProvider.notifier).addToCart(product);
                ScaffoldMessenger.of(ref.context).showSnackBar(SnackBar(content: Text("$name added to cart!")));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, minimumSize: Size(80, 30)),
              child: Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}

