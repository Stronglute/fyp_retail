import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/store_model.dart';
import '../providers/store_provider.dart';
import '../screens/store_list_screen.dart';
import '../screens/auth_screen.dart';
import '../providers/auth_provider.dart';

class StoreListingPage extends ConsumerWidget {
  const StoreListingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeList = ref.watch(storeProvider);
    final user = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'GroceryHub',
          style: TextStyle(
            color: Colors.green.shade800,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 0.5,
          ),
        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: Text(
                      user.name[0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    user.name,
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          IconButton(
            icon: Icon(
              user == null ? Icons.person_outline : Icons.logout,
              color: Colors.green.shade800,
            ),
            onPressed: () {
              if (user == null) {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                            const AuthScreen(),
                    transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              } else {
                ref.read(authProvider.notifier).logout();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Logged out successfully'),
                    backgroundColor: Colors.green.shade800,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for stores or products...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.green.shade600,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Colors.green.shade400,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 500.ms)
                  .slideY(begin: 0.2, end: 0),
            ),

            // Hero Section
            Container(
                  height: 300,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.green.shade600,
                                  Colors.green.shade800,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Background pattern
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CustomPaint(painter: CirclePatternPainter()),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                        'Fresh Groceries',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          height: 1.2,
                                        ),
                                      )
                                      .animate()
                                      .fadeIn(delay: 200.ms, duration: 600.ms)
                                      .slideX(begin: -0.2, end: 0),
                                  Text(
                                        'Delivered To Your Door',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600,
                                          height: 1.2,
                                        ),
                                      )
                                      .animate()
                                      .fadeIn(delay: 400.ms, duration: 600.ms)
                                      .slideX(begin: -0.2, end: 0),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Shop from local stores with fast delivery.',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                      height: 1.3,
                                    ),
                                  ).animate().fadeIn(
                                    delay: 600.ms,
                                    duration: 600.ms,
                                  ),
                                  const SizedBox(height: 30),
                                  ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor:
                                              Colors.green.shade800,
                                          elevation: 5,
                                          shadowColor: Colors.black.withOpacity(
                                            0.3,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Shop Now',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      )
                                      .animate()
                                      .fadeIn(delay: 800.ms, duration: 600.ms)
                                      .scale(
                                        begin: const Offset(0.8, 0.8),
                                        end: const Offset(1, 1),
                                      ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Image.network(
                                'https://example.com/path/to/grocery_bag.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: 200.ms, duration: 800.ms)
                .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1, 1),
                ),

            const SizedBox(height: 30),

            // How It Works Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HOW IT WORKS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade600,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Get Your Groceries in 3 Easy Steps',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 800.ms),

            const SizedBox(height: 16),

            Container(
              height: 250,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children:
                    [
                          _buildStepCard(
                            icon: Icons.storefront_outlined,
                            step: '1',
                            title: 'Choose Store',
                            description: 'Browse local stores near you',
                            color: Colors.green.shade100,
                            iconColor: Colors.green.shade800,
                            delay: 400,
                          ),
                          _buildStepCard(
                            icon: Icons.shopping_basket_outlined,
                            step: '2',
                            title: 'Add Items',
                            description: 'Select your favorite products',
                            color: Colors.amber.shade100,
                            iconColor: Colors.amber.shade800,
                            delay: 600,
                          ),
                          _buildStepCard(
                            icon: Icons.delivery_dining_outlined,
                            step: '3',
                            title: 'Fast Delivery',
                            description: 'Get it delivered to your door',
                            color: Colors.blue.shade100,
                            iconColor: Colors.blue.shade800,
                            delay: 800,
                          ),
                        ]
                        .map(
                          (widget) => Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: widget,
                          ),
                        )
                        .toList(),
              ),
            ),

            const SizedBox(height: 30),

            // Store List Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'POPULAR STORES',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade600,
                          letterSpacing: 1.5,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const StoreListScreen(),
                              transitionsBuilder: (
                                context,
                                animation,
                                secondaryAnimation,
                                child,
                              ) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View All',
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: Colors.green.shade800,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Featured Local Stores',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 800.ms),

            const SizedBox(height: 16),

            storeList.when(
              data: (stores) {
                if (stores.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.store_mall_directory_outlined,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No stores available",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms, duration: 800.ms);
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: stores.length > 3 ? 3 : stores.length,
                  itemBuilder: (context, index) {
                    final store = stores[index];
                    return _buildStoreCard(store, index);
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
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Error loading stores",
                          style: TextStyle(
                            color: Colors.red.shade400,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms, duration: 800.ms),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
            onPressed: () {},
            backgroundColor: Colors.green.shade800,
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            label: const Text(
              'Cart',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            elevation: 4,
          )
          .animate()
          .fadeIn(delay: 1000.ms, duration: 800.ms)
          .slideY(begin: 1, end: 0),
    );
  }

  // Step Card Widget for "How It Works" Section
  Widget _buildStepCard({
    required IconData icon,
    required String step,
    required String title,
    required String description,
    required Color color,
    required Color iconColor,
    required int delay,
  }) {
    return Container(
          width: 200,
          margin: const EdgeInsets.only(right: 10),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withOpacity(0.9), color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          step,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Icon(icon, color: Colors.white, size: 36),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: delay.ms, duration: 800.ms)
        .slideX(begin: 0.2, end: 0);
  }

  // Store Card Widget
  // Store Card Widget
  Widget _buildStoreCard(Store store, int index) {
    return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.green.shade50, Colors.white],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'store-${store.id}',
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: NetworkImage(store.imageUrl),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.green.shade900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              store.category,
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        store.rating >= 4.5
                                            ? Colors.green.shade100
                                            : Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 2,
                                        offset: const Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        color:
                                            store.rating >= 4.5
                                                ? Colors.green.shade800
                                                : Colors.amber.shade800,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        store.rating.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              store.rating >= 4.5
                                                  ? Colors.green.shade800
                                                  : Colors.amber.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${store.reviews} reviews)',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.green.shade700,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (600 + (index * 100)).ms, duration: 800.ms)
        .slideY(begin: 0.1, end: 0);
  }
}

// Custom painter for decorative circle patterns in the hero section
class CirclePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.fill;

    // Draw several circles of varying sizes
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.2),
      size.width * 0.2,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.8),
      size.width * 0.15,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.9),
      size.width * 0.1,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
