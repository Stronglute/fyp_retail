import 'package:flutter/material.dart';
import 'package:fyp_retail/models/product.dart';
import 'package:fyp_retail/screens/cart_screen.dart';
import 'package:fyp_retail/screens/dashboard_screen.dart';
import 'package:fyp_retail/screens/delivery_tracking.dart';
import 'package:fyp_retail/screens/inventory_screen.dart';
import 'package:fyp_retail/screens/order_history_screen.dart';
import 'package:fyp_retail/screens/order_store_screen.dart';
import 'package:fyp_retail/screens/pos_screen.dart';
import 'package:fyp_retail/screens/orders_screen.dart';
import 'package:fyp_retail/screens/customers_screen.dart';
import 'package:fyp_retail/screens/settings_screen.dart';
import 'package:fyp_retail/screens/store_list_screen.dart';
import 'package:fyp_retail/screens/main_screen.dart';
import 'package:fyp_retail/screens/store_screen.dart';
import 'package:fyp_retail/screens/product_detail_screen.dart';
import 'package:fyp_retail/screens/seller_negotiation_screen.dart';
import 'package:fyp_retail/screens/checkout_screen.dart';
import 'package:fyp_retail/screens/negotiations_list_screen.dart';
import 'package:fyp_retail/screens/invoice_screen.dart';
import 'package:fyp_retail/screens/addstore_screen.dart';

class AppRouter {
  static const String dashboard = '/dashboard';
  static const String home = '/';
  static const String inventory = '/inventory';
  static const String pos = '/pos';
  static const String orders = '/orders';
  static const String customers = '/customers';
  static const String settings = '/settings';
  static const String storeListing = '/store-listing';
  static const String storeList = '/store-list';
  static const String storeDetails = '/store-details';
  static const String productDetails = '/product-details';
  static const String cart = '/cart';
  static const String negotiationSeller = '/negotiation-seller';
  static const String ordercustomer = '/order-customer';
  static const String checkout = '/checkout';
  static const String orderhistory = '/order-history';
  static const String customernegotiation = '/customer-negotiation';
  static const String delivarytracking = '/delivary-tracking';
  static const String invoice = '/invoice';
  static const String addstore = '/addstore';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case inventory:
        return MaterialPageRoute(builder: (_) => const InventoryScreen());
      case pos:
        return MaterialPageRoute(builder: (_) => const POSScreen());
      case orders:
        return MaterialPageRoute(builder: (_) => OrdersScreen());
      case customers:
        return MaterialPageRoute(builder: (_) => const CustomersScreen());
      case AppRouter.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case home:
        return MaterialPageRoute(builder: (_) => MainScreen());
      case cart:
        return MaterialPageRoute(builder: (_) => CartScreen());
      case ordercustomer:
        return MaterialPageRoute(builder: (_) => OrderStoreScreen());
      case checkout:
        return MaterialPageRoute(builder: (_) => const CheckoutScreen());
      case orderhistory:
        return MaterialPageRoute(builder: (_) => OrderHistoryScreen());
      case addstore:
        return MaterialPageRoute(builder: (_) => AddStoreScreen());
      case invoice:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => InvoiceScreen(order: args['order']),
        );
      case delivarytracking:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder:
              (_) => DeliveryTrackingScreen(orderId: args['orderId'] as String),
        );
      case productDetails:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder:
              (_) => ProductDetailScreen(product: args['product'] as Product),
        );
      case negotiationSeller:
        return MaterialPageRoute(
          builder: (context) => SellerNegotiationScreen(),
        );
      case customernegotiation:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder:
              (_) => NegotiationsListScreen(buyerId: args['buyerId'] as String),
        );
      case storeList:
        return MaterialPageRoute(builder: (_) => StoreListScreen());
      case storeDetails:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder:
              (_) => StoreScreen(
                storeName: args['storeName'] ?? 'Unknown Store',
                storeCategory: args['storeCategory'] ?? 'No Category',
              ),
        );
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 50),
                      SizedBox(height: 10),
                      Text(
                        '404 - Page Not Found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'The page you are looking for does not exist.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
        );
    }
  }
}
