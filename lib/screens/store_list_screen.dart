import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/store_provider.dart';
import '../screens/store_screen.dart';
import '../models/store_model.dart';

class StoreListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeList = ref.watch(storeProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('All Stores', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
      ),
      body: storeList.when(
        data: (stores) {
          if (stores.isEmpty) {
            return Center(child: Text("No stores available"));
          }
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: stores.length,
            itemBuilder: (context, index) {
              final store = stores[index];
              return _buildStoreCard(store, context);
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Widget _buildStoreCard(Store store, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(store.imageUrl),
            backgroundColor: Colors.grey[300],
          ),
          title: Text(store.name, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(store.category),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StoreScreen(storeName: store.name, storeCategory: store.category),
              ),
            );
          },
        ),
      ),
    );
  }
}

