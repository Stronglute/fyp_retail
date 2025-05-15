import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../screens/negotiation_chat_screen.dart';
import '../providers/auth_provider.dart';
// Import needed for backdrop filter
import 'dart:ui';

class StoreScreen extends ConsumerWidget {
  final String storeName;
  final String storeCategory;

  const StoreScreen({
    super.key,
    required this.storeName,
    required this.storeCategory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsByStoreProvider(storeName));
    final cartItems = ref.watch(cartProvider);
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        scrolledUnderElevation: 5,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.green.shade800,
              size: 18,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              storeName,
              style: TextStyle(
                color: Colors.green.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              storeCategory,
              style: TextStyle(
                color: Colors.green.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.shopping_cart_rounded,
                    color: Colors.green.shade800,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/cart');
                },
              ),
              if (cartItems.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Center(
                      child: Text(
                        '${cartItems.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ).animate().scale(
                    begin: Offset(0.5, 0.5),
                    end: Offset(1, 1),
                    duration: 300.ms,
                    curve: Curves.elasticOut,
                  ),
                ),
            ],
          ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2, end: 0),
          // --- Add this IconButton for chat ---
          IconButton(
            icon: Icon(Icons.chat_bubble_outline, color: Colors.green.shade800),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ChatScreen(
                        sellerId:
                            productsAsync
                                .value!
                                .first
                                .username, // Replace with actual id
                        buyerId: auth!.email, // Replace with actual user id,
                        currentUserId:
                            auth!.email, // Replace with actual user id
                      ),
                ),
              );
            },
          ),
          SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.green.shade600,
                          ),
                          suffixIcon: Icon(
                            Icons.filter_list,
                            color: Colors.green.shade600,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
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
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .slideY(begin: -0.2, end: 0),

                  SizedBox(height: 16),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildCategoryChip('All', true, 400),
                        _buildCategoryChip('Fruits', false, 500),
                        _buildCategoryChip('Vegetables', false, 600),
                        _buildCategoryChip('Dairy', false, 700),
                        _buildCategoryChip('Bakery', false, 800),
                        _buildCategoryChip('Beverages', false, 900),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 8),

            Expanded(
              child: productsAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_basket_outlined,
                            size: 80,
                            color: Colors.green.shade200,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "No products available",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Check back later for new items",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 800.ms);
                  }

                  return CustomScrollView(
                    physics: BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.60, // Changed from 0.75
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final product = products[index];
                            return _buildProductCard(
                              product,
                              ref,
                              context,
                              index,
                            );
                          }, childCount: products.length),
                        ),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  );
                },
                loading:
                    () => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.green.shade600,
                              ),
                              strokeWidth: 3,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading products...',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                error:
                    (err, _) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 60,
                            color: Colors.red.shade400,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Something went wrong",
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            err.toString(),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.refresh),
                            label: Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: Icon(Icons.shopping_cart_checkout),
            label: Text(
              'Checkout',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          )
          .animate()
          .fadeIn(delay: 1000.ms, duration: 800.ms)
          .slideY(begin: 1, end: 0),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, int delay) {
    return Container(
          margin: EdgeInsets.only(right: 10),
          child: FilterChip(
            label: Text(label),
            selected: isSelected,
            showCheckmark: false,
            backgroundColor: Colors.grey.shade100,
            selectedColor: Colors.green.shade100,
            labelStyle: TextStyle(
              color: isSelected ? Colors.green.shade800 : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            shape: StadiumBorder(
              side: BorderSide(
                color:
                    isSelected ? Colors.green.shade400 : Colors.grey.shade300,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onSelected: (bool selected) {},
          ),
        )
        .animate()
        .fadeIn(delay: delay.ms, duration: 300.ms)
        .slideX(begin: 0.2, end: 0);
  }

  Widget _buildProductCard(
    Product product,
    WidgetRef ref,
    BuildContext context,
    int index,
  ) {
    final bool isEven = index % 2 == 0;

    return Card(
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/product-details',
                arguments: {'product': product},
              );
            },
            splashColor: Colors.blue.withOpacity(0.2),
            highlightColor: Colors.blue.withOpacity(0.1),
            child: Stack(
              children: [
                // Background gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Colors.blue.shade50],
                    ),
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Product Image Section with Sale Tag
                    Stack(
                      children: [
                        Container(
                          height: 115,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          child: Hero(
                            tag: 'product-${product.id}',
                            child: Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Colors.blue.shade50, Colors.white],
                                ),
                              ),
                              child: Image.network(
                                product.imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Colors.grey.shade400,
                                      size: 40,
                                    ),
                                  );
                                },
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue.shade400,
                                      ),
                                      strokeWidth: 2,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        // Sale Tag if product is on sale
                        if (product.oldPrice != null)
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.red.shade600,
                                    Colors.red.shade400,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'SALE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 1.3,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Product Details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue.shade900,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              product.weight ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            SizedBox(height: 6),
                            // Price Row
                            Row(
                              children: [
                                Text(
                                  "\$${product.basePrice.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: 8),
                                if (product.oldPrice != null)
                                  Text(
                                    "\$${product.oldPrice?.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Add to Cart Button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(cartProvider.notifier).addToCart(product);

                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "${product.name} added to cart!",
                                      style: TextStyle(color: Colors.white),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.blue.shade800,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              action: SnackBarAction(
                                label: 'VIEW CART',
                                textColor: Colors.white,
                                onPressed: () {
                                  Navigator.pushNamed(context, '/cart');
                                },
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shadowColor: Colors.blue.withOpacity(0.4),
                        ),
                        child: Text(
                          'Add to Cart',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (300 + (index * 50)).ms, duration: 800.ms)
        .slideY(begin: isEven ? 0.1 : 0.2, end: 0);
  }
}

// Extensions for Product model if not already in your model
extension ProductExtension on Product {
  String? get weight => null; // Replace with actual property if available
  double? get oldPrice => null; // Replace with actual property if available
  String get id => hashCode.toString(); // Replace with actual ID if available
}
