import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/store_provider.dart';
import '../screens/store_screen.dart';
import '../models/store_model.dart';

class StoreListScreen extends ConsumerWidget {
  const StoreListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeList = ref.watch(storeProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.green.shade800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Stores',
          style: TextStyle(
            color: Colors.green.shade800,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: storeList.when(
        data: (stores) {
          if (stores.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store_mall_directory_outlined,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No stores available",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms);
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: stores.length,
            itemBuilder: (context, index) {
              final store = stores[index];
              return _buildStoreCard(store, context, index);
            },
          );
        },
        loading:
            () => Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.green.shade800,
                ),
              ),
            ),
        error:
            (err, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Error loading stores",
                    style: TextStyle(color: Colors.red.shade400, fontSize: 18),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms),
      ),
    );
  }

  Widget _buildStoreCard(Store store, BuildContext context, int index) {
    // Define theme colors
    final greenPrimary = Color(0xFF2E7D32); // Forest green
    final greenLight = Color(0xFFAED581); // Light green
    final greenAccent = Color(0xFF00C853); // Vibrant green accent

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Card(
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => StoreScreen(
                          storeName: store.name,
                          storeCategory: store.category,
                        ),
                  ),
                );
              },
              splashColor: greenLight.withOpacity(0.2),
              highlightColor: greenLight.withOpacity(0.1),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.white,
                      Color(0xFFF1F8E9),
                    ], // White to very light green
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'store-image-${store.id}',
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                            image: DecorationImage(
                              image: NetworkImage(store.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: greenPrimary,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                store.category,
                                style: TextStyle(
                                  color: greenPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        store.rating >= 4.5
                                            ? greenAccent.withOpacity(0.15)
                                            : greenLight.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color:
                                          store.rating >= 4.5
                                              ? greenAccent.withOpacity(0.3)
                                              : greenLight.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        color:
                                            store.rating >= 4.5
                                                ? greenAccent
                                                : greenPrimary,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        store.rating.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              store.rating >= 4.5
                                                  ? greenAccent
                                                  : greenPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${store.reviews} reviews)',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: greenPrimary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: greenPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .animate()
          .fadeIn(delay: (100 + (index * 100)).ms, duration: 600.ms)
          .slideX(begin: 0.2, end: 0, curve: Curves.easeOutQuint)
          .scale(
            begin: Offset(0.97, 0.97),
            end: Offset(1, 1),
            duration: 500.ms,
            curve: Curves.easeOut,
          ),
    );
  }
}
